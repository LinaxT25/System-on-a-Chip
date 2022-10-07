library ieee;
use ieee.std_logic_1164.all;

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
begin
    -- seta o endereço de memoria apontado por ele
    -- data_addr 
    -- read(arq_load, data_in(i))
    -- write()
    -- file_open(read_mode)

    data_out <= data_in when data_read = '0' and data_write = '1' and falling_edge(clock);
end architecture;