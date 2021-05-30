----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.04.2021 20:22:19
-- Design Name: 
-- Module Name: MSS_cGen_Calcul - Behavioral
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

entity mss_cgen_calcul  is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           ready : in STD_LOGIC;
           start : out STD_LOGIC;
           nextValue : out STD_LOGIC);
end entity mss_cgen_calcul;

architecture Behavioral of mss_cgen_calcul is


-- NOUVELLE METHODE
    type Etat is (idle, next1, next2, start1 );
	signal Etat_present, Etat_futur : Etat := idle;
	
	signal start_reg                   		: std_logic := '0'; 
	signal nextValue_reg                   	: std_logic := '0'; 



	
begin

start <= start_reg;
nextValue <= nextValue_reg;

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
-- Gestion des états futurs en fonction des entrées
Fut: 
process (ready, Etat_Present)
	-- (idle, next1, next2, start1 )
	
	
	begin
	-- valeurs par défaut
		Etat_Futur <= idle;
		start_reg <= '0';
		nextValue_reg <= '0';

	
		case Etat_Present is
		      -- 0
		      when idle =>
		          
                    if (ready = '1') then
                        Etat_Futur <= start1;
                    else 
                        Etat_Futur <= idle;
                    end if;
            -- 1        
            when next1 =>
                    
                    -- nextValue_reg <= '1';
                    start_reg <= '1';

                    Etat_Futur <= next2;
            -- 2        
            when next2 =>
                                        
                    if (ready = '1') then
                        Etat_Futur <= start1;
                    else 
                        Etat_Futur <= next2;
                    end if;
              -- 3      
              when start1 =>
                    
                    -- start_reg <= '1';
                    nextValue_reg <= '1';
                    Etat_Futur <= next1;

            when others =>
				Etat_Futur <= idle;
			end case ;
			
end process Fut;
		

end Behavioral;
