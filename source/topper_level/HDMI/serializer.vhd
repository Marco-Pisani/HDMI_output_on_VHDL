----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2023 11:37:55 PM
-- Design Name: 
-- Module Name: serializer - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity serializer is
    Port ( 
        data_clk, fast_clk, reset, enable: in std_logic;        
        data_in: in std_logic_vector(9 downto 0);
        out_p, out_n: out std_logic
    );
end serializer;

architecture Behavioral of serializer is
    signal index, index_wire: unsigned(3 downto 0);
    
    signal data_reg, data_reg_wire: std_logic_vector(9 downto 0);
    signal data_out: std_logic;
begin

    index_wire    <= index;    
    data_reg_wire <= data_reg;
    
    -- differential output
    obuf : OBUFDS
    generic map (IOSTANDARD =>"TMDS_33")
    port map (I=>data_out, O=>out_p, OB=>out_n);

    read: process(reset, data_clk)
    begin
        if reset = '1' then
            data_reg <= (others => '0');
            
        elsif rising_edge(data_clk) then       
            data_reg <= data_reg_wire;
            
            if enable = '1' then
                data_reg <= data_in;
            end if;
        end if;
    end process;
    
    index_increment: process(reset, fast_clk)
    begin
        if reset = '1' then
            index <= (others => '0');
            data_out <= '0';
            
        elsif rising_edge(fast_clk) then
            data_out <= data_reg(to_integer(index_wire));
                
            if index_wire = 9 then    
                index <= (others => '0');
            else    
                index <= index_wire + 1;
            end if;

        end if;
    end process;
    


end Behavioral;
