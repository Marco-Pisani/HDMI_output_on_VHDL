


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top_level is
   Port (
       data_in: in std_logic_vector(23 downto 0);
       address_in: in std_logic_vector(16 downto 0);
       char_in: in std_logic_vector(5 downto 0);
       
       enable, enable_video, write, mode, reset: in std_logic;
       pixel_clk, serial_clk, serial_clk_2: in std_logic;
       
       busy: out std_logic;
       
       blue_p, blue_n: out std_logic;
       red_p, red_n: out std_logic;
       green_p, green_n: out std_logic;
       clk_p, clk_n: out std_logic
   );
end top_level;

architecture Behavioral of top_level is

    signal memory_enable_letter: std_logic;
    signal address_w: std_logic_vector(16 downto 0);
    signal data_w: std_logic_vector(23 downto 0);
    signal enable_r: std_logic;
    signal data_r: std_logic_vector(23 downto 0);
    signal address_r: std_logic_vector(16 downto 0);
begin
        
    lett: entity work.letter
        port map(
            address_in => address_in,
            data_in    => data_in,
            char_in    => char_in,
            reset      => reset,
            clock      => serial_clk_2,
            write      => write,
            enable     => enable,
            mode       => mode,
            memory_enable => memory_enable_letter,
            memory_busy   => enable_r,
            busy          => busy,
            address_out   => address_w,
            data_out      => data_w
        );


    mem: entity work.memory
        port map(
            clock_w => serial_clk_2,
            enable_w => memory_enable_letter,
            address_w => address_w,
            data_w => data_w,
            clock_r => pixel_clk,
            enable_r => enable_r,
            data_r => data_r,
            address_r => address_r
        );
        
    HDMI: entity work.HDMI
        port map(
            enable => enable_video,
            data_in => data_r,
            pixel_clk => pixel_clk,
            serial_clk => serial_clk,
            reset => reset,
            address => address_r,
            memory_enable => enable_r,
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
