library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    data_in : out std_logic_vector((data_width*2)-1 downto 0); -- data to be written in memory
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
    signal SP_aux, IP_aux : std_logic_vector(addr_width-1 downto 0) := (others => '0');
    signal zero_aux, dropped_item, op_helper : std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal setup_finished : boolean := false;
    signal op_1, op_2, op_3 : integer := 0;
    signal last_instruction : integer range 0 to 14;
begin
    -- Precisa de um processo de inicialização que checará o clock e o valid para saber 
    -- Quando deve ser escrito na memória de instruçoes, e controlado por aqui de forma a incrementar o 
    -- IP, quando o valid passar mais de um ciclo de clock admitir que terminou a leitura do codec das instruções
    -- E então começar a executar as instruçoes.
    start: process(clock, codec_valid)
    begin
    -- tem que ser verificado se funcionam os dois ao mesmo tempo, pode ser que um nao consiga alcancer a 'velocidade'
    -- do outro, o que implica em fazer algum wait, cabivel só em test_bench
        if(codec_valid = '1' and rising_edge(clock)) then 
            IP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(IP_aux)) + 1, IP_aux'length)); 
            IP <= IP_aux;
        elsif(codec_valid = '0' and rising_edge(clock)) then
            IP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(IP_aux)) - 1, IP_aux'length));
            IP <= IP_aux;
            setup_finished <= true;
        end if;
    end process;
    
    cpu_itself: process
        variable instruction_aux : integer range 0 to 14;
    begin
        if(setup_finished = true) then
            data_read <= '0';
            data_write <= '0';
            codec_interrupt <= '0';
            codec_read <= '0';
            codec_write <= '0';
            if last_instruction = 5 then
                SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) - 1, SP_aux'length));
                SP <= SP_aux;
            end if;
            instruction_aux :=  to_integer(unsigned(instruction_in(data_width - 1 downto data_width - 4)));
            last_instruction <= instruction_aux;
            if (inner_halt = '0' and halt = '0' and rising_edge(clock)) then -- verificar essa condicao depois
                case instruction_aux is
                    when 0 => -- HLT 0
                        inner_halt <= '1';
                    -- IN 1
                    when 1 => 
                        codec_read <= '1';
                        codec_interrupt <= '1';
                        wait on codec_valid; -- verificar como proceder para a espera do mesmo ser 1 para continuar o procedimento
                        data_in((data_width*2)-1 downto data_width) <= zero_aux; -- most valuable one
                        data_in(data_width-1 downto 0) <= codec_data_out(7 downto 0);
                        SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) + 1, SP_aux'length));
                        SP <= SP_aux; 
                        data_write <= '1';
                    -- OUT 2
                    when 2 => 
                        data_read <= '1';
                        SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) - 1, SP_aux'length));
                        codec_data_in <= data_out((data_width*4)-1 downto (data_width*3));
                        codec_write <= '1';
                        codec_interrupt <= '1';
                        wait on codec_valid;
                        SP <= SP_aux;
                    -- PUSH IP 3 
                    when 3 =>  
                        IP(7 downto 0) <= instruction_in;
                    -- PUSH imm 4 
                    when 4 => 
                        data_in((data_width*2)-1 downto data_width) <= zero_aux;
                        data_in(7 downto 4) <= "0000";
                        data_in(3 downto 0) <= instruction_in(3 downto 0);
                        SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) + 1, SP_aux'length));
                        SP <= SP_aux;
                        data_write <= '1';
                    -- DROP 5
                    when 5 => 
                        data_read <= '1';
                        dropped_item <= data_out((data_width*4)-1 downto (data_width*3));
                        data_read <= '0';
                        data_in((data_width*2)-1 downto data_width) <= zero_aux; 
                        data_in(data_width-1 downto 0) <= zero_aux;
                        data_write <= '1';
                    -- DUP 6
                    when 6 => 
                        data_in((data_width*2)-1 downto data_width) <= zero_aux; 
                        data_in(data_width-1 downto 0) <= dropped_item;
                        SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) + 1, SP_aux'length));
                        SP <= SP_aux;
                        data_write <= '1';
                    -- ADD 8
                    when 8 => 
                        data_read <= '1';
                        op_1 <= to_integer(unsigned(data_out((data_width*4)-1 downto (data_width*3))));
                        op_2 <= to_integer(unsigned(data_out((data_width*3)-1 downto (data_width*2))));
                        op_helper <= std_logic_vector(to_unsigned(op_1 + op_2, op_helper'length));
                        data_in((data_width*2)-1 downto data_width) <= zero_aux; 
                        data_in(data_width-1 downto 0) <= op_helper;
                        if (to_integer(unsigned(SP_aux)) - 1) > 0 then
                            SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) - 1, SP_aux'length));
                            SP <= SP_aux;
                        end if;
                        data_write <= '1';
                    -- SUB 9
                    when 9 =>
                        data_read <= '1';
                        op_1 <= to_integer(unsigned(data_out((data_width*4)-1 downto (data_width*3))));
                        op_2 <= to_integer(unsigned(data_out((data_width*3)-1 downto (data_width*2))));
                        op_helper <= std_logic_vector(to_unsigned(op_1 - op_2, op_helper'length));
                        data_in((data_width*2)-1 downto data_width) <= zero_aux; 
                        data_in(data_width-1 downto 0) <= op_helper;
                        if (to_integer(unsigned(SP_aux)) - 1) > 0 then
                            SP_aux <= std_logic_vector(to_unsigned(to_integer(unsigned(SP_aux)) - 1, SP_aux'length));
                            SP <= SP_aux;
                        end if;
                        data_write <= '1';
                    -- NAND 10
                    --when "1010" => 
                        --data_in <= codec_data_out nand data_out;
                    -- SLT 11
                    --when "1011" =>
                        --data_in <= codec_data_out < data_out;
                    -- SHL 12
                    --when "1100" =>
                        --data_in <= codec_data_out sll data_out;
                    -- SHR 13 
                    --when "1101" =>
                        --data_in <= codec_data_out srl data_out; 
                    -- JEQ 14
                    --when "1110" => 
                        -- if(codec_data_out = data_out) then
                            --IP <= Op3 + IP_aux
                    -- JMP 15
                    --when "1111" => 
                    -- IP_aux <= codec_data_out
                    -- IP <= IP_aux
                    when others =>
                        op_1 <= 1;
                end case;
            else
                inner_halt <= '0';
                IP_aux <= std_logic_vector(to_unsigned(0, IP_aux'length));
                SP_aux <= std_logic_vector(to_unsigned(0, SP_aux'length));
                IP <= IP_aux;
                SP <= SP_aux;
            end if;
        end if;
        wait on clock, setup_finished;
    end process;
end architecture;
