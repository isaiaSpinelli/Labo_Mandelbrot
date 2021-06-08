----------------------------------------------------------------------------------
-- Company: MSE HES-SO
-- Engineer: Isaia Spinelli 
-- 
-- Create Date: 20.04.2021 20:22:19
-- Design Name: 
-- Module Name: mandelbrot_calculator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: calculator mandelbrot
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
use ieee.numeric_std.all;


entity mandelbrot_calculator is
generic (   comma       : integer := 12; -- nombre de bits après la virgule
            max_iter    : integer := 100;
            SIZE        : integer := 16);
            
          
    Port ( clk          : in STD_LOGIC;
           rst          : in STD_LOGIC;
           ready        : out STD_LOGIC;
           start        : in STD_LOGIC;
           finished     : out STD_LOGIC;
           c_real       : in STD_LOGIC_VECTOR (SIZE-1 downto 0);
           c_imaginary  : in STD_LOGIC_VECTOR (SIZE-1 downto 0);
           z_real       : out STD_LOGIC_VECTOR (SIZE-1 downto 0);
           z_imaginary  : out STD_LOGIC_VECTOR (SIZE-1 downto 0);
           iterations   : out STD_LOGIC_VECTOR (SIZE-1 downto 0));
           
end mandelbrot_calculator;


architecture Behavioral of mandelbrot_calculator is


	--  ---------- CONSTANTES ----------  
	constant DOUBLE_SIZE       : integer := 2*SIZE;
	constant COMMA_HIGH        : integer := (SIZE+comma-1);
	
	-- rayon max au carre
	constant rayon_2           : std_logic_vector(DOUBLE_SIZE-1 downto 0) := "00000100" & "000000000000000000000000";
	
	

	--  ---------- SIGNAUX MSS ----------  
		
		
	-- Machine d'etat (MSS)
	type Etat is (idle, calcul);
	signal Etat_present, Etat_futur : Etat := idle;
	

	-- MSS prete pour un nouveau calcul
	signal ready_reg               : std_logic := '1'; 
	-- Debut un nouveau calcul
	signal start_s			       : std_logic;
	-- Calcul fini
	signal finished_reg		       : std_logic := '0';
	-- Active un calcul
	signal calcul_en               : std_logic;
	-- réinitialise les signaux de bases
	signal calcul_rst              : std_logic;
	
	
	--  ---------- SIGNAUX LOGIQUES ----------  

	-- compteur d'iterations
	signal iterations_count_next   : unsigned (SIZE-1 downto 0) := (others => '0');
    signal iterations_count		   : unsigned (SIZE-1 downto 0) := (others => '0');

    -- sortie des MUX
	signal z_real_s			    : std_logic_vector(SIZE-1 downto 0);
	signal z_imag_s	            : std_logic_vector(SIZE-1 downto 0);

	-- resultats intermédiaires
	signal z_real_carre			: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal Z_im_carre			: std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_re_x_im_s		    : std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal Z_re_Z_im_2_p	    : std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_re2_sub_im2_s	    : std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_re2_add_im2_s	    : std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_re_fut_s		    : std_logic_vector(DOUBLE_SIZE-1 downto 0);
	signal z_im_fut_s		    : std_logic_vector(DOUBLE_SIZE-1 downto 0);

	-- sortie des registres
	signal z_new_re_s			: std_logic_vector(SIZE-1 downto 0);
	signal z_new_im_s		    : std_logic_vector(SIZE-1 downto 0);


begin
    
-- branchement
z_real 		<= z_real_s;
z_imaginary <= z_imag_s;

combinatoire :
process( all )
	begin
		--  MUX
		z_real_s 		    <= z_new_re_s;
		z_imag_s 	        <= z_new_im_s;


		--  MUL
		z_real_carre	    <= std_logic_vector(signed(z_real_s) * signed(z_real_s));				
		Z_im_carre			<= std_logic_vector(signed(z_imag_s) * signed(z_imag_s));		
		z_re_x_im_s	        <= std_logic_vector(signed(z_real_s) * signed(z_imag_s));			
		Z_re_Z_im_2_p	    <= std_logic_vector(z_re_x_im_s(DOUBLE_SIZE-2 downto 0) & '0');


		--  ADD / SUB
		z_re2_sub_im2_s 	<= std_logic_vector(signed(z_real_carre) - signed(Z_im_carre));	
		z_re2_add_im2_s 	<= std_logic_vector(signed(z_real_carre) + signed(Z_im_carre));
		
		-- RES
		z_re_fut_s			<= std_logic_vector(signed(z_re2_sub_im2_s) + signed(c_real & "000000000000"));
		z_im_fut_s			<= std_logic_vector(signed(Z_re_Z_im_2_p) + signed(c_imaginary & "000000000000"));

        -- test de fin
		if(unsigned(z_re2_add_im2_s) > unsigned(rayon_2)) then
			finished_reg 	<= '1';
		elsif(unsigned(iterations_count) >= max_iter) then
			finished_reg 	<= '1';
		else
			finished_reg	<= '0';
		end if;
end process combinatoire;

-- branchement
finished	<= finished_reg;



-- Reset ou met à jour l'état présent
Mem: 
process (clk, rst)
	begin
		if (rst = '1') then
			Etat_present <= idle;
		elsif rising_edge(clk) then
			Etat_present <= Etat_Futur ;
		end if;
end process Mem;



Fut:
process(all)
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

-- branchement
ready       <= ready_reg;


-- Compteur iterations (+1)
iterations_count_next <= iterations_count + 1;

process(clk, rst)
begin
	if(rst = '1') then
		iterations_count    <= (others => '0');
		z_new_re_s		    <= (others => '0');
	    z_new_im_s	        <= (others => '0');
	elsif(rising_edge(Clk)) then
		if(calcul_rst = '1') then
			iterations_count <= (others => '0');
			z_new_re_s		 <= (others => '0');
			z_new_im_s	     <= (others => '0');
		elsif (calcul_en = '1') then
			iterations_count <= iterations_count_next;
			z_new_re_s	 	 <= z_re_fut_s(COMMA_HIGH downto comma);
			z_new_im_s	     <= z_im_fut_s(COMMA_HIGH downto comma);
		end if;
	end if;
end process;

iterations      <= std_logic_vector(iterations_count(SIZE-1 downto 0));

end Behavioral;
