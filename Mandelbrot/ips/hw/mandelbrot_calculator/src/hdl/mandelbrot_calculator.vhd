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
-- use ieee.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;

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

	--  Constants  
	constant DOUBLE_SIZE : integer := 2*SIZE;
	constant COMMA_HIGH  : integer := (SIZE+comma-1);
	-- Valeur limite pour la comparaison (2^2 = 4)
	constant val_limite : std_logic_vector(DOUBLE_SIZE-1 downto 0) := "00000100" & "000000000000000000000000";
	
	type Etat is (idle, calcul );
	signal Etat_present, Etat_futur : Etat := idle;

	
	signal ready_reg                   : std_logic := '1'; 
	signal finished_reg		           : std_logic := '0';
	
	
	signal iterations_count_next	   : unsigned (SIZE-1 downto 0) := (others => '0');
    signal iterations_count		       : unsigned (SIZE-1 downto 0) := (others => '0');




	signal start_s			: std_logic;
	signal z_real_s			: std_logic_vector(SIZE-1 downto 0);
	signal z_imaginary_s	: std_logic_vector(SIZE-1 downto 0);


	-- Signaux intermediaires pour les calculs
	signal z_real2_s				: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_imaginary2_s			: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real_x_imaginary_s		: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_2_real_x_imaginary_s	: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real2_sub_imaginary2_s	: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real2_add_imaginary2_s	: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_real_fut_s				: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_imaginary_fut_s		: std_logic_vector(DOUBLE_SIZE-1 downto 0);

	-- Signaux pour de sorties des bascules
	signal z_new_real_s				: std_logic_vector(SIZE-1 downto 0);
	signal z_new_imaginary_s		: std_logic_vector(SIZE-1 downto 0);

	-- Signaux de controle
	signal calcul_en: std_logic;
	signal calcul_rst: std_logic;

	-- Signaux pour la machine d'etat
	signal EtatPresent: std_logic;
	signal EtatFutur: std_logic;

-------------
--	Begin  --
-------------
begin

	z_real 		<= z_real_s;
	z_imaginary <= z_imaginary_s;
	

combinatoire :
process( all )
-- c_real, c_imaginary, z_new_real_s, z_new_imaginary_s, z_real_s, z_imaginary_s, z_real_x_imaginary_s, z_real2_s, z_imaginary2_s, z_2_real_x_imaginary_s, z_real2_add_imaginary2_s, iterations_count, calcul_en, z_real2_sub_imaginary2_s
	begin
		--  Multiplexeur  --
		z_real_s 		<= z_new_real_s;
		z_imaginary_s 	<= z_new_imaginary_s;

		--  Multiplicateurs  --
		z_real2_s				<= std_logic_vector(signed(z_real_s) * signed(z_real_s));				-- ZR^2
		z_imaginary2_s			<= std_logic_vector(signed(z_imaginary_s) * signed(z_imaginary_s));		-- ZI^2
		z_real_x_imaginary_s	<= std_logic_vector(signed(z_real_s) * signed(z_imaginary_s));			-- ZR*ZI
		z_2_real_x_imaginary_s	<= std_logic_vector(z_real_x_imaginary_s(DOUBLE_SIZE-2 downto 0) & '0');-- 2*ZR*ZI

		--  Additionneurs - Soustracteurs  --
		z_real2_sub_imaginary2_s 	<= std_logic_vector(signed(z_real2_s) - signed(z_imaginary2_s));	-- ZR^2-ZI^2
		z_real2_add_imaginary2_s 	<= std_logic_vector(signed(z_real2_s) + signed(z_imaginary2_s));	-- ZR^2+ZI^2
		z_real_fut_s				<= std_logic_vector(signed(z_real2_sub_imaginary2_s) + signed(c_real & "000000000000"));
		z_imaginary_fut_s			<= std_logic_vector(signed(z_2_real_x_imaginary_s) + signed(c_imaginary & "000000000000"));
		--iterations_count_next			<= std_logic_vector(signed(iterations_count) + 1);

		--  Comparateurs  --
		-- Valeurs plus grande que 2^2
		if(unsigned(z_real2_add_imaginary2_s) > unsigned(val_limite)) then
			finished_reg 	<= '1';
		-- Fin des iterations
		elsif(unsigned(iterations_count) >= max_iter) then
			finished_reg 	<= '1';
		else
			finished_reg	<= '0';
		end if;
	end process;
	
	
ready       <= ready_reg;
finished	<= finished_reg;

-- Reset ou met à jour l'état présent
	Mem: process (clk, rst)
	begin
		if (rst = '1') then
			Etat_present <= idle;
		elsif rising_edge(clk) then
			Etat_present <= Etat_Futur ;
		end if;
	end process;

Fut:
process(all) -- Etat_present, start, finished_reg, z_real_s, z_imaginary_s, iterations_count

	begin
		-- valeurs par défaut
		Etat_futur        <= idle;
		ready_reg  	      <= '0';

		calcul_en 	       <= '0';
		calcul_rst 		   <= '0';

		case Etat_present is
		      -- 0 -> en attente d'un nouveau calcul
              when idle  =>
				ready_reg  <= '1';
				
				-- start un new calcul -> reset les valeurs de base
				if (start = '1') then
					calcul_rst     <= '1';
					Etat_futur     <= calcul;
				else
					Etat_futur     <= idle;
				end if;

			-- 1 -> en train de traiter un calcul 
			when calcul  =>
				if (finished_reg = '1') then
					Etat_futur  	<= idle;
				else
					calcul_en       <= '1';
					Etat_futur      <= calcul;
				end if;

			when others => 
			     Etat_Futur <= idle;
			     
		end case;
end process Fut;


-- Compteur iterations (+1)
iterations_count_next <= iterations_count + 1;

process(clk, rst)
begin
	if(rst = '1') then
		iterations_count    <= (others => '0');
		z_new_real_s		<= (others => '0');
	    z_new_imaginary_s	<= (others => '0');
	elsif(rising_edge(Clk)) then
		if(calcul_rst = '1') then
			iterations_count     <= (others => '0');
			z_new_real_s		 <= (others => '0');
			z_new_imaginary_s	 <= (others => '0');
		elsif (calcul_en = '1') then
			iterations_count     <= iterations_count_next;
			z_new_real_s	 	 <= z_real_fut_s(COMMA_HIGH downto comma);
			z_new_imaginary_s	 <= z_imaginary_fut_s(COMMA_HIGH downto comma);
		end if;
	end if;
end process;

iterations      <= std_logic_vector(iterations_count(SIZE-1 downto 0));

end Behavioral;
