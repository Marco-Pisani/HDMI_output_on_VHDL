----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2023 10:52:40 PM
-- Design Name: 
-- Module Name: memory - Behavioral
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

entity memory is
    Port (
        clock_w, enable_w, clock_r, enable_r: in std_logic;
        
        address_w, address_r: in std_logic_vector(16 downto 0);
        
        data_w: in std_logic_vector(23 downto 0);
        data_r: out std_logic_vector(23 downto 0)
     );
end memory;

architecture Behavioral of memory is

    type mem_type is array (76799 downto 0) of std_logic_vector(23 downto 0);
    signal RAM: mem_type:=(others => x"101010");
    
begin
    
    write: process(clock_w)
    begin
        if rising_edge(clock_w) then
            if enable_w = '1' then
                RAM(to_integer(unsigned(address_w))) <= data_w;
            end if;
        end if;
    end process;    

    read: process(clock_r)
    begin
        if rising_edge(clock_r) then
            if enable_r = '1' then
                data_r <= RAM(to_integer(unsigned(address_r)));
            end if;
        end if;
    end process;

end Behavioral;
