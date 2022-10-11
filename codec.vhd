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
    type vet_int is array(7 downto 0) of integer;
    
    impure function read_array(nome_arq : string)
        return vet_int is
            type t_arq is file of integer;
            file arq_int : t_arq open read_mode is nome_arq;
            variable result : vet_int := (others => 0);
            variable i : natural := 1;
        begin
            while not endfile(arq_int) and i <= 8 loop
                read(arq_int, result(i));
                i := i + 1;
            end loop;
            return result;
    end function read_array;

begin
    archive_inout: process (interrupt)
        variable dados : vet_int;
    begin
        if read_signal = '1' and write_signal = '0' then
           dados := read_array("dados.dat");
        end if;
    end process;
    valid <= '1'; 
end architecture;