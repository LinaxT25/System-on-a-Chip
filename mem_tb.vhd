library ieee;
use ieee.std_logic_1164.all;

entity mem_tb is
end entity;

architecture mixed of mem_tb is
    -- signals declaration
    signal addr_width: natural := 16; -- Memory Address Width (in bits)
    signal data_width: natural := 8; -- Data Width (in bits)
    signal clock, data_read, data_write : std_logic;
    signal data_addr :  std_logic_vector(addr_width-1 downto 0);
    signal data_in :    std_logic_vector(data_width-1 downto 0);
    signal data_out :   std_logic_vector((data_width*4)-1 downto 0);
begin
    mem_t:  entity work.memory(behavioral)
            generic map (addr_width, data_width)
            port map (data_addr, data_in, data_out);

    testing_memory: process is
        type line_tv is record
            ck, dt_r, dt_w : std_logic;
            dt_addr : std_logic_vector(addr_width-1 downto 0);
            dt_in   : std_logic_vector(data_width-1 downto 0);
            dt_out  : std_logic_vector((data_width*4)-1 downto 0);
        end record;
        type vet_l_tv is array (0 to 7) of line_tv;
        constant tb : vet_l_tv :=
        -- ck  read write address input output
        (('1', '1', '0', "000000"
            ));
    begin

    end process;
end architecture;
