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
use ieee.STD_LOGIC_ARITH.all;

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

-- ANCIENNE METHODES
----declaration internal signals 
-- signal Etat_Present, Etat_Futur : Std_Logic_Vector(2 downto 0);
 
-- --Les constantes des états
-- --Etat start
-- constant Etat0_wait : Std_Logic_Vector(2 downto 0) := "000";
 
-- constant Etat1_init   : Std_Logic_Vector(2 downto 0) := "001";
-- constant Etat2_mul    : Std_Logic_Vector(2 downto 0) := "010";
-- constant Etat3_add    : Std_Logic_Vector(2 downto 0) := "011";
-- constant Etat4_if     : Std_Logic_Vector(2 downto 0) := "100";
-- constant Etat5_finish : Std_Logic_Vector(2 downto 0) := "101";

-- NOUVELLE METHODE
    type Etat is (idle, init, mul, add, test, finish );
	signal Etat_present, Etat_futur : Etat := idle;

	
	
	-- regsitres
    signal save_info 			       : std_logic := '0'; 
    signal c_real_reg		   	       : std_logic_vector (SIZE-1 downto 0);
    signal c_imaginary_reg			   : std_logic_vector (SIZE-1 downto 0);
    
    signal z_real_reg		   	       : std_logic_vector (SIZE-1 downto 0);
    signal z_imaginary_reg			   : std_logic_vector (SIZE-1 downto 0);
    signal iterations_reg			   : std_logic_vector (SIZE-1 downto 0);
    
    
    
    --signal z_real_fut_reg		   	       : std_logic_vector (SIZE-1 downto 0);
    --signal z_imaginary_fut_reg			   : std_logic_vector (SIZE-1 downto 0);
    
    signal z_real_carre		   	       : std_logic_vector ((SIZE*2)-1 downto 0);
    signal Z_re_Z_im_2		   	       : std_logic_vector ((SIZE*2) downto 0);
    signal Z_im_carre		   	       : std_logic_vector ((SIZE*2)-1 downto 0);
    
    signal D_s                          : std_logic_vector (SIZE-1 downto 0);
    
	
	
begin


-- Reset ou met à jour l'état présent
	Mem: process (clk, rst)
	begin
		if (rst = '1') then
			Etat_Present <= idle;
		elsif rising_edge(clk) then
			Etat_Present <= Etat_Futur;
		end if;
	end process;
	
	
-- Gestion des sorties en fonction de l'état présent
-- Gestion des états futurs en fonction des entrées (sauf etat 4)
Fut: 
process (start, Etat_Present)
	-- (idle, init, mul, add, test, finish )
	begin
	-- valeurs par défaut
		Etat_Futur <= idle;
		finished <= '0';
		ready <= '1';
		
		save_info <= '0';
		
		
		-- Besoin de
		--z_real <= (others => '0');
		--z_imaginary <= (others => '0');
		--iterations <= (others => '0');
		
		case Etat_Present is
		
		      when idle =>
                    finished <= '0';
                    ready <= '1';
    
                    if (start = '1') then
                        Etat_Futur <= init;
                    else 
                        Etat_Futur <= idle;
                    end if;
                    
                

            when init =>
                    finished <= '0';
                    ready <= '0';
                    
                    -- save data
                    save_info <= '1';
                    iterations_reg  <= (others => '0');
                    z_real_reg      <= (others => '0');
                    z_imaginary_reg <= (others => '0');
                
                    Etat_Futur <= mul;
                    
                    
            when mul =>
                    finished <= '0';
                    ready <= '0';
                    -- z_real_carre  Z_re_Z_im_2 Z_im_carre

                    
                    -- faire les multiplications
                    z_real_carre      <= signed(z_real_reg) * signed(z_real_reg);
                    -- p <= z_real_fut_reg(result_lowbit+result_width-1 downto result_lowbit) OR (SIZE downto 0);
                    
                  
                    Z_re_Z_im_2 <= (signed(z_real_reg) * signed(z_imaginary_reg)) & '0' ;
                    --Z_re_Z_im_2 <= Z_re_Z_im_2(SIZE downto 0) & '0';
                    
                    
                    Z_im_carre <= - (signed(z_imaginary_reg) * signed(z_real_reg));
                
                    Etat_Futur <= add;
                    
                    
              when add =>
                    finished <= '0';
                    ready <= '0';
                    
                    iterations_reg  <= unsigned(iterations_reg) + 1;
                    z_real_reg      <= conv_std_logic_vector((signed(z_real_carre) + signed(Z_re_Z_im_2) + signed(c_real_reg)), SIZE) ;
                    z_imaginary_reg <= conv_std_logic_vector(signed(Z_im_carre) + signed(c_imaginary_reg), SIZE);
                     
                    D_s             <= signed(z_real_reg) + signed(z_imaginary_reg);
                
                    Etat_Futur <= test;
                    
                    
                    
            when test =>
                    finished <= '0';
                    ready <= '0';

                
                    if (D_s >= "100") then
                        Etat_Futur <= finish;
                    else 
                        if (iterations_reg >= "1100100") then
                            iterations_reg <= (others => '0');
                            Etat_Futur <= finish;
                        else 
                            Etat_Futur <= mul;
                        end if;
                    end if;
                    
                    
                    
               when finish =>
                    finished <= '1';
                    ready <= '0';
                
                    Etat_Futur <= idle;
               
                    
                    
            when others =>
				Etat_Futur <= idle;
				finished <= '0';
                ready <= '1';
			end case ;
			
end process Fut;
		
		
-- Registre pour la lecture sychro
process(clk, rst)
begin
	if(rst = '1') then
		c_real_reg <= (others => '0');
		c_imaginary_reg <= (others => '0');
	elsif(rising_edge(Clk)) then
		if(save_info = '1') then
			c_real_reg <= c_real;
			c_imaginary_reg <= c_imaginary;
		end if;
	end if;
end process;

-- Registre l'ecriture sychro
process(clk, rst)
begin
	if(rst = '1') then
		iterations  <= (others => '0');
		z_real      <= (others => '0');
		z_imaginary <= (others => '0');
	elsif(rising_edge(Clk)) then
		iterations    <= iterations_reg;
		z_real        <= z_real_reg;
		z_imaginary   <= z_imaginary_reg;
	end if;
end process;




end Behavioral;
