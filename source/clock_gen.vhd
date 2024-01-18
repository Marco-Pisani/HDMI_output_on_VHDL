----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2023 02:28:48 PM
-- Design Name: 
-- Module Name: clock_gen - Behavioral
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

entity clock_gen is
    generic(
        CLK_IN_PERIOD    :   real   := 8.000;   --input period
        CLK_MULTIPLY_ALL :   integer:= 8;       --multiplies all
        CLK_DIVIDE_ALL   :   integer:= 1;       --divides all
        
        CLK_OUT_0_DIVIDE :   integer:= 40;      --pixel_clk
        CLK_OUT_1_DIVIDE :   integer:= 4;       --serial_clk
        CLK_OUT_2_DIVIDE :   integer:= 5        --write_clock
    );

    Port ( 
        clk_in: in std_logic;
        
        pixel_clk, serial_clk, write_clk: out std_logic
    );
end clock_gen;

architecture Behavioral of clock_gen is
    signal pixel_clk_sig, serial_clk_sig, write_clk_sig: std_logic;
    signal feedback_sig: std_logic;
begin

    clk0buf: BUFG port map (I=>pixel_clk_sig, O=>pixel_clk);
    clk1buf: BUFG port map (I=>serial_clk_sig, O=>serial_clk);
    clk2buf: BUFG port map (I=>write_clk_sig, O=>write_clk);

    clock: PLLE2_BASE generic map (
        clkin1_period  => CLK_IN_PERIOD,
        clkfbout_mult  => CLK_MULTIPLY_ALL,
        clkout0_divide => CLK_OUT_0_DIVIDE,
        clkout1_divide => CLK_OUT_1_DIVIDE,
        clkout2_divide => CLK_OUT_2_DIVIDE,
        divclk_divide  => CLK_DIVIDE_ALL
    )
    port map(
        rst      => '0',
        pwrdwn   => '0',
        clkin1   => clk_in,
        clkfbin  => feedback_sig,
        clkfbout => feedback_sig,
        clkout0  => pixel_clk_sig,
        clkout1  => serial_clk_sig,
        clkout2  => write_clk_sig
    );

end Behavioral;
