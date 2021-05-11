----------------------------------------------------------------------------------
-- hepia / LPSCP / Pr. F. Vannel
--
-- Generateur de nombres complexes a fournir au calculateur de Mandelbrot
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;

entity ComplexValueGenerator is
    generic
        (SIZE       : integer := 16;  -- Taille en bits de nombre au format virgule fixe
         X_SIZE     : integer := 1024;  -- Taille en X (Nombre de pixel) de la fractale à afficher
         Y_SIZE     : integer := 600;  -- Taille en Y (Nombre de pixel) de la fractale à afficher
         SCREEN_RES : integer := 10);  -- Nombre de bit pour les vecteurs X et Y de la position du pixel

    port
        (clk           : in  std_logic;
         reset         : in  std_logic;
         -- interface avec le module MandelbrotMiddleware
         next_value    : in  std_logic;
         c_inc_RE      : in  std_logic_vector((SIZE - 1) downto 0);
         c_inc_IM      : in  std_logic_vector((SIZE - 1) downto 0);
         c_top_left_RE : in  std_logic_vector((SIZE - 1) downto 0);
         c_top_left_IM : in  std_logic_vector((SIZE - 1) downto 0);
         c_real        : out std_logic_vector((SIZE - 1) downto 0);
         c_imaginary   : out std_logic_vector((SIZE - 1) downto 0);
         X_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0);
         Y_screen      : out std_logic_vector((SCREEN_RES - 1) downto 0));
end ComplexValueGenerator;


architecture Behavioral of ComplexValueGenerator is

    -- signaux internes
    signal c_re_i, c_im_i : std_logic_vector (SIZE-1 downto 0);
    signal posx_i, posy_i : std_logic_vector (SCREEN_RES-1 downto 0);

begin

    -- processus combinatoire --------------------------------------------------
    process (clk, reset)
    begin
        if (reset = '1') then
            c_re_i <= c_top_left_RE;
            c_im_i <= c_top_left_IM;
            posx_i <= (others => '0');
            posy_i <= (others => '0');

        elsif rising_edge(clk) then

            if next_value = '1' then

                -- balayage de l'espace complexe 
                c_re_i <= std_logic_vector(unsigned(c_re_i) + unsigned(c_inc_RE));
                posx_i <= std_logic_vector(unsigned(posx_i) + 1);

                -- fin de ligne
                if posx_i = std_logic_vector(to_unsigned((X_SIZE - 1), SCREEN_RES)) then
                    c_re_i <= c_top_left_RE;
                    c_im_i <= std_logic_vector(unsigned(c_im_i) - unsigned(c_inc_IM));
                    posy_i <= std_logic_vector(unsigned(posy_i) + 1);
                    posx_i <= (others => '0');
                    -- fin d'ecran
                    if posy_i = std_logic_vector(to_unsigned((Y_SIZE - 1), SCREEN_RES)) then
                        c_im_i <= c_top_left_IM;
                        posy_i <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- sorties pour le module calculateur de Mandelbrot ----------------------
    c_real      <= c_re_i;
    c_imaginary <= c_im_i;
    X_screen    <= posx_i;
    Y_screen    <= posy_i;

end Behavioral;

