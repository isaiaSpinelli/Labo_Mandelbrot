----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.04.2021 20:22:19
-- Design Name: 
-- Module Name: mandelbrot_calculator - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mandelbrot_calculator is
generic (   comma       : integer := 12; -- nombre de bits après la virgule
            max_iter    : integer := 100;
            SIZE        : integer := 16);
            
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           ready : out STD_LOGIC;
           start : in STD_LOGIC;
           finished : out STD_LOGIC;
           c_real : in STD_LOGIC_VECTOR (SIZE-1 downto 0);
           c_imaginary : in STD_LOGIC_VECTOR (SIZE-1 downto 0);
           z_real : out STD_LOGIC_VECTOR (SIZE-1 downto 0);
           z_imaginary : out STD_LOGIC_VECTOR (SIZE-1 downto 0);
           iterations : out STD_LOGIC_VECTOR (SIZE-1 downto 0));
end mandelbrot_calculator;

architecture Behavioral of mandelbrot_calculator is

begin


end Behavioral;
