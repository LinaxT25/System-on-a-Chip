library ieee, std;
use ieee.std_logic_1164.all;
use std.textio.all;

entity codec is
    port(
        interrupt: in std_logic; -- Interrupt signal
        read_signal: in std_logic; -- Read signal
        write_signal: in std_logic; -- Write signal
        valid: out std_logic; -- Valid signal

    -- Byte written to codec
        codec_data_in : in std_logic_vector(7 downto 0);
    -- Byte read from codec
        codec_data_out : out std_logic_vector(7 downto 0)
    );
end entity;

architecture behavioral of codec is
    type r_arq is file of integer;
    type w_arq is file of character;
    type vet_int is array(7 downto 0) of integer;

    procedure read_file is
        file arq : r_arq open read_mode is "dados.dat";
        variable output : vet_int;
        variable char : integer;
        variable index : integer := 0;
    begin
        while index < 8 loop
        read(arq, char);
        output(index) := char;
        index := index + 1;
    end loop;
    end procedure read_file;

    procedure write_file is
        file arq : w_arq open write_mode is "dados.dat";
        variable char : character;
    begin
        write(arq,char);
    end procedure;

begin
    in_out: process (interrupt) is
    begin
        if read_signal = '1' and write_signal = '0' and interrupt = '1' then
            read_file;
            valid <= '1';
        elsif read_signal = '0' and write_signal = '1' and interrupt = '1' then
            write_file;
            valid <= '1';
        end if;
    end process;
end architecture;