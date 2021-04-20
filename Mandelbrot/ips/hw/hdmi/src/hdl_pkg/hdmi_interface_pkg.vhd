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
-- Module Name: hdmi_interface_pkg - package
-- Target Device: All
-- Tool version: 2018.3
-- Description: HDMI Interface Package
--
-- Last update: 2019-02-14
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hdmi_interface_pkg is

    -- VGA/HDMI Resolutions
    constant C_RESOLUTION_640X480     : string                               := "640x480";
    constant C_RESOLUTION_800X600     : string                               := "800x600";
    constant C_RESOLUTION_1024X600    : string                               := "1024x600";
    constant C_RESOLUTION_1024X768    : string                               := "1024x768";
    -- VGA Part
    constant C_DATA_SIZE              : integer                              := 16;
    constant C_PIXEL_SIZE             : integer                              := 8;
    constant C_CHANNEL_NUMBER         : integer                              := 4;
    -- VGA 1024x768
    constant C_1024x768_H_ACTIVE      : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(1024, C_DATA_SIZE);
    constant C_1024x768_V_ACTIVE      : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(768, C_DATA_SIZE);
    constant C_1024x768_H_FRONT_PORCH : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(24, C_DATA_SIZE);
    constant C_1024x768_H_BACK_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(160, C_DATA_SIZE);
    constant C_1024x768_V_FRONT_PORCH : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(3, C_DATA_SIZE);
    constant C_1024x768_V_BACK_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(29, C_DATA_SIZE);
    constant C_1024x768_H_SYNC_LEN    : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(136, C_DATA_SIZE);
    constant C_1024x768_V_SYNC_LEN    : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(6, C_DATA_SIZE);
    constant C_1024x768_H_LEN         : unsigned((C_DATA_SIZE - 1) downto 0) := C_1024x768_H_ACTIVE + C_1024x768_H_FRONT_PORCH +
                                                                        C_1024x768_H_BACK_PORCH + C_1024x768_H_SYNC_LEN;
    constant C_1024x768_V_LEN : unsigned((C_DATA_SIZE - 1) downto 0) := C_1024x768_V_ACTIVE + C_1024x768_V_FRONT_PORCH +
                                                                        C_1024x768_V_BACK_PORCH + C_1024x768_V_SYNC_LEN;
    constant C_1024x768_H_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    constant C_1024x768_V_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    -- VGA 1024x600
    constant C_1024x600_H_ACTIVE      : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(1024, C_DATA_SIZE);
    constant C_1024x600_V_ACTIVE      : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(600, C_DATA_SIZE);
    constant C_1024x600_H_FRONT_PORCH : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(160, C_DATA_SIZE);
    constant C_1024x600_H_BACK_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(140, C_DATA_SIZE);
    constant C_1024x600_V_FRONT_PORCH : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(12, C_DATA_SIZE);
    constant C_1024x600_V_BACK_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(20, C_DATA_SIZE);
    constant C_1024x600_H_SYNC_LEN    : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(20, C_DATA_SIZE);
    constant C_1024x600_V_SYNC_LEN    : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(3, C_DATA_SIZE);
    constant C_1024x600_H_LEN         : unsigned((C_DATA_SIZE - 1) downto 0) := C_1024x600_H_ACTIVE + C_1024x600_H_FRONT_PORCH +
                                                                        C_1024x600_H_BACK_PORCH + C_1024x600_H_SYNC_LEN;
    constant C_1024x600_V_LEN : unsigned((C_DATA_SIZE - 1) downto 0) := C_1024x600_V_ACTIVE + C_1024x600_V_FRONT_PORCH +
                                                                        C_1024x600_V_BACK_PORCH + C_1024x600_V_SYNC_LEN;
    constant C_1024x600_H_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    constant C_1024x600_V_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    -- VGA 800x600
    constant C_800x600_H_ACTIVE       : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(800, C_DATA_SIZE);
    constant C_800x600_V_ACTIVE       : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(600, C_DATA_SIZE);
    constant C_800x600_H_FRONT_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(40, C_DATA_SIZE);
    constant C_800x600_H_BACK_PORCH   : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(88, C_DATA_SIZE);
    constant C_800x600_V_FRONT_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(1, C_DATA_SIZE);
    constant C_800x600_V_BACK_PORCH   : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(23, C_DATA_SIZE);
    constant C_800x600_H_SYNC_LEN     : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(128, C_DATA_SIZE);
    constant C_800x600_V_SYNC_LEN     : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(4, C_DATA_SIZE);
    constant C_800x600_H_LEN          : unsigned((C_DATA_SIZE - 1) downto 0) := C_800x600_H_ACTIVE + C_800x600_H_FRONT_PORCH +
                                                                       C_800x600_H_BACK_PORCH + C_800x600_H_SYNC_LEN;
    constant C_800x600_V_LEN : unsigned((C_DATA_SIZE - 1) downto 0) := C_800x600_V_ACTIVE + C_800x600_V_FRONT_PORCH +
                                                                       C_800x600_V_BACK_PORCH + C_800x600_V_SYNC_LEN;
    constant C_800x600_H_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    constant C_800x600_V_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    -- VGA 640x480
    constant C_640x480_H_ACTIVE      : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(640, C_DATA_SIZE);
    constant C_640x480_V_ACTIVE      : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(480, C_DATA_SIZE);
    constant C_640x480_H_FRONT_PORCH : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(16, C_DATA_SIZE);
    constant C_640x480_H_BACK_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(48, C_DATA_SIZE);
    constant C_640x480_V_FRONT_PORCH : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(10, C_DATA_SIZE);
    constant C_640x480_V_BACK_PORCH  : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(33, C_DATA_SIZE);
    constant C_640x480_H_SYNC_LEN    : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(96, C_DATA_SIZE);
    constant C_640x480_V_SYNC_LEN    : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(2, C_DATA_SIZE);
    constant C_640x480_H_LEN         : unsigned((C_DATA_SIZE - 1) downto 0) := C_640x480_H_ACTIVE + C_640x480_H_FRONT_PORCH +
                                                                       C_640x480_H_BACK_PORCH + C_640x480_H_SYNC_LEN;
    constant C_640x480_V_LEN : unsigned((C_DATA_SIZE - 1) downto 0) := C_640x480_V_ACTIVE + C_640x480_V_FRONT_PORCH +
                                                                       C_640x480_V_BACK_PORCH + C_640x480_V_SYNC_LEN;
    constant C_640x480_H_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);
    constant C_640x480_V_SYNC_ACTIVE : unsigned((C_DATA_SIZE - 1) downto 0) := to_unsigned(0, C_DATA_SIZE);


    type t_VgaSync is record
        HSyncxS : std_logic;
        VSyncxS : std_logic;
    end record t_vgaSync;

    type t_VgaPixel is record
        RedxD   : std_logic_vector((C_PIXEL_SIZE - 1) downto 0);
        GreenxD : std_logic_vector((C_PIXEL_SIZE - 1) downto 0);
        BluexD  : std_logic_vector((C_PIXEL_SIZE - 1) downto 0);
    end record t_vgaPixel;

    type t_Vga is record
        VgaSyncxS  : t_VgaSync;
        VgaPixelxD : t_VgaPixel;
    end record t_Vga;

    constant C_NO_VGASYNC  : t_VgaSync := (HSyncxS => '0', VSyncxS => '0');
    constant C_SET_VGASYNC : t_VgaSync := (HSyncxS => '1', VSyncxS => '1');
    constant C_NO_VGAPIXEL : t_VgaPixel := (RedxD   => (others => '0'),
                                            GreenxD => (others => '0'),
                                            BluexD  => (others => '0'));
    constant C_NO_VGA : t_Vga := (VgaSyncxS  => C_NO_VGASYNC,
                                  VgaPixelxD => C_NO_VGAPIXEL);

    type t_HdmiSourceIn is record
        HdmiTxHpdxS : std_logic;
    end record t_HdmiSourceIn;

    constant C_NO_HDMI_SOURCE_IN : t_HdmiSourceIn := (HdmiTxHpdxS => '0');

    type t_HdmiSourceOut is record
        HdmiTxRsclxS : std_logic;
        HdmiTxClkPxS : std_logic;
        HdmiTxClkNxS : std_logic;
        HdmiTxPxD    : std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
        HdmiTxNxD    : std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
    end record t_HdmiSourceOut;

    constant C_NO_HDMI_SOURCE_OUT : t_HdmiSourceOut := (HdmiTxRsclxS => '0',
                                                        HdmiTxClkPxS => '0',
                                                        HdmiTxClkNxS => '0',
                                                        HdmiTxPxD    => (others => '0'),
                                                        HdmiTxNxD    => (others => '0'));

    type t_HdmiSourceInOut is record
        HdmiTxRsdaxS : std_logic;
        HdmiTxCecxS  : std_logic;
    end record t_HdmiSourceInOut;

    constant C_NO_HDMI_SOURCE_INOUT : t_HdmiSourceInOut := (HdmiTxRsdaxS => 'Z',
                                                            HdmiTxCecxS  => 'Z');

    type t_HdmiSource is record
        HdmiSourceInxS    : t_HdmiSourceIn;
        HdmiSourceOutxD   : t_HdmiSourceOut;
        HdmiSourceInOutxS : t_HdmiSourceInOut;
    end record t_HdmiSource;

    constant C_NO_HDMI_SOURCE : t_HdmiSource := (HdmiSourceInxS    => C_NO_HDMI_SOURCE_IN,
                                                 HdmiSourceOutxD   => C_NO_HDMI_SOURCE_OUT,
                                                 HdmiSourceInOutxS => C_NO_HDMI_SOURCE_INOUT);

    constant C_COLOR_BLACK : t_VgaPixel := C_NO_VGAPIXEL;
    constant C_COLOR_RED : t_VgaPixel := (RedxD   => (others => '1'),
                                          GreenxD => (others => '0'),
                                          BluexD  => (others => '0'));
    constant C_COLOR_GREEN : t_VgaPixel := (RedxD   => (others => '0'),
                                            GreenxD => (others => '1'),
                                            BluexD  => (others => '0'));
    constant C_COLOR_BLUE : t_VgaPixel := (RedxD   => (others => '0'),
                                           GreenxD => (others => '0'),
                                           BluexD  => (others => '1'));
    constant C_COLOR_YELLOW : t_VgaPixel := (RedxD   => (others => '1'),
                                             GreenxD => (others => '1'),
                                             BluexD  => (others => '1'));
    constant C_COLOR_MAGENTA : t_VgaPixel := (RedxD   => (others => '1'),
                                              GreenxD => (others => '0'),
                                              BluexD  => (others => '1'));
    constant C_COLOR_CYAN : t_VgaPixel := (RedxD   => (others => '0'),
                                           GreenxD => (others => '1'),
                                           BluexD  => (others => '1'));
    constant C_COLOR_GRAY : t_VgaPixel := (RedxD   => x"60",
                                           GreenxD => x"60",
                                           BluexD  => x"60");
    constant C_COLOR_WHITE : t_VgaPixel := (RedxD   => (others => '1'),
                                            GreenxD => (others => '1'),
                                            BluexD  => (others => '1'));

    type t_VgaConfig is record
        HActivexD     : unsigned((C_DATA_SIZE - 1) downto 0);
        VActivexD     : unsigned((C_DATA_SIZE - 1) downto 0);
        HFrontPorchxD : unsigned((C_DATA_SIZE - 1) downto 0);
        HBackPorchxD  : unsigned((C_DATA_SIZE - 1) downto 0);
        VFrontPorchxD : unsigned((C_DATA_SIZE - 1) downto 0);
        VBackPorchxD  : unsigned((C_DATA_SIZE - 1) downto 0);
        HSyncLenxD    : unsigned((C_DATA_SIZE - 1) downto 0);
        VSyncLenxD    : unsigned((C_DATA_SIZE - 1) downto 0);
        HLenxD        : unsigned((C_DATA_SIZE - 1) downto 0);
        VLenxD        : unsigned((C_DATA_SIZE - 1) downto 0);
        HSyncActivexD : unsigned((C_DATA_SIZE - 1) downto 0);
        VSyncActivexD : unsigned((C_DATA_SIZE - 1) downto 0);
    end record t_VgaConfig;

    constant C_NO_VGACONFIG : t_VgaConfig := (HActivexD     => (others => '0'),
                                              VActivexD     => (others => '0'),
                                              HFrontPorchxD => (others => '0'),
                                              HBackPorchxD  => (others => '0'),
                                              VFrontPorchxD => (others => '0'),
                                              VBackPorchxD  => (others => '0'),
                                              HSyncLenxD    => (others => '0'),
                                              VSyncLenxD    => (others => '0'),
                                              HLenxD        => (others => '0'),
                                              VLenxD        => (others => '0'),
                                              HSyncActivexD => (others => '0'),
                                              VSyncActivexD => (others => '0'));
    constant C_1024x768_VGACONFIG : t_VgaConfig := (HActivexD     => C_1024x768_H_ACTIVE,
                                                    VActivexD     => C_1024x768_V_ACTIVE,
                                                    HFrontPorchxD => C_1024x768_H_FRONT_PORCH,
                                                    HBackPorchxD  => C_1024x768_H_BACK_PORCH,
                                                    VFrontPorchxD => C_1024x768_V_FRONT_PORCH,
                                                    VBackPorchxD  => C_1024x768_V_BACK_PORCH,
                                                    HSyncLenxD    => C_1024x768_H_SYNC_LEN,
                                                    VSyncLenxD    => C_1024x768_V_SYNC_LEN,
                                                    HLenxD        => C_1024x768_H_LEN,
                                                    VLenxD        => C_1024x768_V_LEN,
                                                    HSyncActivexD => C_1024x768_H_SYNC_ACTIVE,
                                                    VSyncActivexD => C_1024x768_V_SYNC_ACTIVE);
    constant C_1024x600_VGACONFIG : t_VgaConfig := (HActivexD     => C_1024x600_H_ACTIVE,
                                                    VActivexD     => C_1024x600_V_ACTIVE,
                                                    HFrontPorchxD => C_1024x600_H_FRONT_PORCH,
                                                    HBackPorchxD  => C_1024x600_H_BACK_PORCH,
                                                    VFrontPorchxD => C_1024x600_V_FRONT_PORCH,
                                                    VBackPorchxD  => C_1024x600_V_BACK_PORCH,
                                                    HSyncLenxD    => C_1024x600_H_SYNC_LEN,
                                                    VSyncLenxD    => C_1024x600_V_SYNC_LEN,
                                                    HLenxD        => C_1024x600_H_LEN,
                                                    VLenxD        => C_1024x600_V_LEN,
                                                    HSyncActivexD => C_1024x600_H_SYNC_ACTIVE,
                                                    VSyncActivexD => C_1024x600_V_SYNC_ACTIVE);
    constant C_800x600_VGACONFIG : t_VgaConfig := (HActivexD     => C_800x600_H_ACTIVE,
                                                   VActivexD     => C_800x600_V_ACTIVE,
                                                   HFrontPorchxD => C_800x600_H_FRONT_PORCH,
                                                   HBackPorchxD  => C_800x600_H_BACK_PORCH,
                                                   VFrontPorchxD => C_800x600_V_FRONT_PORCH,
                                                   VBackPorchxD  => C_800x600_V_BACK_PORCH,
                                                   HSyncLenxD    => C_800x600_H_SYNC_LEN,
                                                   VSyncLenxD    => C_800x600_V_SYNC_LEN,
                                                   HLenxD        => C_800x600_H_LEN,
                                                   VLenxD        => C_800x600_V_LEN,
                                                   HSyncActivexD => C_800x600_H_SYNC_ACTIVE,
                                                   VSyncActivexD => C_800x600_V_SYNC_ACTIVE);
    constant C_640x480_VGACONFIG : t_VgaConfig := (HActivexD     => C_640x480_H_ACTIVE,
                                                   VActivexD     => C_640x480_V_ACTIVE,
                                                   HFrontPorchxD => C_640x480_H_FRONT_PORCH,
                                                   HBackPorchxD  => C_640x480_H_BACK_PORCH,
                                                   VFrontPorchxD => C_640x480_V_FRONT_PORCH,
                                                   VBackPorchxD  => C_640x480_V_BACK_PORCH,
                                                   HSyncLenxD    => C_640x480_H_SYNC_LEN,
                                                   VSyncLenxD    => C_640x480_V_SYNC_LEN,
                                                   HLenxD        => C_640x480_H_LEN,
                                                   VLenxD        => C_640x480_V_LEN,
                                                   HSyncActivexD => C_640x480_H_SYNC_ACTIVE,
                                                   VSyncActivexD => C_640x480_V_SYNC_ACTIVE);
    -- constant C_DEFAULT_VGACONFIG : t_VgaConfig := C_640x480_VGACONFIG;
    -- constant C_DEFAULT_VGACONFIG : t_VgaConfig := C_800x600_VGACONFIG;
    constant C_DEFAULT_VGACONFIG : t_VgaConfig := C_1024x600_VGACONFIG;
    -- constant C_DEFAULT_VGACONFIG : t_VgaConfig := C_1024x768_VGACONFIG;

end package hdmi_interface_pkg;
