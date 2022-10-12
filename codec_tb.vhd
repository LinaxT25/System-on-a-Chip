library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
        type line_tv is record
            inte, rd_s, wr_s, v : std_logic;
            c_dt_in, c_dt_out : std_logic_vector(7 downto 0);
        end record;
        type vet_l_tv is array (0 to 1) of line_tv;
        constant tb : vet_l_tv :=
        --   IN  read  write valid   CDI         CDO
        (   ('1', '1', '0', '1', "00000000", "10000001" ),
            ('1', '1', '0', '1', "00000000", "01111110" ));
    begin
        for i in tb'range loop
            interrupt <= tb(i).inte;
            read_signal <= tb(i).rd_s;
            write_signal <= tb(i).wr_s;
            valid <= tb(i).v;
            codec_data_in <= tb(i).c_dt_in;
      
            wait for 1 ns;
            assert codec_data_out = tb(i).c_dt_out
            report "YAMETE KUDASAI " & integer'image(i)
            severity error;
        end loop;
        report "Fim dos Testes";
        wait;
    end process;
end architecture;
