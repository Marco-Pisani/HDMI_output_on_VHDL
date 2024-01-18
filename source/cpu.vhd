

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpu is
    Port (
        data: out std_logic_vector(23 downto 0);
        address: out std_logic_vector(16 downto 0);
        char: out std_logic_vector(5 downto 0);
        
        enable, write, mode: out std_logic;
        
        start, clock, reset: in std_logic
     );
end cpu;

architecture Behavioral of cpu is

    signal counter, counter_wire, counter_2, counter_wire_2: integer range 0 to 80000;
    signal data_reg, data_wire: unsigned(23 downto 0);
    signal address_reg, address_wire: unsigned(16 downto 0);
    signal char_reg, char_wire: unsigned(5 downto 0);
    
begin

    counter_wire <= counter;
    counter_wire_2 <= counter_2;
    char_wire <= char_reg;
    address_wire <= address_reg;
    data_wire <= data_reg;
    
    data <= std_logic_vector(data_reg);
    address <= std_logic_vector(address_reg);
    char <= std_logic_vector(char_reg);
      
    process(clock, reset)
    begin
    
        if reset = '1' then
            counter_2 <= 0;
            counter <= 0;
            data_reg <= (others => '0');
            address_reg <= (others => '0');
            char_reg <= (others => '0');
            mode <= '0';
            write <= '0';
            enable <= '0';
            
        elsif rising_edge(clock) then
            
            if start = '1' then
            
                mode <= '1';
                enable <= '1';
                write <= '1';
                
--                if data_wire = x"1010DD" then
--                    data_reg <= x"10DD10";
--                else
--                    data_reg <= x"1010DD";
--                end if;
                
                data_reg <= x"10A010";-- + counter_wire_2;
                address_reg <= "00111110101100100" + 180;-- + counter_wire;
                char_reg <= "010100";-- + counter_wire;
                
                if counter = 76799 then
                    counter <= 0;
                    counter_2 <= 0;
                else
                    counter <= counter_wire + 1;
                    
                    if counter_2 = 100 then
                        counter_2 <= 0;
                    else
                        counter_2 <= counter_wire_2 + 1;                       
                    end if;
                    
                end if;
              
            else
            
                data_reg <= (others => '0');
                address_reg <= (others => '0');
                char_reg <= (others => '0');
                mode <= '0';
                write <= '0';
                enable <= '0';
                counter_2 <= 0;
                counter <= 0;
                
            end if;
        end if;
    end process;
    
end Behavioral;
