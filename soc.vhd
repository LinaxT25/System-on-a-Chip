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