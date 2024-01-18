library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity topper_level is
    Port (
        proc_in: in std_logic_vector(49 downto 0);
        clock, reset, enable_video: in std_logic;
        
        
        busy: out std_logic;
        
        blue_p, blue_n: out std_logic;
        red_p, red_n: out std_logic;
        green_p, green_n: out std_logic;
        clk_p, clk_n: out std_logic
     );
end topper_level;

architecture Behavioral of topper_level is
    signal pixel_clk, serial_clk, serial_clk_2: std_logic;
begin

    clk_gen: entity work.clock_gen
    port map(
        clk_in => clock,
        serial_clk => serial_clk,
        pixel_clk => pixel_clk,
        write_clk => serial_clk_2
    );

    com: entity work.top_level
    port map(
        data_in    => proc_in(23 downto 0),
        char_in    => proc_in(29 downto 24),
        mode       => proc_in(30),
        write      => proc_in(31),
        address_in => proc_in(48 downto 32),
        enable     => proc_in(49),
        
        busy => busy,
        enable_video => enable_video,
        reset => reset,
        pixel_clk => pixel_clk,
        serial_clk => serial_clk,
        serial_clk_2 => serial_clk_2,
        
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
