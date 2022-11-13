library ieee, std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    file arq_r : text open read_mode is "dados.txt";
    file arq_w: text open write_mode is "escrita.txt"; 
begin
    in_out: process (interrupt) is
        variable write_aux : Bit_vector(7 downto 0);
        variable rreeaad_char : Bit_vector(7 downto 0);
        variable write_line, read_line : line; 
    begin
        if read_signal = '1' and write_signal = '0' and rising_edge(interrupt) then
            readline(arq_r, read_line);
            read(read_line, rreeaad_char);
            codec_data_out <= to_stdlogicvector(rreeaad_char);
            valid <= '1';
            wait for 1 ns;
            valid <= '0';
        end if;
        if read_signal = '0' and write_signal = '1' and rising_edge(interrupt) then
            write(write_line, to_bitvector(codec_data_in));
            writeline(arq_w, write_line);
            valid <= '1';
            wait for 1 ns;
            valid <= '0';
        end if;
    end process;
end architecture;