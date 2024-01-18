----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2023 07:40:33 PM
-- Design Name: 
-- Module Name: signals_timings - Behavioral
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

entity signals_timings is
    Port( 
        clk, enable, reset: in std_logic;
        data_in: in std_logic_vector(23 downto 0);
        
        -- simulation
--        y_out, x_out: out std_logic;
--        x_counter_out, y_counter_out, h_out, v_out: out integer;
        
        memory_enable: out std_logic;
        address: out std_logic_vector(16 downto 0);     -- 240x320 = 76800 pixels
        
        red, green, blue: out std_logic_vector(7 downto 0);
        Hsync, Vsync: out std_logic

    );
end signals_timings;

architecture Behavioral of signals_timings is
    constant H_visible: integer := 640;
    constant H_front  : integer := 16;
    constant H_pulse  : integer := 96;
    constant H_back   : integer := 48;
        
    constant V_visible: integer := 480;
    constant V_front  : integer := 10;
    constant V_pulse  : integer := 2;
    constant V_back   : integer := 33;
        
    constant address_length: integer := 17;

    constant h_range : integer := (H_visible + H_front + H_pulse + H_back - 1);
    constant v_range : integer := (V_visible + V_front + V_pulse + V_back - 1);
---------------------------------------------------------------------------------------
    signal h_counter, h_counter_wire: integer range 0 to 1000;--h_range;
    signal v_counter, v_counter_wire: integer range 0 to 1000;--v_range;
    
    signal x_counter, x_wire: integer range 0 to (H_visible - 1);
    signal y_counter, y_wire: integer range 0 to (V_visible - 1); 
    
    signal data, data_wire: std_logic_vector(23 downto 0):= (others => '0');
    signal data_aux, data_aux_wire: unsigned(23 downto 0);
    signal c, c_wire: integer range 0 to 10;

    signal x, x_w, y, y_w: std_logic;     -- to count only half lines
begin
    data_wire <= data;
    data_aux_wire <= data_aux;
    c_wire <= c;
    
    x_w <= x;
    y_w <= y;

    h_counter_wire <= h_counter;
    v_counter_wire <= v_counter;
    
    x_wire <= x_counter;
    y_wire <= y_counter;
    
    red   <= data(7 downto 0);
    green <= data(15 downto 8);
    blue  <= data(23 downto 16);
 
    --simulation
--    y_out <= y;
--    x_out <= x;
--    x_counter_out <= x_counter;
--    y_counter_out <= y_counter;
--    h_out <= h_counter;
--    v_out <= v_counter;
 
    memory_interface: process(clk, reset)
    begin
        if reset = '1' then
            address <= (others => '0');
            memory_enable <= '0';
        elsif rising_edge(clk) then
--            if enable = '1' and ((h_counter < H_visible + H_back and h_counter > H_back) and (v_counter < V_visible + V_back and v_counter >= V_back)) then
            if enable = '1' and ((h_counter < H_visible and h_counter >= 0) and (v_counter < V_visible and v_counter >= 0)) then
                address <= std_logic_vector( to_unsigned(x_wire, address_length) + shift_left(to_unsigned(y_wire, address_length), 6) + shift_left(to_unsigned(y_wire, address_length), 8) );
                memory_enable <= '1';
            else
                address <= (others => '0');
                memory_enable <= '0';
            end if;
        end if;
    end process;
 
--------------------------------------------------------
    adddress_y: process(clk, reset)
    begin
        if reset = '1' then
            y_counter <= 0;
        elsif rising_edge(clk) then
--            if enable = '1' and (v_counter < V_visible + V_back and v_counter >= V_back) then       
            if enable = '1' and (v_counter < V_visible and v_counter >= 0) then       
--                if h_counter = H_visible + H_back and y_w = '1' then                    
                if h_counter = H_visible and y_w = '1' then                    
--                    if y_wire = (V_visible + V_back - 1) then
                    if y_wire = (V_visible - 1) then
                        y_counter <= 0;
                    else
                        y_counter <= y_wire + 1;
                    end if;                   
                else
                    y_counter <= y_wire;
                end if;             
            else
                y_counter <= 0;
            end if;
        end if;
    end process;
    
    process(clk, reset)
    begin
        if reset = '1' then
            y <= '0';
        elsif rising_edge(clk) then
            if enable = '1' or v_counter = v_range then           
--                if h_counter = H_visible + H_back then                   
                if h_counter = H_visible then                   
                    if y_w = '1' then
                        y <= '0';
                    else
                        y <= '1';
                    end if;                   
                else
                    y <= y_w;
                end if;               
            else
                y <= '0';
            end if;
        end if;
    end process;
 
    adddress_x: process(clk, reset)
    begin
        if reset = '1' then
            x_counter <= 0;
        elsif rising_edge(clk) then
            if enable = '1' then
--                if ((h_counter < H_visible + H_back and h_counter > H_back) and (v_counter < V_visible + V_back and v_counter >= V_back)) then
                if ((h_counter < H_visible and h_counter >= 0) and (v_counter < V_visible and v_counter >= 0)) then
                    if x_w = '1' then                           -- increases every 2 pixels
                        if x_wire = (H_visible - 1) then        
                            x_counter <= 0;
                        else
                            x_counter <= x_wire + 1;
                        end if;
                    else
                        x_counter <= x_wire;
                    end if;
                else
                    x_counter <= 0;
                end if;
            else
                x_counter <= 0;
            end if;
        end if;
    end process;
    
    
    process(clk, reset)
    begin
        if reset = '1' then
            x <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
--                if ((h_counter < H_visible + H_back and h_counter >= H_back) and (v_counter < V_visible + V_back and v_counter >= V_back)) then
                if ((h_counter < H_visible and h_counter >= 0) and (v_counter < V_visible and v_counter >= 0)) then
                    if x_w = '1' then           --x changes every cycles
                        x <= '0';
                    else
                        x <= '1';
                    end if;
                else
                    x <= '0';
                end if;
            else
                x <= '0';
            end if; 
        end if;
    end process;
----------------------------------------------
    RGB: process(clk, reset)
    begin
        if reset = '1' then
            data <= x"000000";
            c <= 0;
            data_aux <= x"101010";
        elsif rising_edge(clk) then
--            if enable = '1' and ((h_counter < H_visible + H_back and h_counter >= H_back) and (v_counter < V_visible + V_back and v_counter >= V_back)) then
            if enable = '1' and ((h_counter < H_visible and h_counter >= 0) and (v_counter < V_visible and v_counter >= 0)) then
                data <= data_in;
--                data <= std_logic_vector(data_aux);
--            if v_counter > V_back + 10 and v_counter < V_back + 470 then --????????????????????
--            if H_counter > H_back + 90 and H_counter < H_back + 200 then
--                data <= x"A01050";
--            else
--                data <= x"105050";
--            end if;
--                if c = 9 then
--                    c <= 0;
--                    data_aux <= data_aux_wire + 1;
--                else
--                    c <= c_wire + 1;
--                    if h_counter = H_back then
--                        data_aux <= data_aux_wire + x"000100";
--                    else
--                        data_aux <= data_aux_wire;
--                    end if;
--                end if;
                
                
            else
                data <= x"000000";

--                data_aux(23 downto 8) <= data_aux_wire(23 downto 8);
--                data_aux(7 downto 0) <= x"10"; 
--                c <= 0;
            end if;
        end if;
    end process;


 ------------------------------------------------------------  
 
 -------------------------------------------------   
    hsync_signal:process(clk, reset)
    begin
        if reset = '1' then    
            Hsync <= '0';
        elsif rising_edge(clk) then
--            if (h_counter >= (H_visible + H_front + H_back)) and (h_counter < (H_visible + H_front + H_pulse + H_back)) then
            if (h_counter >= (H_visible + H_front)) and (h_counter < (H_visible + H_front + H_pulse)) then
                Hsync <= '0';
            else
                Hsync <= '1';
            end if;
        end if;
    end process;
    
    vsync_signal:process(clk, reset)
    begin
        if reset = '1' then    
            Vsync <= '0';
        elsif rising_edge(clk) then
--            if (V_counter >= (V_visible + V_front + V_back)) and (v_counter < (V_visible + V_front + V_pulse + V_back)) then
            if (V_counter >= (V_visible + V_front)) and (v_counter < (V_visible + V_front + V_pulse)) then
                Vsync <= '0';
            else
                Vsync <= '1';
            end if;
        end if;
    end process;
-----------------------------------------------------------------    
    counters: process(clk, reset)
    begin
        if reset = '1' then
            h_counter <= 0;
            v_counter <= 0;
        elsif rising_edge(clk) then
            h_counter <= h_counter_wire;
            
            if enable = '1' then
                if h_counter = h_range then
                
                    h_counter <= 0;
                    
                    if v_counter = v_range then
                        v_counter <= 0;
                    else
                        v_counter <= v_counter_wire + 1;
                    end if;
                    
                else
                    h_counter <= h_counter_wire + 1;
                    v_counter <= v_counter_wire;
                end if;
            else
                h_counter <= 0;
                v_counter <= 0;
            end if;
        end if;
    end process;

end Behavioral;
