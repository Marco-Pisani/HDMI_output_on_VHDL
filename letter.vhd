----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2023 05:01:33 PM
-- Design Name: 
-- Module Name: letter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity letter is
    Port (
        data_in: in std_logic_vector(23 downto 0);
        address_in: in std_logic_vector(16 downto 0);
        char_in: in std_logic_vector(5 downto 0);
        
        -- enable -->starts the procedure
        -- write  -->writes to the register
        -- mode   -->selects mode of operation
        
        enable, mode, reset, clock, write, memory_busy: in std_logic;
        memory_enable, busy: out std_logic;
        
        address_out: out std_logic_vector(16 downto 0);
        data_out: out std_logic_vector(23 downto 0)
     );
end letter;

architecture Behavioral of letter is
    constant address_length: integer := 17;

    type map_type is array (45 downto 0) of std_logic_vector(29 downto 0);    -- data for each character
    signal bit_map: map_type;

    -- buffer registers
    signal data, data_wire: std_logic_vector(23 downto 0);
    signal char, char_wire: std_logic_vector(5 downto 0);
    signal address, address_wire: std_logic_vector(16 downto 0);
    
    -- 
    signal x_counter, x_counter_wire: integer range 0 to 7;
    signal y_counter, y_counter_wire: integer range 0 to 7;
    signal bit_ptr, bit_ptr_wire: integer range 0 to 31;
    
    signal status, status_wire: std_logic;
begin

    data_wire <= data;
    char_wire <= char;
    address_wire <= address;
    
    x_counter_wire <= x_counter;
    y_counter_wire <= y_counter;
    bit_ptr_wire <= bit_ptr;
    status_wire <= status;
    
    busy <= status;
    
    bit_map(0)  <= "100011000111111100011000101110";  -- A
    bit_map(1)  <= "011111000110001011111000101111";  -- B
    bit_map(2)  <= "111100000100001000010000111110";  -- C
    bit_map(3)  <= "011111000110001100011000101111";  -- D
    bit_map(4)  <= "111110000100001001110000111111";  -- E
    bit_map(5)  <= "000010000100111000010000111111";  -- F
    bit_map(6)  <= "111101000111001000010000111110";  -- G
    bit_map(7)  <= "100011000110001111111000110001";  -- H
    bit_map(8)  <= "001000010000100001000010000100";  -- I
    bit_map(9)  <= "001110010100100001000010011111";  -- J
    bit_map(10) <= "100011000101001001110100110001";  -- K
    bit_map(11) <= "011110000100001000010000100001";  -- L
    bit_map(12) <= "100011000110001101011101110001";  -- M
    bit_map(13) <= "100011000111001101011001110001";  -- N
    bit_map(14) <= "011101000110001100011000101110";  -- O
    bit_map(15) <= "000010000101111100011000101111";  -- P
    bit_map(16) <= "111110110101001010010100101111";  -- Q
    bit_map(17) <= "100010100101111100011000101111";  -- R
    bit_map(18) <= "011111000010000011100000111110";  -- S
    bit_map(19) <= "001000010000100001000010011111";  -- T
    bit_map(20) <= "011101000110001100011000110001";  -- U
    bit_map(21) <= "001000101001010010101000110001";  -- V
    bit_map(22) <= "010100101010101100011000110001";  -- W
    bit_map(23) <= "100011000101010001000101010001";  -- X
    bit_map(24) <= "001000010000100010101000110001";  -- Y
    bit_map(25) <= "111110000100010011001000011111";  -- Z
    
    bit_map(26) <= "111110010000100001010011000100";  -- 1
    bit_map(27) <= "111110001000100010001000101110";  -- 2
    bit_map(28) <= "011101000110000011001000101110";  -- 3
    bit_map(29) <= "100001000011111100011000110001";  -- 4
    bit_map(30) <= "111111000010000111110000111111";  -- 5
    bit_map(31) <= "011101000110001011110000111110";  -- 6
    bit_map(32) <= "000010001000100010001000011111";  -- 7
    bit_map(33) <= "011101000110001011101000101110";  -- 8
    bit_map(34) <= "011101000011110100011000101110";  -- 9
    bit_map(35) <= "011101000110101101011000101110";  -- 0
    
    bit_map(36) <= "000110001100000000000000000000";  -- .
    bit_map(37) <= "000010001000000000000000000000";  -- ,
    
    bit_map(38) <= "001000000000100010001000101110";  -- ?
    bit_map(39) <= "001000000000100001000010000100";  -- !
    
    bit_map(40) <= "000000010000100111110010000100";  -- +
    bit_map(41) <= "000000000000000111110000000000";  -- -
    bit_map(42) <= "000001111100000000001111100000";  -- =
    bit_map(43) <= "000010001000010001000100001000";  -- /
    bit_map(44) <= "000000000000000011100111000000";  -- *
    bit_map(45) <= "111111111111111111111111111111";  
    
    reading: process(reset, clock)
    begin
        if reset = '1' then
            char    <= (others => '0');
            data    <= (others => '0');
            address <= (others => '0');
        elsif rising_edge(clock) then
            char    <= char_wire;
            data    <= data_wire;
            address <= address_wire;
            
            if write = '1' then
                char    <= char_in;
                data    <= data_in;
                address <= address_in;
--                char    <= "001110";
--                data    <= x"1010DD";
--                address <= "00000000000000000";
            end if;
        end if;
    end process;
    
    status_proc: process(reset, clock)
    begin
        if reset = '1' then
            status <= '0';
        elsif rising_edge(clock) then
            status <= status_wire;
            
            if enable = '1' then
                status <= '1';
            else
                if mode = '1' then
                    if bit_ptr_wire = 30 then
                        status <= '0';
                    else
                        status <= status_wire;
                    end if;
                else
                    status <= '0';
                end if;
            end if;

        
        end if;
    end process;
    
    bit_pointer: process(clock, reset)
    begin
        if reset = '1' then
            bit_ptr <= 0;
        elsif rising_edge(clock) then
            
            if status = '1' and mode = '1' then
                if bit_ptr_wire < 30 and memory_busy = '0' then
                    bit_ptr <= bit_ptr_wire + 1;
                else
                    bit_ptr <= bit_ptr_wire;
                end if;
            else
                bit_ptr <= 0;
            end if;
        end if;
    end process bit_pointer;
---------------------------------------------------------------------------------------    
    x_counter_increment: process(clock, reset)
    begin
        if reset = '1' then
            x_counter <= 0;
        elsif rising_edge(clock) then
            x_counter <= x_counter_wire;
            
            if status = '1' then
            
                if bit_ptr_wire < 30 and memory_busy = '0' then
                    if x_counter_wire = 4 then
                        x_counter <= 0;
                    else
                        x_counter <= x_counter_wire + 1;
                    end if;
                end if;
                
            else
                x_counter <= 0;
            end if;
         end if;
    end process;    

    y_counter_increment: process(clock, reset)
    begin
        if reset = '1' then
            y_counter <= 0;
        elsif rising_edge(clock) then
            y_counter <= y_counter_wire;
            
            if status = '1' then
            
                if bit_ptr_wire < 30 and memory_busy = '0' then
                    if x_counter_wire = 4 then
                        if y_counter_wire = 5 then
                            y_counter <= 0;
                        else
                            y_counter <= y_counter_wire + 1;
                        end if;
                    end if;
                end if;
                
            else
                y_counter <= 0;
            end if;
         end if;
    end process;
--------------------------------------------------------------------

    output: process(clock, reset)
    begin
        if reset = '1' then
            memory_enable <= '0';
            data_out      <= (others => '0');
            address_out   <= (others => '0');
        elsif rising_edge(clock) then
            if mode = '1' then
                if bit_ptr_wire < 30 and status = '1' and memory_busy = '0' then
                    address_out <= std_logic_vector( 
                                      unsigned(address) 
                                    + to_unsigned(x_counter_wire, address_length) 
                                    + shift_left(to_unsigned(y_counter_wire, address_length), 6) 
                                    + shift_left(to_unsigned(y_counter_wire, address_length), 8));
                                    
                    if bit_map(to_integer(unsigned(char_wire)))(bit_ptr_wire) = '1' then
                        data_out      <= data;
                        memory_enable <= '1';
                    else
                        data_out      <= (others => '0');
                        memory_enable <= '0';
                    end if;
                else
                    data_out      <= (others => '0');
                    memory_enable <= '0';
                    address_out   <= (others => '0');
                end if;
                
            else
                if status = '1' then -- and memory_busy = '0' then
                    memory_enable <= '1';
                    data_out <= data;
                    address_out <= address;
                else
                    memory_enable <= '0';
                    data_out      <= (others => '0');
                    address_out   <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end Behavioral;
