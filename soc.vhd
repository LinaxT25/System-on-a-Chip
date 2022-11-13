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

    --instruction_memory: entity work.memory(behavioral)
        --                generic map()
                    --    port map();

    --data_memory:    entity work.memory(behavioral)
        --            generic map()
           --         port map();

   -- codec_entity:   entity work.codec(bevahioral)
           --         port map();
end architecture;