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
-- Module Name: vga_to_hdmi - rtl
-- Target Device: All
-- Tool version: 2018.3
-- Description: VGA To HDMI
--
-- Last update: 2019-02-14
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.hdmi_interface_pkg.all;

entity vga_to_hdmi is

    generic (
        C_PIXEL_SIZE     : integer := 8;
        C_CHANNEL_NUMBER : integer := 4);

    port (
        ClkVgaxCI      : in    std_logic;
        ClkHdmixCI     : in    std_logic;
        RstxRI         : in    std_logic;
        VgaxDI         : in    t_Vga;
        VidOnxSI       : in    std_logic;
        HdmiSourcexDIO : inout t_HdmiSource);

end entity vga_to_hdmi;

architecture rtl of vga_to_hdmi is

    constant C_TMDS_DATA_SIZE         : integer                                                   := 8;
    constant C_TMDS_ENCODED_DATA_SIZE : integer                                                   := 10;
    constant C_TMDS_ENCODED_DATA_CLK  : std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0) := "0000011111";

    component tmds_encoder is
        generic (
            C_TMDS_DATA_SIZE         : integer;
            C_TMDS_ENCODED_DATA_SIZE : integer);
        port (
            ClkxCI             : in  std_logic;
            TmdsDataxDI        : in  std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0);
            ControlxDI         : in  std_logic_vector(1 downto 0);
            VidOnxSI           : in  std_logic;
            TmdsEncodedDataxDO : out std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0));
    end component tmds_encoder;

    component serializer_10_to_1 is
        generic (
            C_TMDS_ENCODED_DATA_SIZE : integer);
        port (
            ClkVgaxCI         : in  std_logic;
            ClkHdmixCI        : in  std_logic;
            RstxRI            : in  std_logic;
            TmdsDataxDI       : in  std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0);
            TmdsSerialDataxSO : out std_logic);
    end component serializer_10_to_1;

    signal VgaxD                      : t_Vga                                                     := C_NO_VGA;
    signal HdmiSourcexD               : t_HdmiSource                                              := C_NO_HDMI_SOURCE;
    signal SerialDataCh0xS            : std_logic                                                 := '0';
    signal SerialDataCh1xS            : std_logic                                                 := '0';
    signal SerialDataCh2xS            : std_logic                                                 := '0';
    signal SerialDataClkxS            : std_logic                                                 := '0';
    signal TmdsEncodedDataSymbolCh0xD : std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0) := (others => '0');
    signal TmdsEncodedDataSymbolCh1xD : std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0) := (others => '0');
    signal TmdsEncodedDataSymbolCh2xD : std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0) := (others => '0');
    signal TmdsEncodedDataSymbolClkxD : std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0) := C_TMDS_ENCODED_DATA_CLK;

    -- Debug signals

    -- attribute mark_debug                               : string;
    -- attribute mark_debug of TmdsEncodedDataSymbolCh0xD : signal is "true";
    -- attribute mark_debug of TmdsEncodedDataSymbolCh1xD : signal is "true";
    -- attribute mark_debug of TmdsEncodedDataSymbolCh2xD : signal is "true";
    -- attribute mark_debug of TmdsEncodedDataSymbolClkxD : signal is "true";

    -- attribute keep                               : string;
    -- attribute keep of TmdsEncodedDataSymbolCh0xD : signal is "true";
    -- attribute keep of TmdsEncodedDataSymbolCh1xD : signal is "true";
    -- attribute keep of TmdsEncodedDataSymbolCh2xD : signal is "true";
    -- attribute keep of TmdsEncodedDataSymbolClkxD : signal is "true";

begin  -- architecture rtl

    -- Asynchronous statements

    VgaInxB : block is
    begin  -- block VgaInxB
        
        VgaxAS : VgaxD <= VgaxDI;
        
    end block VgaInxB;

    HdmiSourceInOutxB : block is
    begin  -- block HdmiSourceOutxB
        
        HdmiSourceOutxAS   : HdmiSourcexDIO.HdmiSourceOutxD   <= HdmiSourcexD.HdmiSourceOutxD;
        HdmiSourceInxAS    : HdmiSourcexD.HdmiSourceInxS      <= HdmiSourcexDIO.HdmiSourceInxS;
        HdmiSourceInOutxAS : HdmiSourcexDIO.HdmiSourceInOutxS <= HdmiSourcexD.HdmiSourceInOutxS;
        
    end block HdmiSourceInOutxB;

    HdmiSourceI2CxB : block is
    begin  -- block HdmiSourceIOxB
        
        HdmiSourceRsclxAS : HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS   <= '1';
        HdmiSourceRsdaxAS : HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS <= 'Z';
        HdmiSourceCecxAS  : HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS  <= 'Z';
        
    end block HdmiSourceI2CxB;

    -- Synchronous statements

    -- Blue + HSync + VSync
    TmdsEncoderC0xI : entity work.tmds_encoder
        generic map (
            C_TMDS_DATA_SIZE         => C_TMDS_DATA_SIZE,
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkxCI             => ClkVgaxCI,
            TmdsDataxDI        => VgaxD.VgaPixelxD.BluexD,
            ControlxDI(0)      => VgaxD.VgaSyncxS.HSyncxS,
            ControlxDI(1)      => VgaxD.VgaSyncxS.VSyncxS,
            VidOnxSI           => VidOnxSI,
            TmdsEncodedDataxDO => TmdsEncodedDataSymbolCh0xD);

    -- Green
    TmdsEncoderC1xI : entity work.tmds_encoder
        generic map (
            C_TMDS_DATA_SIZE         => C_TMDS_DATA_SIZE,
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkxCI             => ClkVgaxCI,
            TmdsDataxDI        => VgaxD.VgaPixelxD.GreenxD,
            ControlxDI         => (others => '0'),
            VidOnxSI           => VidOnxSI,
            TmdsEncodedDataxDO => TmdsEncodedDataSymbolCh1xD);

    -- Red
    TmdsEncoderC2xI : entity work.tmds_encoder
        generic map (
            C_TMDS_DATA_SIZE         => C_TMDS_DATA_SIZE,
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkxCI             => ClkVgaxCI,
            TmdsDataxDI        => VgaxD.VgaPixelxD.RedxD,
            ControlxDI         => (others => '0'),
            VidOnxSI           => VidOnxSI,
            TmdsEncodedDataxDO => TmdsEncodedDataSymbolCh2xD);

    -- Blue + HSync + VSync
    SerializerChannel0xI : entity work.serializer_10_to_1
        generic map (
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkVgaxCI         => ClkVgaxCI,
            ClkHdmixCI        => ClkHdmixCI,
            RstxRI            => RstxRI,
            TmdsDataxDI       => TmdsEncodedDataSymbolCh0xD,
            TmdsSerialDataxSO => SerialDataCh0xS);

    -- Green
    SerializerChannel1xI : entity work.serializer_10_to_1
        generic map (
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkVgaxCI         => ClkVgaxCI,
            ClkHdmixCI        => ClkHdmixCI,
            RstxRI            => RstxRI,
            TmdsDataxDI       => TmdsEncodedDataSymbolCh1xD,
            TmdsSerialDataxSO => SerialDataCh1xS);

    -- Red
    SerializerChannel2xI : entity work.serializer_10_to_1
        generic map (
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkVgaxCI         => ClkVgaxCI,
            ClkHdmixCI        => ClkHdmixCI,
            RstxRI            => RstxRI,
            TmdsDataxDI       => TmdsEncodedDataSymbolCh2xD,
            TmdsSerialDataxSO => SerialDataCh2xS);

    -- Clock
    SerializerChannel3xI : entity work.serializer_10_to_1
        generic map (
            C_TMDS_ENCODED_DATA_SIZE => C_TMDS_ENCODED_DATA_SIZE)
        port map (
            ClkVgaxCI         => ClkVgaxCI,
            ClkHdmixCI        => ClkHdmixCI,
            RstxRI            => RstxRI,
            TmdsDataxDI       => TmdsEncodedDataSymbolClkxD,
            TmdsSerialDataxSO => SerialDataClkxS);

    OBUFDSHdmiTxCh0xI : OBUFDS
        generic map (
            IOSTANDARD => "TMDS_33",    -- Specify the output I/O standard
            SLEW       => "FAST")       -- Specify the output slew rate
        port map (
            O  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD(0),  -- Diff_p output (connect directly to top-level port)
            OB => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD(0),  -- Diff_n output (connect directly to top-level port)
            I  => SerialDataCh0xS);     -- Buffer input 

    OBUFDSHdmiTxCh1xI : OBUFDS
        generic map (
            IOSTANDARD => "TMDS_33",    -- Specify the output I/O standard
            SLEW       => "FAST")       -- Specify the output slew rate
        port map (
            O  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD(1),  -- Diff_p output (connect directly to top-level port)
            OB => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD(1),  -- Diff_n output (connect directly to top-level port)
            I  => SerialDataCh1xS);     -- Buffer input

    OBUFDSHdmiTxCh2xI : OBUFDS
        generic map (
            IOSTANDARD => "TMDS_33",    -- Specify the output I/O standard
            SLEW       => "FAST")       -- Specify the output slew rate
        port map (
            O  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD(2),  -- Diff_p output (connect directly to top-level port)
            OB => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD(2),  -- Diff_n output (connect directly to top-level port)
            I  => SerialDataCh2xS);     -- Buffer input

    OBUFDSHdmiTxClkxI : OBUFDS
        generic map (
            IOSTANDARD => "TMDS_33",    -- Specify the output I/O standard
            SLEW       => "FAST")       -- Specify the output slew rate
        port map (
            O  => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS,  -- Diff_p output (connect directly to top-level port)
            OB => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS,  -- Diff_n output (connect directly to top-level port)
            I  => SerialDataClkxS);     -- Buffer input 

end architecture rtl;
