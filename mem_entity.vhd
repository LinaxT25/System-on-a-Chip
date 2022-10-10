library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    generic(
        addr_width: natural := 16; -- Memory Address Width (in bits)
        data_width: natural := 8 -- Data Width (in bits)
    );

port(
    clock: in std_logic; -- Clock signal; Write on Falling-Edge
    data_read : in std_logic; -- When '1', read data from memory
    data_write: in std_logic; -- When '1', write data to memory
 -- Data address given to memory
    data_addr : in std_logic_vector(addr_width-1 downto 0);
 -- Data sent from memory when data_read = '1' and data_write = '0'
    data_in : in std_logic_vector(data_width-1 downto 0);
 -- Data sent to memory when data_read = '0' and data_write = '1'
    data_out : out std_logic_vector((data_width*4)-1 downto 0)
);
end entity;

architecture behavioral of memory is
    -- create a new type named something near signal little_data_vet : std_logic_vector(data_width - 1 down to 0);
    -- create a new variable data_vet : little_data_vet type (addr_width - 1 downto 0);
    -- aparently it doesn't need to be first a type because we're
    -- declaring a mult dimensional vector. hope it works
    -- needs to change the address range (first dimension)
    -- type data_vet_t is array ((2**data_width) downto 0, data_width - 1 downto 0) of std_logic;
    type data_vet_t is array (data_width - 1 downto 0) of std_logic;
    type dt_vet_t is array((2**data_width) downto 0) of data_vet_t;
    signal data_vet : dt_vet_t := (others => 0);
    signal a : std_logic;
begin
    read_d: process (data_read) is
        begin
            if data_read = '1' and data_write = '0' then
                data_out((data_width*4)-1 downto 0) <= data_vet((signed(data_addr)+3) downto signed(data_addr'value));
            else
                a <= '0';     
            end if;
        end process;
    write_d: process (data_write) is
        begin
            if data_read = '0' and data_write = '1' and falling_edge(clock) then
                data_vet(signed(data_addr)) <= data_in;
                data_out((data_width*4)-1 downto 0) <= data_vet((signed(data_addr)+3) downto signed(data_addr));
            else
                a <= '0';
            end if;
        end process;
end architecture;
