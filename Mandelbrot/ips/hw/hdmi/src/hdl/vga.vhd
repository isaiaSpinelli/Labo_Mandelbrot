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
-- Module Name: vga - rtl
-- Target Device: All
-- Tool version: 2018.3
-- Description: VGA
--
-- Last update: 2019-02-14
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity vga is

    generic (
        C_DATA_SIZE    : integer     := 16;
        C_PIXEL_SIZE   : integer     := 8;
        C_VGA_CONFIG   : t_VgaConfig := C_DEFAULT_VGACONFIG;
        C_HDMI_LATENCY : integer     := 0);

    port (
        ClkVgaxCI    : in  std_logic;
        RstxRI       : in  std_logic;
        PllLockedxSI : in  std_logic;
        VidOnxSO     : out std_logic;
        DataxDI      : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
        HCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VgaxDO       : out t_Vga);

end entity vga;

architecture rtl of vga is

    component vga_controler is
        generic (
            C_DATA_SIZE    : integer;
            C_VGA_CONFIG   : t_VgaConfig;
            C_HDMI_LATENCY : integer);
        port (
            ClkVgaxCI    : in  std_logic;
            RstxRANI     : in  std_logic;
            PllLockedxSI : in  std_logic;
            VgaSyncxSO   : out t_VgaSync;
            HCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO    : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSO     : out std_logic);
    end component vga_controler;

    component vga_stripes is
        generic (
            C_DATA_SIZE  : integer;
            C_PIXEL_SIZE : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            HCountxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSI    : in  std_logic;
            DataxDI     : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            VgaPixelxDO : out t_VgaPixel;
            HCountxDO   : out std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO   : out std_logic_vector((C_DATA_SIZE - 1) downto 0));
    end component vga_stripes;

    signal RstxRN              : std_logic                                    := '1';
    signal VgaxD               : t_Vga                                        := C_NO_VGA;
    signal HCountCtrl2StripxD  : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VCountCtrl2StripxD  : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal HCountStrip2ImGenxD : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VCountStrip2ImGenxD : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');
    signal VidOnxS             : std_logic                                    := '0';

    -- Debug signals

    -- signal DebugRedxD   : std_logic_vector((C_PIXEL_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugGreenxD : std_logic_vector((C_PIXEL_SIZE - 1) downto 0) := (others => '0');
    -- signal DebugBluexD  : std_logic_vector((C_PIXEL_SIZE - 1) downto 0) := (others => '0');

    -- attribute mark_debug                 : string;
    -- attribute mark_debug of DebugRedxD   : signal is "true";
    -- attribute mark_debug of DebugGreenxD : signal is "true";
    -- attribute mark_debug of DebugBluexD  : signal is "true";

    -- attribute keep                 : string;
    -- attribute keep of DebugRedxD   : signal is "true";
    -- attribute keep of DebugGreenxD : signal is "true";
    -- attribute keep of DebugBluexD  : signal is "true";

begin  -- architecture rtl

    -- Asynchronous statements

    VgaSigOutxB : block is
    begin  -- block VgaSigOutxB

        VgaxAS    : VgaxDO    <= VgaxD;
        VidOnxAS  : VidOnxSO  <= VidOnxS;
        HCountxAS : HCountxDO <= HCountStrip2ImGenxD;

        VCountxAS : VCountxDO <= VCountCtrl2StripxD;
    end block VgaSigOutxB;

    RstxAS : RstxRN <= not RstxRI;

    -- DebugSigxB : block is
    -- begin  -- block DebugSigxB
    --     DebugRedxAS   : DebugRedxD   <= VgaxD.VgaPixelxD.RedxD;
    --     DebugGreenxAS : DebugGreenxD <= VgaxD.VgaPixelxD.GreenxD;
    --     DebugBluexAS  : DebugBluexD  <= VgaxD.VgaPixelxD.BluexD;
    -- end block DebugSigxB;

    VgaStripesxI : entity work.vga_stripes
        generic map (
            C_DATA_SIZE  => C_DATA_SIZE,
            C_PIXEL_SIZE => C_PIXEL_SIZE,
            C_VGA_CONFIG => C_VGA_CONFIG)
        port map (
            HCountxDI   => HCountCtrl2StripxD,
            VCountxDI   => VCountCtrl2StripxD,
            VidOnxSI    => VidOnxS,
            DataxDI     => DataxDI,
            VgaPixelxDO => VgaxD.VgaPixelxD,
            HCountxDO   => HCountStrip2ImGenxD,
            VCountxDO   => VCountStrip2ImGenxD);

    -- Synchronous statements

    VgaControlerxI : entity work.vga_controler
        generic map (
            C_DATA_SIZE    => C_DATA_SIZE,
            C_VGA_CONFIG   => C_VGA_CONFIG,
            C_HDMI_LATENCY => C_HDMI_LATENCY)
        port map (
            ClkVgaxCI    => ClkVgaxCI,
            RstxRANI     => RstxRN,
            PllLockedxSI => PllLockedxSI,
            VgaSyncxSO   => VgaxD.VgaSyncxS,
            HCountxDO    => HCountCtrl2StripxD,
            VCountxDO    => VCountCtrl2StripxD,
            VidOnxSO     => VidOnxS);

end architecture rtl;
