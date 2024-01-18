


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_test is
    Port (
        start, reset, enable_video: in std_logic;
        
        clock: in std_logic;
       
        blue_p, blue_n: out std_logic;
        red_p, red_n: out std_logic;
        green_p, green_n: out std_logic;
        clk_p, clk_n: out std_logic
     );
end cpu_test;

architecture Behavioral of cpu_test is

    signal data: std_logic_vector(23 downto 0);
    signal address: std_logic_vector(16 downto 0);
    signal char: std_logic_vector(5 downto 0);
        
    signal enable, write, mode: std_logic;
    
    signal pixel_clk, serial_clk, serial_clk_2: std_logic;
    
begin

    clk_gen: entity work.clock_gen
    port map(
        clk_in => clock,
        serial_clk => serial_clk,
        pixel_clk => pixel_clk,
        write_clk => serial_clk_2
    );

    test: entity work.cpu
    port map(
        enable => enable,
        write => write,
        mode => mode,
        data => data,
        address => address,
        char => char,
        start => start,
        clock => pixel_clk,
        reset => reset
    );

    TOP_LEVEL_inst: entity work.top_level
    port map(
        data_in => data,
        address_in => address,
        char_in => char,
        enable => enable,
        enable_video => enable_video,
        reset => reset,
        
        pixel_clk => pixel_clk,
        serial_clk => serial_clk,
        serial_clk_2 => serial_clk_2,
        
        write => write,
        mode => mode,
        blue_p => blue_p,
        blue_n => blue_n,
        red_p => red_p,
        red_n => red_n,
        green_p => green_p,
        green_n => green_n,
        clk_p => clk_p,
        clk_n => clk_n
    );

end Behavioral;
