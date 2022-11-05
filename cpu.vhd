library ieee;
use ieee.std_logic_1164.all;

entity cpu is
    generic(
        addr_width: natural := 16; -- Memory Address Width (in bits)
        data_width: natural := 8 -- Data Width (in bits)
    );

port(
    clock: in std_logic; -- Clock signal
    halt : in std_logic; -- Halt processor execution when '1'

    ---- Begin Memory Signals ---
    -- Data address given to memory
    SP: out std_logic_vector(addr_width-1 downto 0); -- holds the data address
    -- Instruction address given to memory
    IP: out std_logic_vector(addr_width-1 downto 0); -- holds the address to the next instruction

    -- Instruction byte received from memory
    instruction_in : in std_logic_vector(data_width-1 downto 0); -- holds the instruction itself
    -- Data sent to memory when data_read = '0' and data_write = '1'
    data_in : out std_logic_vector(data_width-1 downto 0); -- data to be written in memory
    -- Data sent from memory when data_read = '1' and data_write = '0'
    data_out : in std_logic_vector((data_width*4)-1 downto 0);  -- data read from memory

    data_read : out std_logic; -- When '1', read data from memory
    data_write: out std_logic; -- When '1', write data to memory
    ---- End Memory Signals ---

    ---- Begin Codec Signals ---
    codec_interrupt: out std_logic; -- Interrupt signal
    codec_read: out std_logic; -- Read signal
    codec_write: out std_logic; -- Write signal
    codec_valid: in std_logic; -- Valid signal

    -- Byte read from codec
    codec_data_out : in std_logic_vector(7 downto 0);
    -- Byte written to codec
    codec_data_in : out std_logic_vector(7 downto 0)
    --- End Codec Signals ---
);
end entity;

architecture behavioral of cpu is
    signal inner_halt : std_logic := '0';
    
begin
    sua_mae: process(clock)
        variable instruction_aux : std_logic_vector(3 downto 0);
    begin
        instruction_aux(3 downto 0) :=  instruction_in(data_width - 1 downto data_width - 4);
        if (inner_halt /= '1') or (rising_edge(halt)) then
            inner_halt <= '0';
            case instruction_aux is
            -- when "0000" => -- HLT 0
                    -- inner_halt <= '1'
                when "0001" => -- IN 1
                    codec_write <= '0';
                    codec_read <= '1';
                    wait on codec_valid; -- verificar
                    data_in <= codec_data_out;
                    -- att SP 
                    data_write <= '1';
                    data_read <= '0';
                when "0010" => -- OUT 2
                    data_read <= '1';
                    data_write <= '0';
                    -- att SP
                    codec_data_in <= data_out(7 downto 0);
                    codec_write <= '1';
                    codec_read <= '0';
                    wait on codec_valid; -- verificar
                when "0011" => -- PUSH IP 3 -- 2 bytes
                    IP(7 downto 0) <= instruction_in;
                when "0100" => -- PUSH imm 4 -- 1 byte
                    data_in <= instruction_in;
                    data_write <= '1';
                    data_read <= '0';
                    --att SP
                when "0101" => -- DROP 5
                    --if IP
                      --  IP <= IP - 1
                when "0110" => -- DUP 6
                when "1000" => -- ADD 8
                when "1001" => -- SUB 9
                when "1010" => -- NAND 10
                when "1011" => -- SLT 11
                when "1100" => -- SHL 12
                when "1101" => -- SHR 13
                when "1110" => -- JEQ 14
                when "1111" => -- JMP 15
            end case;
        end if;
    end process;
end architecture;