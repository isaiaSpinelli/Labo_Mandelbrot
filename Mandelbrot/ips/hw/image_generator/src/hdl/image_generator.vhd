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
-- Module Name: image_generator - behavioural
-- Target Device: All
-- Tool version: 2018.3
-- Description: Image Generator
--
-- Last update: 2019-02-15
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity image_generator is

    generic (
        C_DATA_SIZE  : integer     := 16;
        C_PIXEL_SIZE : integer     := 8;
        C_VGA_CONFIG : t_VgaConfig := C_DEFAULT_VGACONFIG);

    port (
        ClkVgaxCI    : in  std_logic;
        RstxRAI      : in  std_logic;
        PllLockedxSI : in  std_logic;
        HCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
        VidOnxSI     : in  std_logic;
        DataxDO      : out std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
        Color1xDI    : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0));

end entity image_generator;

architecture behavioural of image_generator is

    -- VGA 640x480
    constant C_GREEN_STRIP_START_640X480          : integer := 0;
    constant C_WHITE_STRIP_START_640X480          : integer := 213;
    constant C_RED_STRIP_START_640X480            : integer := 426;
    constant C_RED_STRIP_END_640X480              : integer := 639;
    constant C_WHITE_CROSS_V_H_COUNT_MIN_640X480  : integer := 510;
    constant C_WHITE_CROSS_V_H_COUNT_MAX_640X480  : integer := 533;
    constant C_WHITE_CROSS_V_V_COUNT_MIN_640X480  : integer := 42;
    constant C_WHITE_CROSS_V_V_COUNT_MAX_640X480  : integer := 168;
    constant C_WHITE_CROSS_H_H_COUNT_MIN_640X480  : integer := 468;
    constant C_WHITE_CROSS_H_H_COUNT_MAX_640X480  : integer := 597;
    constant C_WHITE_CROSS_H_V_COUNT_MIN_640X480  : integer := 84;
    constant C_WHITE_CROSS_H_V_COUNT_MAX_640X480  : integer := 126;
    -- VGA 800x600
    constant C_GREEN_STRIP_START_800x600          : integer := 0;
    constant C_WHITE_STRIP_START_800x600          : integer := 266;
    constant C_RED_STRIP_START_800x600            : integer := 533;
    constant C_RED_STRIP_END_800x600              : integer := 799;
    constant C_WHITE_CROSS_V_H_COUNT_MIN_800x600  : integer := 639;
    constant C_WHITE_CROSS_V_H_COUNT_MAX_800x600  : integer := 693;
    constant C_WHITE_CROSS_V_V_COUNT_MIN_800x600  : integer := 53;
    constant C_WHITE_CROSS_V_V_COUNT_MAX_800x600  : integer := 212;
    constant C_WHITE_CROSS_H_H_COUNT_MIN_800x600  : integer := 586;
    constant C_WHITE_CROSS_H_H_COUNT_MAX_800x600  : integer := 746;
    constant C_WHITE_CROSS_H_V_COUNT_MIN_800x600  : integer := 106;
    constant C_WHITE_CROSS_H_V_COUNT_MAX_800x600  : integer := 159;
    -- VGA 1024x600
    constant C_GREEN_STRIP_START_1024x600         : integer := 0;
    constant C_WHITE_STRIP_START_1024x600         : integer := 341;
    constant C_RED_STRIP_START_1024x600           : integer := 683;
    constant C_RED_STRIP_END_1024x600             : integer := 1023;
    constant C_WHITE_CROSS_V_H_COUNT_MIN_1024x600 : integer := 819;
    constant C_WHITE_CROSS_V_H_COUNT_MAX_1024x600 : integer := 888;
    constant C_WHITE_CROSS_V_V_COUNT_MIN_1024x600 : integer := 53;
    constant C_WHITE_CROSS_V_V_COUNT_MAX_1024x600 : integer := 212;
    constant C_WHITE_CROSS_H_H_COUNT_MIN_1024x600 : integer := 751;
    constant C_WHITE_CROSS_H_H_COUNT_MAX_1024x600 : integer := 956;
    constant C_WHITE_CROSS_H_V_COUNT_MIN_1024x600 : integer := 106;
    constant C_WHITE_CROSS_H_V_COUNT_MAX_1024x600 : integer := 159;
    -- VGA 1024x768
    constant C_GREEN_STRIP_START_1024x768         : integer := 0;
    constant C_WHITE_STRIP_START_1024x768         : integer := 341;
    constant C_RED_STRIP_START_1024x768           : integer := 683;
    constant C_RED_STRIP_END_1024x768             : integer := 1023;
    constant C_WHITE_CROSS_V_H_COUNT_MIN_1024x768 : integer := 819;
    constant C_WHITE_CROSS_V_H_COUNT_MAX_1024x768 : integer := 888;
    constant C_WHITE_CROSS_V_V_COUNT_MIN_1024x768 : integer := 68;
    constant C_WHITE_CROSS_V_V_COUNT_MAX_1024x768 : integer := 272;
    constant C_WHITE_CROSS_H_H_COUNT_MIN_1024x768 : integer := 751;
    constant C_WHITE_CROSS_H_H_COUNT_MAX_1024x768 : integer := 956;
    constant C_WHITE_CROSS_H_V_COUNT_MIN_1024x768 : integer := 136;
    constant C_WHITE_CROSS_H_V_COUNT_MAX_1024x768 : integer := 204;

    signal VgaConfigxD            : t_VgaConfig                                         := C_VGA_CONFIG;
    signal DataxD                 : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0) := (others => '0');
    signal HCountxD               : std_logic_vector((C_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal VCountxD               : std_logic_vector((C_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal GreenStripStartxD      : integer                                             := 0;
    signal WhiteStripStartxD      : integer                                             := 0;
    signal RedStripStartxD        : integer                                             := 0;
    signal RedStripEndxD          : integer                                             := 0;
    signal WhiteCrossVHCountMinxD : integer                                             := 0;
    signal WhiteCrossVHCountMaxxD : integer                                             := 0;
    signal WhiteCrossVVCountMinxD : integer                                             := 0;
    signal WhiteCrossVVCountMaxxD : integer                                             := 0;
    signal WhiteCrossHHCountMinxD : integer                                             := 0;
    signal WhiteCrossHHCountMaxxD : integer                                             := 0;
    signal WhiteCrossHVCountMinxD : integer                                             := 0;
    signal WhiteCrossHVCountMaxxD : integer                                             := 0;

begin  -- architecture behavioural

    -- Asynchronous statements

    assert (C_VGA_CONFIG = C_640x480_VGACONFIG)
        or (C_VGA_CONFIG = C_800x600_VGACONFIG)
        or (C_VGA_CONFIG = C_1024x600_VGACONFIG)
        or (C_VGA_CONFIG = C_1024x768_VGACONFIG)
        report "Not supported resolution!" severity failure;

    ImGenSigOutxB : block is
    begin  -- block ImGenSigOutxB

        DataxAS   : DataxDO  <= DataxD;
        HCountxAS : HCountxD <= HCountxDI;
        VCountxAS : VCountxD <= VCountxDI;

    end block ImGenSigOutxB;

    VgaConfig640x480xG : if C_VGA_CONFIG = C_640x480_VGACONFIG generate

        GSStartxAS  : GreenStripStartxD      <= C_GREEN_STRIP_START_640X480;
        WSStartxAS  : WhiteStripStartxD      <= C_WHITE_STRIP_START_640X480;
        RSStartxAS  : RedStripStartxD        <= C_RED_STRIP_START_640X480;
        RSEndxAS    : RedStripEndxD          <= C_RED_STRIP_END_640X480;
        WCVHCMinxAS : WhiteCrossVHCountMinxD <= C_WHITE_CROSS_V_H_COUNT_MIN_640X480;
        WCVHCMaxxAS : WhiteCrossVHCountMaxxD <= C_WHITE_CROSS_V_H_COUNT_MAX_640X480;
        WCVVCMinxAS : WhiteCrossVVCountMinxD <= C_WHITE_CROSS_V_V_COUNT_MIN_640X480;
        WCVVCMaxxAS : WhiteCrossVVCountMaxxD <= C_WHITE_CROSS_V_V_COUNT_MAX_640X480;
        WCHHCMinxAS : WhiteCrossHHCountMinxD <= C_WHITE_CROSS_H_H_COUNT_MIN_640X480;
        WCHHCMaxxAS : WhiteCrossHHCountMaxxD <= C_WHITE_CROSS_H_H_COUNT_MAX_640X480;
        WCHVCMinxAS : WhiteCrossHVCountMinxD <= C_WHITE_CROSS_H_V_COUNT_MIN_640X480;
        WCHVCMaxxAS : WhiteCrossHVCountMaxxD <= C_WHITE_CROSS_H_V_COUNT_MAX_640X480;

    end generate VgaConfig640x480xG;

    VgaConfig800x600xG : if C_VGA_CONFIG = C_800x600_VGACONFIG generate

        GSStartxAS  : GreenStripStartxD      <= C_GREEN_STRIP_START_800x600;
        WSStartxAS  : WhiteStripStartxD      <= C_WHITE_STRIP_START_800x600;
        RSStartxAS  : RedStripStartxD        <= C_RED_STRIP_START_800x600;
        RSEndxAS    : RedStripEndxD          <= C_RED_STRIP_END_800x600;
        WCVHCMinxAS : WhiteCrossVHCountMinxD <= C_WHITE_CROSS_V_H_COUNT_MIN_800x600;
        WCVHCMaxxAS : WhiteCrossVHCountMaxxD <= C_WHITE_CROSS_V_H_COUNT_MAX_800x600;
        WCVVCMinxAS : WhiteCrossVVCountMinxD <= C_WHITE_CROSS_V_V_COUNT_MIN_800x600;
        WCVVCMaxxAS : WhiteCrossVVCountMaxxD <= C_WHITE_CROSS_V_V_COUNT_MAX_800x600;
        WCHHCMinxAS : WhiteCrossHHCountMinxD <= C_WHITE_CROSS_H_H_COUNT_MIN_800x600;
        WCHHCMaxxAS : WhiteCrossHHCountMaxxD <= C_WHITE_CROSS_H_H_COUNT_MAX_800x600;
        WCHVCMinxAS : WhiteCrossHVCountMinxD <= C_WHITE_CROSS_H_V_COUNT_MIN_800x600;
        WCHVCMaxxAS : WhiteCrossHVCountMaxxD <= C_WHITE_CROSS_H_V_COUNT_MAX_800x600;

    end generate VgaConfig800x600xG;

    VgaConfig1024x600xG : if C_VGA_CONFIG = C_1024x600_VGACONFIG generate

        GSStartxAS  : GreenStripStartxD      <= C_GREEN_STRIP_START_1024x600;
        WSStartxAS  : WhiteStripStartxD      <= C_WHITE_STRIP_START_1024x600;
        RSStartxAS  : RedStripStartxD        <= C_RED_STRIP_START_1024x600;
        RSEndxAS    : RedStripEndxD          <= C_RED_STRIP_END_1024x600;
        WCVHCMinxAS : WhiteCrossVHCountMinxD <= C_WHITE_CROSS_V_H_COUNT_MIN_1024x600;
        WCVHCMaxxAS : WhiteCrossVHCountMaxxD <= C_WHITE_CROSS_V_H_COUNT_MAX_1024x600;
        WCVVCMinxAS : WhiteCrossVVCountMinxD <= C_WHITE_CROSS_V_V_COUNT_MIN_1024x600;
        WCVVCMaxxAS : WhiteCrossVVCountMaxxD <= C_WHITE_CROSS_V_V_COUNT_MAX_1024x600;
        WCHHCMinxAS : WhiteCrossHHCountMinxD <= C_WHITE_CROSS_H_H_COUNT_MIN_1024x600;
        WCHHCMaxxAS : WhiteCrossHHCountMaxxD <= C_WHITE_CROSS_H_H_COUNT_MAX_1024x600;
        WCHVCMinxAS : WhiteCrossHVCountMinxD <= C_WHITE_CROSS_H_V_COUNT_MIN_1024x600;
        WCHVCMaxxAS : WhiteCrossHVCountMaxxD <= C_WHITE_CROSS_H_V_COUNT_MAX_1024x600;

    end generate VgaConfig1024x600xG;

    VgaConfig1024x768xG : if C_VGA_CONFIG = C_1024x768_VGACONFIG generate

        GSStartxAS  : GreenStripStartxD      <= C_GREEN_STRIP_START_1024x768;
        WSStartxAS  : WhiteStripStartxD      <= C_WHITE_STRIP_START_1024x768;
        RSStartxAS  : RedStripStartxD        <= C_RED_STRIP_START_1024x768;
        RSEndxAS    : RedStripEndxD          <= C_RED_STRIP_END_1024x768;
        WCVHCMinxAS : WhiteCrossVHCountMinxD <= C_WHITE_CROSS_V_H_COUNT_MIN_1024x768;
        WCVHCMaxxAS : WhiteCrossVHCountMaxxD <= C_WHITE_CROSS_V_H_COUNT_MAX_1024x768;
        WCVVCMinxAS : WhiteCrossVVCountMinxD <= C_WHITE_CROSS_V_V_COUNT_MIN_1024x768;
        WCVVCMaxxAS : WhiteCrossVVCountMaxxD <= C_WHITE_CROSS_V_V_COUNT_MAX_1024x768;
        WCHHCMinxAS : WhiteCrossHHCountMinxD <= C_WHITE_CROSS_H_H_COUNT_MIN_1024x768;
        WCHHCMaxxAS : WhiteCrossHHCountMaxxD <= C_WHITE_CROSS_H_H_COUNT_MAX_1024x768;
        WCHVCMinxAS : WhiteCrossHVCountMinxD <= C_WHITE_CROSS_H_V_COUNT_MIN_1024x768;
        WCHVCMaxxAS : WhiteCrossHVCountMaxxD <= C_WHITE_CROSS_H_V_COUNT_MAX_1024x768;

    end generate VgaConfig1024x768xG;

    -- Synchronous statements

    -- purpose: Data generator
    -- type   : combinational
    -- inputs : all
    -- outputs: 
    DataGeneratorxP : process (ClkVgaxCI, PllLockedxSI, RstxRAI) is
    begin  -- process DataGeneratorxP
        if RstxRAI = '1' or PllLockedxSI = '0' then
            DataxD <= (others => '0');
        elsif rising_edge(ClkVgaxCI) then
            DataxD <= DataxD;

            if VidOnxSI = '1' then
                DataxD <= x"ffffff";

                if (to_integer(unsigned(HCountxD)) >= GreenStripStartxD) and
                    (to_integer(unsigned(HCountxD)) < WhiteStripStartxD) then
                    --DataxD <= x"3a8923";
                    DataxD <= Color1xDI;
                elsif (to_integer(unsigned(HCountxD)) >= WhiteStripStartxD) and
                    (to_integer(unsigned(HCountxD)) < RedStripStartxD) then
                    DataxD <= x"ffffff";
                elsif (to_integer(unsigned(HCountxD)) >= RedStripStartxD) and
                    (to_integer(unsigned(HCountxD)) < RedStripEndxD) then
                    DataxD <= x"d90115";

                    if ((to_integer(unsigned(HCountxD)) > WhiteCrossVHCountMinxD) and
                        (to_integer(unsigned(HCountxD)) <= WhiteCrossVHCountMaxxD)) and
                        ((to_integer(unsigned(VCountxD)) > WhiteCrossVVCountMinxD) and
                         (to_integer(unsigned(VCountxD)) <= WhiteCrossVVCountMaxxD)) then
                        DataxD <= x"ffffff";
                    end if;

                    if ((to_integer(unsigned(HCountxD)) > WhiteCrossHHCountMinxD) and
                        (to_integer(unsigned(HCountxD)) <= WhiteCrossHHCountMaxxD)) and
                        ((to_integer(unsigned(VCountxD)) > WhiteCrossHVCountMinxD) and
                         (to_integer(unsigned(VCountxD)) <= WhiteCrossHVCountMaxxD)) then
                        DataxD <= x"ffffff";
                    end if;
                end if;
            else
                DataxD <= (others => '0');
            end if;
        end if;
    end process DataGeneratorxP;

end architecture behavioural;
