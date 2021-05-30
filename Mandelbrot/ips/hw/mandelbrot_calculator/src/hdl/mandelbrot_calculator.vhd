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
    type Etat is (idle, init, mul, add, calulD, test, finish );
	signal Etat_present, Etat_futur : Etat := idle;
	
	signal ready_reg                   : std_logic := '1'; 

	
	
	-- regsitres
    signal save_info 			       : std_logic := '0'; 
    signal c_real_reg		   	       : std_logic_vector (SIZE-1 downto 0);
    signal c_imaginary_reg			   : std_logic_vector (SIZE-1 downto 0);
    
    signal z_real_reg		   	       : std_logic_vector (SIZE+1 downto 0);
    signal z_imaginary_reg			   : std_logic_vector (SIZE downto 0);
    signal z_real_reg_p		   	       : std_logic_vector (SIZE+1 downto 0);
    signal z_imaginary_reg_p		   : std_logic_vector (SIZE downto 0);


	-- Gestion du compteur
	signal iterations_reg			   : std_logic_vector (SIZE-1 downto 0);
	
    signal iterations_count_next	   : unsigned (SIZE-1 downto 0) := (others => '0');
    signal iterations_count		       : unsigned (SIZE-1 downto 0) := (others => '0');
    signal en_cpt_s 			       : std_logic := '0'; 
    signal load_cpt_s 			       : std_logic := '0'; 
    
    --signal z_real_fut_reg		   	       : std_logic_vector (SIZE-1 downto 0);
    --signal z_imaginary_fut_reg			   : std_logic_vector (SIZE-1 downto 0);
    
    signal z_real_carre		   	       : std_logic_vector (SIZE-1 downto 0) ;
    signal Z_re_Z_im_2		   	       : std_logic_vector (SIZE-1 downto 0) ;
    signal Z_im_carre		   	       : std_logic_vector (SIZE-1 downto 0) ;
    signal z_real_carre_p		   	       : std_logic_vector (SIZE-1 downto 0) ;
    signal Z_re_Z_im_2_p		   	       : std_logic_vector (SIZE-1 downto 0) ;
    signal Z_im_carre_p		   	       : std_logic_vector (SIZE-1 downto 0) ;
    
    signal D_s                          : std_logic_vector (SIZE downto 0) ;
    signal D_s_p                          : std_logic_vector (SIZE downto 0) ;

    
	
	attribute mark_debug                                    : string;
    attribute mark_debug of Etat_present                    : signal is "true";
    attribute mark_debug of Etat_futur                      : signal is "true";
    attribute mark_debug of rst                             : signal is "true";
    
    attribute mark_debug of save_info                       : signal is "true";
    attribute mark_debug of c_real_reg                      : signal is "true";
    attribute mark_debug of c_imaginary_reg                 : signal is "true";
    attribute mark_debug of z_real_reg                      : signal is "true";
    attribute mark_debug of z_imaginary_reg                 : signal is "true";
    
    attribute mark_debug of iterations_reg                  : signal is "true";
    attribute mark_debug of en_cpt_s                        : signal is "true";
    attribute mark_debug of load_cpt_s                      : signal is "true";
    attribute mark_debug of z_real_carre                    : signal is "true";
    attribute mark_debug of Z_re_Z_im_2                     : signal is "true";
    attribute mark_debug of Z_im_carre                      : signal is "true";
    attribute mark_debug of D_s                             : signal is "true";
    
    attribute keep                                      : string;
    attribute keep of Etat_present                      : signal is "true";
    attribute keep of Etat_futur                        : signal is "true";
    attribute keep of rst                               : signal is "true";
    
    attribute keep of save_info                         : signal is "true";
    attribute keep of c_real_reg                        : signal is "true";
    attribute keep of c_imaginary_reg                   : signal is "true";
    attribute keep of z_real_reg                        : signal is "true";
    attribute keep of z_imaginary_reg                   : signal is "true";
    
    attribute keep of iterations_reg                    : signal is "true";
    attribute keep of en_cpt_s                          : signal is "true";
    attribute keep of load_cpt_s                        : signal is "true";
    attribute keep of z_real_carre                      : signal is "true";
    attribute keep of Z_re_Z_im_2                       : signal is "true";
    attribute keep of Z_im_carre                        : signal is "true";
    attribute keep of D_s                               : signal is "true";
	
begin

ready <= ready_reg;

-- Reset ou met à jour l'état présent
	Mem: process (clk, rst)
	begin
		if (rst = '1') then
			Etat_Present <= idle;
		elsif rising_edge(clk) then
			Etat_Present <= Etat_Futur;
			
			z_real_reg_p <= z_real_reg;
            z_imaginary_reg_p <= z_imaginary_reg; 
            z_real_carre_p <= z_real_carre;	
            Z_re_Z_im_2_p <= Z_re_Z_im_2;	
            Z_im_carre_p <= Z_im_carre;
            D_s_p <= D_s;
		end if;
	end process;
	
	
-- Gestion des sorties en fonction de l'état présent
-- Gestion des états futurs en fonction des entrées (sauf etat 4)
Fut: 
process (start, Etat_Present,z_real_reg_p,z_imaginary_reg_p,z_real_carre_p,Z_re_Z_im_2_p,Z_im_carre_p,D_s_p ) -- all / start, Etat_Present
	-- (idle, init, mul, add, test, finish )
	
	-- Variables
	variable z_real_carre_32   : std_logic_vector (SIZE-1 downto 0);
	variable z_im_carre_32     : std_logic_vector (SIZE-1 downto 0);
	
	
	begin
	-- valeurs par défaut
		Etat_Futur <= idle;
		finished <= '0';
		ready_reg <= '0';
		
		save_info <= '0';
		
		load_cpt_s <= '0';
		en_cpt_s <= '0';
		
		-- garde son etat
        z_real_reg <= z_real_reg_p;
        z_imaginary_reg <= z_imaginary_reg_p; 
        z_real_carre <= z_real_carre_p;	
        Z_re_Z_im_2 <= Z_re_Z_im_2_p;	
        Z_im_carre <= Z_im_carre_p;
        D_s <= D_s_p;
		
		case Etat_Present is
		      -- 0
		      when idle =>
		      
		            ready_reg <= '1';
    
                    if (start = '1') then
                        Etat_Futur <= init;
                    else 
                        Etat_Futur <= idle;
                    end if;
            -- 1        
            when init =>
                    
                    -- save data
                    save_info <= '1';
                    load_cpt_s <= '1';
                    z_real_reg      <= (others => '0');
                    z_imaginary_reg <= (others => '0');
                
                    Etat_Futur <= mul;
            -- 2        
            when mul =>
                                        
                    -- faire les multiplications
                    
                    z_real_carre        <= conv_std_logic_vector((signed(z_real_reg_p) * signed(z_real_reg_p)), SIZE*2)((SIZE-1+comma) downto comma);
                    Z_re_Z_im_2         <= conv_std_logic_vector(((signed(z_real_reg_p) * signed(z_imaginary_reg_p)) & '0'), SIZE*2)((SIZE-1+comma) downto comma);
                    Z_im_carre          <= conv_std_logic_vector((- (signed(z_imaginary_reg_p) * signed(z_imaginary_reg_p))), SIZE*2)((SIZE-1+comma) downto comma);
                
                    Etat_Futur <= add;
              -- 3      
              when add =>
                    
                    en_cpt_s <= '1';
                    z_real_reg      <= conv_std_logic_vector((signed(z_real_carre_p) + signed(Z_im_carre_p ) + signed(c_real_reg)), SIZE+2) ;
                    z_imaginary_reg <= conv_std_logic_vector(signed(Z_re_Z_im_2_p) + signed(c_imaginary), SIZE+1);
                
                    Etat_Futur <= calulD;
             -- 4      
             when calulD =>
                     -- 12 + size -1 => SIZE-1+comma downto comma
                    z_real_carre_32 := conv_std_logic_vector((signed(z_real_reg_p) * signed(z_real_reg_p)), SIZE*2) ((SIZE-1+comma) downto comma);
                    z_im_carre_32   := conv_std_logic_vector((signed(z_imaginary_reg_p) * signed(z_imaginary_reg_p)), SIZE*2) ((SIZE-1+comma) downto comma);
                    
                    D_s             <= conv_std_logic_vector(unsigned(z_real_carre_32) + unsigned(z_im_carre_32), (SIZE+1));
                
                    Etat_Futur <= test;
            -- 5        
            when test =>
                    
                    if (D_s_p >= "00000100000000000000" ) then --  "0100000000000000" = 4 (Rayon^2)   00000100000000000000  - X"00000000000004000"
                        Etat_Futur <= finish;
                    else 
                        -- TODO : Change constante to mxx_iter generique param
                        if (iterations_reg >= "0000000001100100") then -- "0000000001100100" = 100 iterations
                            load_cpt_s <= '1'; -- retourne 0 
                            Etat_Futur <= finish;
                        else 
                            Etat_Futur <= mul;
                        end if;
                    end if;
                    
                    
           when finish =>
                    finished <= '1';
                    ready_reg <= '1';
                
                    Etat_Futur <= idle;
                    
            when others =>
				Etat_Futur <= idle;
			end case ;
			
end process Fut;
		
		
-- Registre pour la lecture sychro (entrées)
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

-- Registre pour l'ecriture sychro (sorties)
process(clk, rst)
begin
	if(rst = '1') then
		z_real      <= (others => '0');
		z_imaginary <= (others => '0');
	elsif(rising_edge(Clk)) then
		z_real        <= z_real_reg(SIZE-1 downto 0);
		z_imaginary   <= z_imaginary_reg(SIZE-1 downto 0);
	end if;
end process;




-- Compteur iterations (+1)
iterations_count_next <= iterations_count + 1;

process(clk, rst)
begin
	if(rst = '1') then
		iterations_count <= (others => '0');
	elsif(rising_edge(Clk)) then
		if(load_cpt_s = '1') then
			iterations_count <= (others => '0');
		elsif (en_cpt_s = '1') then
			iterations_count <= iterations_count_next;
		end if;
	end if;
end process;

iterations_reg  <=  std_logic_vector(iterations_count(SIZE-1 downto 0));
iterations      <= std_logic_vector(iterations_count(SIZE-1 downto 0));


end Behavioral;
