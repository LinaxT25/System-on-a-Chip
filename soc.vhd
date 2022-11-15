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

begin
    --cpu_entity: entity work.cpu(behavioral)
      --          generic map()
       --         port map();

    instruction_memory: entity work.memory(behavioral)
                        generic map(16, 8)
                        port map(clock, ins_read, ins_write, IP, ins_in, Times_instruction_in);

    data_memory:    entity work.memory(behavioral)
                    generic map(16, 8)
                    port map(clock, data_read, data_write, SP, data_in, data_out);

    codec_entity_firmware:   entity work.codec(bevahioral)
                             port map(codec_interrupt, codec_read, codec_write, codec_valid, codec_data_in, codec_data_out);
end architecture;
