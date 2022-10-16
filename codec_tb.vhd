library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity codec_tb is
end entity;

architecture mixed of codec_tb is
    -- signals declaration
    signal interrupt, read_signal, write_signal, valid : std_logic;
    signal codec_data_in, codec_data_out :  std_logic_vector(7 downto 0);
begin
    mem_t:  entity work.codec(behavioral)
            port map (interrupt, read_signal, write_signal, valid, codec_data_in, codec_data_out);

    testing_memory: process is
        file arq_r : text open read_mode is "escrita.txt";
        variable read_line : line;
        variable read_out : bit_vector(7 downto 0);
        type line_tv is record
            inte, rd_s, wr_s, v : std_logic;
            c_dt_in, c_dt_out : std_logic_vector(7 downto 0);
        end record;
        type vet_l_tv is array (0 to 23) of line_tv;
        constant tb : vet_l_tv :=
        --   IN  read  write valid CodInput   CodOut
        (   ('0', '0', '0', '0', "00000000", "00000000" ),
            ('1', '1', '0', '1', "00000000", "10000001" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '1', '0', '1', "00000000", "01111110" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '1', '0', '1', "00000000", "11110000" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '1', '0', '1', "00000000", "00001111" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '1', '0', '1', "00000000", "10101010" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '1', '0', '1', "00000000", "01010101" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '0', '1', '1', "10000001", "00000000" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '0', '1', '1', "01111110", "00000000" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '0', '1', '1', "11110000", "00000000" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '0', '1', '1', "00001111", "00000000" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '0', '1', '1', "10101010", "00000000" ),
            ('0', '0', '0', '0', "00000000", "00000000" ), -- pulse simulation
            ('1', '0', '1', '1', "01010101", "00000000" ));
    begin
        for i in tb'range loop
            interrupt <= tb(i).inte;
            read_signal <= tb(i).rd_s;
            write_signal <= tb(i).wr_s;
            codec_data_in <= tb(i).c_dt_in;
      
            wait for 2 ns;
            if tb(i).wr_s = '0' and tb(i).inte = '1' then
                assert codec_data_out = tb(i).c_dt_out
                report "YAMETE KUDASAI" & integer'image(i)
                severity error;
            end if; 

            if tb(i).wr_s = '1' and tb(i).inte = '1' then
                if not endfile(arq_r) then
                   readline(arq_r, read_line);
                   read(read_line, read_out);
                end if;
                assert to_stdlogicvector(read_out) = tb(i).c_dt_out
                report "Baka!" & integer'image(i)
                severity error;   
            end if;
        end loop;
        report "Fim dos Testes";
        wait;
    end process;
end architecture;
