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
    signal SP_aux, IP_aux : std_logic_vector(addr_width-1 downto 0) := (others => 0);
    signal setup_finished : boolean := false;

begin
    -- Precisa de um processo de inicialização que checará o clock e o valid para saber 
    -- Quando deve ser escrito na memória de instruçoes, e controlado por aqui de forma a incrementar o 
    -- IP, quando o valid passar mais de um ciclo de clock admitir que terminou a leitura do codec das instruções
    -- E então começar a executar as instruçoes.
    start: process(clock, codec_valid)
    begin
        if(codec_valid = '1' and rising_edge(clock)) then
            IP_aux <= IP_aux + 1;
        elsif(codec_valid = '0' and rising_edge(clock)) then
            setup_finished <= true;
        end if;
    end process;
    
    cpu: process(clock, setup_finished)
        variable instruction_aux : std_logic_vector(3 downto 0);
    begin
        if(setup_finished = true) then
            instruction_aux(3 downto 0) :=  instruction_in(data_width - 1 downto data_width - 4);

            if (inner_halt /= '1' or halt = '0') then
                inner_halt <= '0';

                case instruction_aux is
                    -- HLT 0
                    when "0000" => 
                        inner_halt <= '1';
                    -- IN 1
                    when "0001" => 
                        codec_write <= '0';
                        codec_read <= '1';
                        wait on codec_valid; 
                        data_in <= codec_data_out;
                        -- att SP 
                        data_write <= '1';
                        data_read <= '0';
                    -- OUT 2
                    when "0010" => 
                        data_read <= '1';
                        data_write <= '0';
                        -- att SP
                        codec_data_in <= data_out(7 downto 0);
                        codec_write <= '1';
                        codec_read <= '0';
                        wait on codec_valid;
                    -- PUSH IP 3 
                    when "0011" =>  
                        IP(7 downto 0) <= instruction_in;
                    -- PUSH imm 4 
                    when "0100" => 
                        data_in(7 downto 4) <= "0000";
                        data_in(3 downto 0) <= instruction_in(3 downto 0);
                        data_write <= '1';
                        data_read <= '0';
                        -- att SP
                    -- DROP 5
                    when "0101" => 
                        --IP_aux
                        data_in <= "00000000";
                        data_write <= '1';
                    -- DUP 6
                    when "0110" => 
                    -- ADD 8
                    when "1000" => 
                    -- SUB 9
                    when "1001" => 
                    -- NAND 10
                    when "1010" => 
                    -- SLT 11
                    when "1011" =>
                    -- SHL 12
                    when "1100" =>
                    -- SHR 13 
                    when "1101" => 
                    -- JEQ 14
                    when "1110" => 
                    -- JMP 15
                    when "1111" => 
                end case;
            end if;
        else 
            wait on setup_finished;
        end if;
    end process;
end architecture;