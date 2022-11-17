library ieee;
use ieee.std_logic_1164.all;

entity soc is
    generic(
        firmware_filename: string := "firmware.bin"
    );

    port(
        clock: in std_logic; -- Clock signal
        started: in std_logic -- Start execution when '1'
    );
end entity;

architecture mixed of soc is
    signal inst_read, inst_write, data_read, data_write, codec_read, codec_write, codec_interrupt, codec_valid, halt: std_logic;
    signal codec_data_in, codec_data_out, data_in : std_logic_vector(7 downto 0);
    signal IP, SP : std_logic_vector(15 downto 0);
    signal data_out, instruction_out : std_logic_vector(31 downto 0);
    signal started_aux : std_logic := '0';
begin

    cpu_e:  entity work.cpu(behavioral)
            generic map(16, 8)
            port map(clock, halt, SP, IP, instruction_out(31 downto 24), data_in, data_out, data_read, data_write, codec_interrupt, codec_read, codec_write, codec_valid, codec_data_out, codec_data_in);

    IMEM:   entity work.memory(behavioral)
            generic map(16, 8)
            port map(clock, inst_read, inst_write, IP, codec_data_out, instruction_out);

    DMEM:   entity work.memory(behavioral)
            generic map(16, 8)
            port map(clock, data_read, data_write, SP, data_in, data_out);

    codec_e:    entity work.codec(bevahioral)
                generic map(firmware_filename)
                port map(codec_interrupt, codec_read, codec_write, codec_valid, codec_data_in, codec_data_out);

    start: process(clock, codec_valid)
        variable codec_aux_valid : std_logic := '0'; -- receive the codec_valid when it's done
        variable counter : integer := 0;             -- count every clock border
    begin
        if started_aux = '0' then
            if rising_edge(clock) then
                codec_read <= '1';
                codec_write <= '0';
                codec_interrupt <= '1';
            end if;
            if(codec_valid = '1') then
                codec_aux_valid := '1';
                codec_interrupt <= '0';
            end if;
            if(codec_aux_valid = '1' and rising_edge(clock)) then 
                codec_aux_valid := '0';
                counter := 0;
            elsif(counter = 1 and rising_edge(clock)) then
                inst_write <= '0';
                inst_read <= '1';
                started_aux <= '1';
            elsif(codec_aux_valid = '0') then
                counter := counter + 1;
            end if;
        end if;
    end process;
end architecture;