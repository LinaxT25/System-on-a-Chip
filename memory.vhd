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
    -- type data_vet_t is array (data_width - 1 downto 0) of std_logic;
    -- type dt_vet_t is array((2**data_width) downto 0) of data_vet_t;
    type data_vet_t is array (2**data_width downto 0) of std_logic_vector(data_width - 1 downto 0); 
    signal data_vet : data_vet_t := (others => "00000000");--(others => "00000000"));
    signal a : std_logic;
begin
    whole_p: process (clock) is
        begin
            -- the read part is almost compleated, it has right casts for the range of the first dimension
            -- now, I need to see if it is going to get que right slice of each part
            if data_read = '1' and data_write = '0' then
                -- d 4x 7 a 0                      d 7 a 0
                data_out(data_width-1 downto 0) <= data_vet(to_integer(unsigned(data_addr)))(data_width-1 downto 0);
                data_out((data_width*2) - 1 downto data_width) <= data_vet(to_integer(unsigned(data_addr) + 1))(data_width-1 downto 0);
                data_out((data_width*3) - 1 downto data_width*2) <= data_vet(to_integer(unsigned(data_addr) + 2))(data_width-1 downto 0);
                data_out((data_width*4) - 1 downto data_width*3) <= data_vet(to_integer(unsigned(data_addr) + 3))(data_width-1 downto 0);
                report integer'image(to_integer(unsigned(data_vet(to_integer(unsigned(data_addr))))));
                report integer'image(to_integer(unsigned(data_vet(to_integer(unsigned(data_addr) + 1)))));
                report integer'image(to_integer(unsigned(data_vet(to_integer(unsigned(data_addr) + 2)))));
                report integer'image(to_integer(unsigned(data_vet(to_integer(unsigned(data_addr) + 3)))));
            elsif falling_edge(clock) and data_read = '0' and data_write = '1' then
                data_vet(to_integer(unsigned(data_addr))) <= data_in;
            end if;
        end process;
end architecture;
