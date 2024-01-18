----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2023 11:49:39 PM
-- Design Name: 
-- Module Name: Encoder - Behavioral
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

entity Encoder is
    Port(
     
        clock, reset, enable: in std_logic;
        
        data: in std_logic_vector(7 downto 0);
        control: in std_logic_vector(1 downto 0);
        
        -- simulation outputs
        q_m_sim, q_m_2_sim: out std_logic_vector(8 downto 0);
        n_ones_data_sim: out std_logic_vector(3 downto 0);
        disparity_sim: out std_logic_vector(3 downto 0);
        diff_sim: out std_logic_vector(3 downto 0);
        
        dout: out std_logic_vector(9 downto 0)

    );
end Encoder;

architecture Behavioral of Encoder is
    signal XOR_data, XOR_wire: std_logic_vector(8 downto 0);
    signal XNOR_data, XNOR_wire: std_logic_vector(8 downto 0);
    
    signal q_m, q_m_wire: std_logic_vector(8 downto 0);     -- intermediate encoded data
    signal q_m_2, q_m_2_wire: std_logic_vector(8 downto 0):= (others => '0');  -- pipeline stage
    
    signal enable_1, enable_2, enable_3: std_logic:= '0';       -- pipeline stages for enable
    signal enable_1_wire, enable_2_wire, enable_3_wire, enable_4_wire: std_logic;
    
    signal n_ones_data, n_ones_data_wire: integer range 0 to 8;
    
    signal disparity, disparity_wire: signed(3 downto 0):= to_signed(0, 4);
    signal diff, diff_wire: signed(3 downto 0):= to_signed(0, 4);
    
    signal data_out, data_out_wire: std_logic_vector(9 downto 0):= (others => '0');
    
    signal control_1, control_1_wire, control_2, control_2_wire, control_3, control_3_wire: std_logic_vector(1 downto 0);  -- pipeline for control signals
begin

    -- simulation
    q_m_sim <= q_m_wire;
    q_m_2_sim <= q_m_2;
    disparity_sim <= std_logic_vector(disparity);
    n_ones_data_sim <= std_logic_vector(to_signed(n_ones_data, 4));
    diff_sim <= std_logic_vector(diff);

    control_3_wire <= control_3;
    control_2_wire <= control_2;
    control_1_wire <= control_1;

    XOR_wire   <= XOR_data;
    XNOR_wire  <= XNOR_data;
    q_m_wire   <= q_m;
    q_m_2_wire <= q_m_2;
    
    n_ones_data_wire <= n_ones_data;
    
    enable_1_wire <= enable_1;
    enable_2_wire <= enable_2;
    enable_3_wire <= enable_3;
    
    disparity_wire <= disparity;
    diff_wire      <= diff;
    
    data_out_wire <= data_out;
    dout          <= data_out;
    
    output: process(clock, reset)
    begin
        if reset = '1' then
            disparity <= (others => '0');
            data_out  <= (others => '0');
        elsif rising_edge(clock) then
            if enable_3 = '0' then
            
                case control_3 is
                    when "00"   => data_out <= "1101010100";
                    when "01"   => data_out <= "0010101011";
                    when "10"   => data_out <= "0101010100";
                    when others => data_out <= "1010101011";
                end case;
                
                disparity <= (others => '0');
            
            elsif disparity = 0 or diff = 0 then 
                
                data_out(9) <= not q_m_2(8);
                data_out(8) <= q_m_2(8);
                
                if q_m_2(8) = '0' then
                    data_out(7 downto 0) <= not q_m_2(7 downto 0);
                    disparity <= disparity_wire - diff;
                else
                    data_out(7 downto 0) <= q_m_2(7 downto 0);
                    disparity <= disparity_wire + diff;
                end if;
            
            elsif (diff(diff'left) = '0' and disparity(disparity'left) = '0') or (diff(diff'left) = '1' and disparity(disparity'left) = '1') then
                
                data_out(9) <= '1';
                data_out(8) <= q_m_2(8);
                data_out(7 downto 0) <= not q_m_2(7 downto 0);
                
                if q_m_2(8) = '1' then
                    disparity <= disparity + 2 - diff;
                else
                    disparity <= disparity - diff;
                end if;
        
            else
                
                data_out <= '0' & q_m_2(8 downto 0);
                 
                if q_m_2(8) = '1' then
                    disparity <= disparity + diff;
                else
                    disparity <= disparity - 2 + diff;
                end if;    
            end if;
        end if;
    end process;
    
    encoding_choose: process(clock, reset)
    begin
        if reset = '1' then
            q_m <= (others => '0');
        elsif rising_edge(clock) then
            if enable_1 = '1' then
            
                if n_ones_data > 4 or (n_ones_data = 4 and data(0) = '0') then
                    q_m <= XNOR_data;
                else
                    q_m <= XOR_data;
                end if;
                
            else
                q_m <= (others => '0');
            end if;
        end if;
    end process;
    


--------------------------------------------------------
    enable_stage_1: process(reset, clock)
    begin
        if reset = '1' then
            enable_1 <= '0';
        elsif rising_edge(clock) then
            control_1 <= control;
            
            if enable = '1' then
                enable_1 <= '1';
            else
                enable_1 <= '0';
            end if;
        end if;
    end process; 
    
    enable_stage_2: process(reset, clock)
    begin
        if reset = '1' then
            enable_2 <= '0';
        elsif rising_edge(clock) then
            control_2 <= control_1_wire;
            
            if enable_1 = '1' then
                enable_2 <= '1';
            else
                enable_2 <= '0';
            end if;
        end if;
    end process;

    enable_stage_3: process(reset, clock)
    begin
        if reset = '1' then
            enable_3 <= '0';
            q_m_2 <= (others => '0');
        elsif rising_edge(clock) then
            control_3 <= control_2_wire;
            if enable_2 = '1' then
                enable_3 <= '1';
                q_m_2 <= q_m_wire;
            else
                enable_3 <= '0';
                q_m_2 <= (others => '0');
            end if;
        end if;
    end process;
    
--    enable_stage_4: process(reset, clock)
--    begin
--        if reset = '1' then
--            enable_4 <= '0';
--        elsif rising_edge(clock) then
            
--            if enable_3 = '1' then
--                enable_4 <= '1';
--            else
--                enable_4 <= '0';
--            end if;
--        end if;
--    end process;
--------------------------------------------------------------

                XNOR_data(0) <= data(0);               
                xnor_encoding:for i in 1 to 7 generate
                begin
                    XNOR_data(i) <= data(i) XNOR XNOR_data(i-1);
                end generate;               
                XNOR_data(8) <= '0';
                
                
                XOR_data(0) <= data(0);               
                xor_encoding:for i in 1 to 7 generate
                begin
                    XOR_data(i) <= data(i) XOR XOR_data(i-1);
                end generate;               
                XOR_data(8) <= '1';
                
                
--    xor_encode: process(clock, reset)
--    begin
--        if reset = '1' then
--            XOR_data <= (others => '0');
--        elsif rising_edge(clock) then
--            XOR_data <= XOR_wire;
            
--            if enable = '1' then
            
--                XOR_data(0) <= data(0);
                
--                for i in 1 to 7 loop
--                    XOR_data(i) <= data(i) XOR XOR_data(i-1);
--                end loop;
                
--                XOR_data(8) <= '1';
--            end if;
--        end if;
--    end process;
    
--    xnor_encode: process(clock, reset)
--    begin
--        if reset = '1' then
--            XNOR_data <= (others => '0');
--        elsif rising_edge(clock) then
--            XNOR_data <= XNOR_wire;
            
--            if enable = '1' then
            
--                XNOR_data(0) <= data(0);
                
--                for i in 1 to 7 loop
--                    XNOR_data(i) <= data(i) XNOR XNOR_data(i-1);
--                end loop;
                
--                XNOR_data(8) <= '0';
--            end if;
--        end if;
--    end process;
    
    ones_counting_data: process(clock, reset) is
        variable c : integer range 0 to 8;
    begin
        if reset = '1' then
            c := 0;
            n_ones_data <= 0;
        elsif rising_edge(clock) then
            n_ones_data <= n_ones_data_wire;
            c := 0;
            
            if enable = '1' then
                for i in 0 to 7 loop
                    if data(i) = '1' then
                        c := c + 1;
                    end if;
                end loop;
                n_ones_data <= c;
            end if;
        end if;
    end process;
    
    ones_counting_q_m: process(clock, reset)
        variable c : integer range 0 to 8;
    begin
        if reset = '1' then
            c := 0;
            diff <= to_signed(0, 4);
        elsif rising_edge(clock) then
            diff <= diff_wire;
            c := 0;
            
            if enable_2 = '1' then
                for i in 0 to 7 loop
                    if q_m(i) = '1' then
                        c := c + 1;
                    end if;
                end loop;
                diff <= to_signed(2*c - 8, 4);
            end if;
        end if;
    end process;


end Behavioral;