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