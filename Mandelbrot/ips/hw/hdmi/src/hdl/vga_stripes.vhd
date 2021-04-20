----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: hepia
-- Author: Joachim Schmidt <joachim.schmidt@hesge.ch>
--
-- Module Name: vga_stripes - behavioural
-- Target Device: All
-- Tool version: 2018.3
-- Description: 
--
-- Last update: 2019-02-15
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity vga_stripes is

    generic (
        C_DATA_SIZE  : integer     := 16;
        C_PIXEL_SIZE : integer     := 8;
        C_VGA_CONFIG : t_VgaConfig := C_DEFAULT_VGACONFIG);

    port (
        HCountxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VidOnxSI    : in  std_logic;
        DataxDI     : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
        VgaPixelxDO : out t_VgaPixel;
        HCountxDO   : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDO   : out std_logic_vector((C_DATA_SIZE - 1) downto 0));

end entity vga_stripes;

architecture behavioural of vga_stripes is

    signal VgaConfigxD : t_VgaConfig                                  := C_VGA_CONFIG;
    signal HCountxD    : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VCountxD    : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');

    -- Debug signals

    -- signal DebugHCountxDI : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugVCountxDI : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugHCountxDO : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugVCountxDO : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');

    -- attribute mark_debug                   : string;
    -- attribute mark_debug of DebugHCountxDI : signal is "true";
    -- attribute mark_debug of DebugVCountxDI : signal is "true";
    -- attribute mark_debug of DebugHCountxDO : signal is "true";
    -- attribute mark_debug of DebugVCountxDO : signal is "true";

    -- attribute keep                   : string;
    -- attribute keep of DebugHCountxDI : signal is "true";
    -- attribute keep of DebugVCountxDI : signal is "true";
    -- attribute keep of DebugHCountxDO : signal is "true";
    -- attribute keep of DebugVCountxDO : signal is "true";

begin  -- architecture behavioural

    -- Asynchronous statements

    HVCountSigOutxB : block is
    begin  -- block HVCountSigOut

        HCountxAS : HCountxDO <= HCountxD;
        VCountxAS : VCountxDO <= VCountxD;

    end block HVCountSigOutxB;

    -- DebugSigxB : block is
    -- begin  -- block DebugSigxB
    --     DebugHCountInxAS  : DebugHCountxDI <= HCountxDI;
    --     DebugVCountInxAS  : DebugVCountxDI <= VCountxDI;
    --     DebugHCountOutxAS : DebugHCountxDO <= HCountxD;
    --     DebugVCountOutxAS : DebugVCountxDO <= VCountxD;
    -- end block DebugSigxB;

    -- Synchronous statements

    -- purpose: Counters management
    -- type   : combinational
    -- inputs : all
    -- outputs: 
    CountxP : process (HCountxDI, VCountxDI, VidOnxSI) is
    begin  -- process CountxP
        if VidOnxSI = '1' then
            HCountxD <= HCountxDI;
            VCountxD <= VCountxDI;
        else
            HCountxD <= (others => '0');
            VCountxD <= (others => '0');
        end if;
    end process CountxP;

    -- purpose: Pixels management
    -- type   : combinational
    -- inputs : all
    -- outputs: 
    PixelxP : process (all) is
    begin  -- process PixelxP
        if VidOnxSI = '1' then
            VgaPixelxDO.RedxD   <= DataxDI(((C_PIXEL_SIZE * 3) - 1) downto (C_PIXEL_SIZE * 2));
            VgaPixelxDO.GreenxD <= DataxDI(((C_PIXEL_SIZE * 2) - 1) downto C_PIXEL_SIZE);
            VgaPixelxDO.BluexD  <= DataxDI((C_PIXEL_SIZE - 1) downto 0);
        else
            VgaPixelxDO.RedxD   <= (others => '0');
            VgaPixelxDO.GreenxD <= (others => '0');
            VgaPixelxDO.BluexD  <= (others => '0');
        end if;
    end process PixelxP;

end architecture behavioural;
