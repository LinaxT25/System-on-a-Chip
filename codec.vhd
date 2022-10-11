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
    
    --Function to read files(only read 1 byte)
    impure function read_array(nome_arq : string)
        return std_logic_vector is
            type t_arq is file of std_logic_vector;
            file arq_int : t_arq open read_mode is nome_arq;
            variable result : std_logic_vector(7 downto 0);
        begin
            while not endfile(arq_int) loop
                read(arq_int, result);
            end loop;
            return result;
    end function read_array;

begin
    archive_inout: process (interrupt)
    begin
        if read_signal = '1' and write_signal = '0' then
           codec_data_out <= read_array("dados.dat");
        end if;
    end process;
    valid <= '1'; 
end architecture;