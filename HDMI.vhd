


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity HDMI is
    Port (
        enable, pixel_clk, serial_clk, reset: in std_logic;
        data_in: in std_logic_vector(23 downto 0);
        
        memory_enable: out std_logic;
        address: out std_logic_vector(16 downto 0);
        
        blue_p, blue_n: out std_logic;
        red_p, red_n: out std_logic;
        green_p, green_n: out std_logic;
        clk_p, clk_n: out std_logic
        
     );
end HDMI;

architecture Behavioral of HDMI is

    signal red, green, blue: std_logic_vector(7 downto 0);
    signal Hsync, Vsync: std_logic;
    
    signal memory_en: std_logic;
    
    signal red_encoded, green_encoded, blue_encoded: std_logic_vector(9 downto 0);
begin

    memory_enable <= memory_en;

    timings: entity work.signals_timings
        port map(
            clk => pixel_clk,
            enable => enable,
            reset => reset,
            data_in => data_in,
            memory_enable => memory_en,
            address => address,
            red => red,
            green => green,
            blue => blue,
            Hsync => Hsync,
            Vsync => Vsync
        );
        
        
        -- encoders
--------------------------------------------------------------
    blue_encoder: entity work.Encoder       -- with Hsync and Vsync
        port map(
            clock => pixel_clk,
            enable => memory_en,
            reset => reset,
            data => blue,
            control(0) => Hsync,
            control(1) => Vsync,
            dout => blue_encoded
        );
        
    green_encoder: entity work.Encoder
        port map(
            clock => pixel_clk,
            enable => memory_en,
            reset => reset,
            data => green,
            control(0) => '0',      -- CTL0
            control(1) => '0',      -- CTL1
            dout => green_encoded
        );

    red_encoder: entity work.Encoder
        port map(
            clock => pixel_clk,
            enable => memory_en,
            reset => reset,
            data => red,
            control(0) => '0',      -- CTL2
            control(1) => '0',      -- CTL3
            dout => red_encoded
        );

        -- serializers
----------------------------------------------------------------------
    blue_serializer: entity work.serializer
        port map(
            data_clk => pixel_clk,
            fast_clk => serial_clk,
            enable => enable,
            reset => reset,
            data_in => blue_encoded,
            out_p => blue_p,
            out_n => blue_n
        );
        
    green_serializer: entity work.serializer
        port map(
            data_clk => pixel_clk,
            fast_clk => serial_clk,
            enable => enable,
            reset => reset,
            data_in => green_encoded,
            out_p => green_p,
            out_n => green_n
        );
        
    red_serializer: entity work.serializer
        port map(
            data_clk => pixel_clk,
            fast_clk => serial_clk,
            enable => enable,
            reset => reset,
            data_in => red_encoded,
            out_p => red_p,
            out_n => red_n
        );
        
    clock_serializer: entity work.serializer        -- to have the same delay
        port map(
            data_clk => pixel_clk,
            fast_clk => serial_clk,
            enable => enable,
            reset => reset,
            data_in => "0000011111",
            out_p => clk_p,
            out_n => clk_n
        );
end Behavioral;
