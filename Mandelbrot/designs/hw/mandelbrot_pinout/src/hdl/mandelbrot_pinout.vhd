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
-- Module Name: mandelbrot_pinout - rtl
-- Target Device: All
-- Tool version: 2018.3
-- Description: Mandelbrot Pinout
--
-- Revisions  :
-- Date        Version  Author  Description
-- 25.02.2019   0.0      SCJ      -
-- 08.06.2021   0.1      ISS      finish
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.hdmi_interface_pkg.all;
-- use work.config.all;

entity mandelbrot_pinout is

    generic (
        C_CHANNEL_NUMBER : integer := 4;
        C_HDMI_LATENCY   : integer := 0;
        C_GPIO_SIZE      : integer := 8;
        C_AXI4_DATA_SIZE : integer := 32;
        C_AXI4_ADDR_SIZE : integer := 12);

    port (
        -- Clock and Reset Active Low
        ClkSys100MhzxCI : in    std_logic;
        ResetxRNI       : in    std_logic;
        -- Leds
        LedxDO          : out   std_logic_vector((C_GPIO_SIZE - 1) downto 0);
        -- Buttons
        -- BtnCxSI         : in    std_logic;
        -- HDMI
        HdmiTxRsclxSO   : out   std_logic;
        HdmiTxRsdaxSIO  : inout std_logic;
        HdmiTxHpdxSI    : in    std_logic;
        HdmiTxCecxSIO   : inout std_logic;
        HdmiTxClkPxSO   : out   std_logic;
        HdmiTxClkNxSO   : out   std_logic;
        HdmiTxPxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
        HdmiTxNxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));

end entity mandelbrot_pinout;

architecture rtl of mandelbrot_pinout is

    -- Constants
    constant MAX_ITER : integer := 100;

    ---------------------------------------------------------------------------
    -- Resolution configuration
    ---------------------------------------------------------------------------
    -- Possible resolutions
    --
    -- 1024x768
    -- 1024x600
    -- 800x600
    -- 640x480

    constant C_VGA_CONFIG : t_VgaConfig := C_1024x768_VGACONFIG;
    --constant C_VGA_CONFIG : t_VgaConfig := C_1024x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_800x600_VGACONFIG;
    -- constant C_VGA_CONFIG : t_VgaConfig := C_640x480_VGACONFIG;

    constant C_RESOLUTION : string := "1024x768";
    --constant C_RESOLUTION : string := "1024x600";
    -- constant C_RESOLUTION : string := "800x600";
    -- constant C_RESOLUTION : string := "640x480";

    constant C_DATA_SIZE                        : integer               := 16;
    constant C_PIXEL_SIZE                       : integer               := 8;
    constant C_BRAM_VIDEO_MEMORY_ADDR_SIZE      : integer               := 20;
    constant C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE : integer               := 10;
    constant C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE  : integer               := 10;
    constant C_BRAM_VIDEO_MEMORY_DATA_SIZE      : integer               := 9;
    constant C_CDC_TYPE                         : integer range 0 to 2  := 1;
    constant C_RESET_STATE                      : integer range 0 to 1  := 0;
    constant C_SINGLE_BIT                       : integer range 0 to 1  := 1;
    constant C_FLOP_INPUT                       : integer range 0 to 1  := 1;
    constant C_VECTOR_WIDTH                     : integer range 0 to 32 := 2;
    constant C_MTBF_STAGES                      : integer range 0 to 6  := 5;
    constant C_ALMOST_FULL_LEVEL                : integer               := 948;
    constant C_ALMOST_EMPTY_LEVEL               : integer               := 76;
    constant C_FIFO_DATA_SIZE                   : integer               := 32;
    constant C_FIFO_PARITY_SIZE                 : integer               := 4;
    constant C_OUTPUT_BUFFER                    : boolean               := false;

    -- Components

    component ublaze_core is
        generic (
            C_GPIO_SIZE      : integer;
            C_AXI4_DATA_SIZE : integer;
            C_AXI4_ADDR_SIZE : integer);
        port (
            SysClkxCI    : in  std_logic;
            UserClkxCO   : out std_logic;
            ResetxRNI    : in  std_logic;
            PllLockedxSO : out std_logic;
            GpioxDO      : out std_logic_vector((C_GPIO_SIZE - 1) downto 0);
            WrDataxDO    : out std_logic_vector (31 downto 0);
            WrAddrxDO    : out std_logic_vector (11 downto 0);
            WrValidxSO   : out std_logic;
            RdDataxDI    : in  std_logic_vector (31 downto 0);
            RdAddrxDO    : out std_logic_vector (11 downto 0);
            RdValidxSO   : out std_logic;
            InterruptxSI : in  std_logic);
    end component ublaze_core;

    component hdmi is
        generic (
            C_CHANNEL_NUMBER : integer;
            C_DATA_SIZE      : integer;
            C_PIXEL_SIZE     : integer;
            C_HDMI_LATENCY   : integer;
            C_VGA_CONFIG     : t_VgaConfig;
            C_RESOLUTION     : string);
        port (
            ClkSys100MhzxCI : in    std_logic;
            RstxRI          : in    std_logic;
            PllLockedxSO    : out   std_logic;
            ClkVgaxCO       : out   std_logic;
            HCountxDO       : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDO       : out   std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSO        : out   std_logic;
            DataxDI         : in    std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            HdmiTxRsclxSO   : out   std_logic;
            HdmiTxRsdaxSIO  : inout std_logic;
            HdmiTxHpdxSI    : in    std_logic;
            HdmiTxCecxSIO   : inout std_logic;
            HdmiTxClkPxSO   : out   std_logic;
            HdmiTxClkNxSO   : out   std_logic;
            HdmiTxPxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0);
            HdmiTxNxDO      : out   std_logic_vector((C_CHANNEL_NUMBER - 2) downto 0));
    end component hdmi;

     component clk_mandelbrot
         port(
             ClkMandelxCO    : out std_logic;
             reset           : in  std_logic;
             PllLockedxSO    : out std_logic;
             ClkSys100MhzxCI : in  std_logic);
     end component;

    component image_generator is
        generic (
            C_DATA_SIZE  : integer;
            C_PIXEL_SIZE : integer;
            C_VGA_CONFIG : t_VgaConfig);
        port (
            ClkVgaxCI    : in  std_logic;
            RstxRAI      : in  std_logic;
            PllLockedxSI : in  std_logic;
            HCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VCountxDI    : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            VidOnxSI     : in  std_logic;
            DataxDO      : out std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
            Color1xDI    : in  std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0));
    end component image_generator;

     component bram_video_memory_wauto_dauto_rdclk1_wrclk1
         port (
             clka  : in  std_logic;
             wea   : in  std_logic_vector(0 downto 0);
             addra : in  std_logic_vector(19 downto 0);
             dina  : in  std_logic_vector(8 downto 0);
             douta : out std_logic_vector(8 downto 0);
             clkb  : in  std_logic;
             web   : in  std_logic_vector(0 downto 0);
             addrb : in  std_logic_vector(19 downto 0);
             dinb  : in  std_logic_vector(8 downto 0);
             doutb : out std_logic_vector(8 downto 0));
     end component;
     
     
     component c_gen is
        generic (
            C_FXP_SIZE   : integer ;
            C_X_SIZE     : integer ;
            C_Y_SIZE     : integer ;
            C_SCREEN_RES : integer );
        port (
            ClkxC         : in  std_logic;
            RstxRA        : in  std_logic;
            ZoomInxSI     : in  std_logic;
            ZoomOutxSI    : in  std_logic;
            CRealxDO      : out std_logic_vector((C_FXP_SIZE - 1) downto 0);
            CImaginaryxDO : out std_logic_vector((C_FXP_SIZE - 1) downto 0);
            XScreenxDO    : out std_logic_vector((C_SCREEN_RES - 1) downto 0);
            YScreenxDO    : out std_logic_vector((C_SCREEN_RES - 1) downto 0));
    end component c_gen;
    
    component mss_cgen_calcul is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               ready : in STD_LOGIC;
               start : out STD_LOGIC;
               nextValue : out STD_LOGIC);
    end component mss_cgen_calcul;
    
    component mandelbrot_calculator is
        generic (   
            comma       : integer; -- nombre de bits apr?s la virgule
            max_iter    : integer;
            SIZE        : integer);
        Port ( 
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            ready : out STD_LOGIC;
            start : in STD_LOGIC;
            finished : out STD_LOGIC;
            c_real : in STD_LOGIC_VECTOR (SIZE-1 downto 0);
            c_imaginary : in STD_LOGIC_VECTOR (SIZE-1 downto 0);
            z_real : out STD_LOGIC_VECTOR (SIZE-1 downto 0);
            z_imaginary : out STD_LOGIC_VECTOR (SIZE-1 downto 0);
            iterations : out STD_LOGIC_VECTOR (SIZE-1 downto 0));
    end component mandelbrot_calculator;

    component fifo_regport
        port (
            wr_clk : in  std_logic;
            wr_rst : in  std_logic;
            rd_clk : in  std_logic;
            rd_rst : in  std_logic;
            din    : in  std_logic_vector(31 downto 0);
            wr_en  : in  std_logic;
            rd_en  : in  std_logic;
            dout   : out std_logic_vector(31 downto 0);
            full   : out std_logic;
            empty  : out std_logic);
    end component;


    -- Signals

    -- Clocks
    signal ClkVgaxC             : std_logic                                         := '0';
    signal ClkMandelxC          : std_logic;
    signal UBlazeUserClkxC      : std_logic                                         := '0';
    -- Reset
    signal ResetxR              : std_logic                                         := '0';
    -- Pll Locked
     signal PllLockedxS          : std_logic                                         := '0';
     signal PllLockedxD          : std_logic_vector(0 downto 0)                      := (others => '0');
     signal PllNotLockedxS       : std_logic                                         := '0';
    signal HdmiPllLockedxS      : std_logic                                         := '0';
    signal HdmiPllNotLockedxS   : std_logic                                         := '0';
    signal UBlazePllLockedxS    : std_logic                                         := '0';
    signal UBlazePllNotLockedxS : std_logic                                         := '0';
    -- VGA
    signal HCountxD             : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal VCountxD             : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal VidOnxS              : std_logic;
    -- Others
    signal DataImGen2HDMIxD     : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
     signal DataImGen2BramMVxD         : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
     signal DataBramMV2HdmixD          : std_logic_vector(((C_PIXEL_SIZE * 3) - 1) downto 0);
    signal HdmiSourcexD         : t_HdmiSource                                      := C_NO_HDMI_SOURCE;
     signal BramVideoMemoryWriteAddrxD : std_logic_vector((C_BRAM_VIDEO_MEMORY_ADDR_SIZE - 1) downto 0) := (others => '0');
     signal BramVideoMemoryReadAddrxD  : std_logic_vector((C_BRAM_VIDEO_MEMORY_ADDR_SIZE - 1) downto 0);
     signal BramVideoMemoryWriteDataxD : std_logic_vector((C_BRAM_VIDEO_MEMORY_DATA_SIZE - 1) downto 0);
     signal BramVideoMemoryReadDataxD  : std_logic_vector((C_BRAM_VIDEO_MEMORY_DATA_SIZE - 1) downto 0);
    -- signal BtnCInterruptxS      : std_logic                                         := '0';
    -- signal BtnCxD               : std_logic_vector(3 downto 0)                      := (others => '0');
    -- signal BtnCRisexS           : std_logic                                         := '0';
    -- signal BtnCFallxS           : std_logic                                         := '0';
    -- AXI4 Lite To Register Bank Signals
    signal WrDataxD             : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal WrAddrxD             : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal WrValidxS            : std_logic                                         := '0';
    signal RdDataxD             : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal RdAddrxD             : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal RdValidxS            : std_logic                                         := '0';
    signal WrValidDelayedxS     : std_logic                                         := '0';
    signal RdValidFlagColor1xS  : std_logic                                         := '0';
    signal RdEmptyFlagColor1xS  : std_logic                                         := '0';
    signal RdDataFlagColor1xDP  : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0) := (others => '0');
    signal RdDataFlagColor1xDN  : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0) := (others => '0');
    signal RdEnFlagColor1xS     : std_logic                                         := '0';
    -- Register Bank
    signal InterruptRegPortxDP  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor1RegPortxDP : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor2RegPortxDP : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor3RegPortxDP : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal InterruptRegPortxDN  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor1RegPortxDN : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor2RegPortxDN : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor3RegPortxDN : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    
    
    signal CReal_s              : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal CImaginary_s         : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal XScreen_s            : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal YScreen_s            : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    
    signal nextValue_s              : std_logic  ;
  
    signal ready_s              : std_logic  ;
    signal start_s              : std_logic  := '0';
    signal finished_s           : std_logic  ;
    signal z_real_s             : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    signal z_imaginary_s        : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    -- TODO : no need C_DATA_SIZE bits
    signal iterations_s         : std_logic_vector((C_DATA_SIZE - 1) downto 0);
    
    
    

begin  -- architecture rtl


    IOPinoutxB : block is
    begin  -- block IOPinoutxB

        ResetxAS      : ResetxR                                 <= not ResetxRNI;
        HdmiTxRsclxAS : HdmiTxRsclxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS;
        HdmiTxRsdaxAS : HdmiTxRsdaxSIO                          <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS;
        HdmiTxHpdxAS  : HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS <= HdmiTxHpdxSI;
        HdmiTxCecxAS  : HdmiTxCecxSIO                           <= HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS;
        HdmiTxClkPxAS : HdmiTxClkPxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS;
        HdmiTxClkNxAS : HdmiTxClkNxSO                           <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS;
        HdmiTxPxAS    : HdmiTxPxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD;
        HdmiTxNxAS    : HdmiTxNxDO                              <= HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD;

    end block IOPinoutxB;

    -- VGA HDMI Clock Domain
    ---------------------------------------------------------------------------

    VgaHdmiCDxB : block is
    begin  -- block VgaHdmiCDxB

                                        
         DataBramMV2HdmixAS : DataBramMV2HdmixD <= BramVideoMemoryReadDataxD(C_BRAM_VIDEO_MEMORY_DATA_SIZE-3 downto 0) & '0' &
                                                   BramVideoMemoryReadDataxD(C_BRAM_VIDEO_MEMORY_DATA_SIZE-3 downto 0) & '0' &
                                                   BramVideoMemoryReadDataxD(C_BRAM_VIDEO_MEMORY_DATA_SIZE-3 downto 0) & '0';
                                                   

         BramVMRdAddrxAS : BramVideoMemoryReadAddrxD <= VCountxD((C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE - 1) downto 0) &
                                                        HCountxD((C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE - 1) downto 0);

        HdmiPllNotLockedxAS : HdmiPllNotLockedxS <= not HdmiPllLockedxS;

        HdmixI : entity work.hdmi
            generic map (
                C_CHANNEL_NUMBER => C_CHANNEL_NUMBER,
                C_DATA_SIZE      => C_DATA_SIZE,
                C_PIXEL_SIZE     => C_PIXEL_SIZE,
                C_HDMI_LATENCY   => C_HDMI_LATENCY,
                C_VGA_CONFIG     => C_VGA_CONFIG,
                C_RESOLUTION     => C_RESOLUTION)
            port map (
                ClkSys100MhzxCI => ClkSys100MhzxCI,
                RstxRI          => ResetxR,
                PllLockedxSO    => HdmiPllLockedxS,
                ClkVgaxCO       => ClkVgaxC,
                HCountxDO       => HCountxD,
                VCountxDO       => VCountxD,
                VidOnxSO        => open,           --open, VidOnxS
                DataxDI         => DataBramMV2HdmixD,  --DataBramMV2HdmixD, DataImGen2HDMIxD
                HdmiTxRsclxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxRsclxS,
                HdmiTxRsdaxSIO  => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxRsdaxS,
                HdmiTxHpdxSI    => HdmiSourcexD.HdmiSourceInxS.HdmiTxHpdxS,
                HdmiTxCecxSIO   => HdmiSourcexD.HdmiSourceInOutxS.HdmiTxCecxS,
                HdmiTxClkPxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkPxS,
                HdmiTxClkNxSO   => HdmiSourcexD.HdmiSourceOutxD.HdmiTxClkNxS,
                HdmiTxPxDO      => HdmiSourcexD.HdmiSourceOutxD.HdmiTxPxD,
                HdmiTxNxDO      => HdmiSourcexD.HdmiSourceOutxD.HdmiTxNxD);

    end block VgaHdmiCDxB;

    -- VGA HDMI To FPGA User Clock Domain Crossing
    ---------------------------------------------------------------------------

    VgaHdmiToFpgaUserCDCxB : block is
    begin  -- block VgaHdmiToFpgaUserCDCxB

         BramVideoMemoryxI : bram_video_memory_wauto_dauto_rdclk1_wrclk1
             port map (
                 -- Port A (Write)
                 clka  => ClkMandelxC,
                 wea(0)   => finished_s, -- PllLockedxD or  wea(0)   => finished_s
                 addra => BramVideoMemoryWriteAddrxD,
                 dina  => BramVideoMemoryWriteDataxD, -- BramVideoMemoryWriteDataxD
                 douta => open,
                 -- Port B (Read)
                 clkb  => ClkVgaxC,
                 web   => (others => '0'),
                 addrb => BramVideoMemoryReadAddrxD,
                 dinb  => (others => '0'),
                 doutb => BramVideoMemoryReadDataxD);

    end block VgaHdmiToFpgaUserCDCxB;

    -- FPGA User Clock Domain
    ---------------------------------------------------------------------------

    FpgaUserCDxB : block is

         signal ClkSys100MhzBufgxC : std_logic                                    := '0';
         signal HCountIntxD        : std_logic_vector((C_DATA_SIZE - 1) downto 0) := std_logic_vector(C_VGA_CONFIG.HActivexD - 1);
         signal VCountIntxD        : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');

    begin  -- block FpgaUserCDxB

         PllNotLockedxAS : PllNotLockedxS <= not PllLockedxS;
         PllLockedxAS    : PllLockedxD(0) <= PllLockedxS;

 
             -- RGB
            BramVideoMemoryWriteDataxD <= iterations_s(C_BRAM_VIDEO_MEMORY_DATA_SIZE-1 downto 0);
                              
                                                   
            BramVMWrAddrxAS : BramVideoMemoryWriteAddrxD <= std_logic_vector(unsigned(YScreen_s((C_BRAM_VIDEO_MEMORY_HIGH_ADDR_SIZE - 1) downto 0) & 
                                                                            XScreen_s((C_BRAM_VIDEO_MEMORY_LOW_ADDR_SIZE - 1) downto 0)));
                                                         
         BUFGClkSysToClkMandelxI : BUFG
             port map (
                 O => ClkSys100MhzBufgxC,
                 I => ClkSys100MhzxCI);

         ClkMandelbrotxI : clk_mandelbrot
             port map (
                 ClkMandelxCO    => ClkMandelxC,
                 reset           => ResetxR,
                 PllLockedxSO    => PllLockedxS,
                 ClkSys100MhzxCI => ClkSys100MhzBufgxC);

        ImageGeneratorxI : entity work.image_generator
            generic map (
                C_DATA_SIZE  => C_DATA_SIZE,
                C_PIXEL_SIZE => C_PIXEL_SIZE,
                C_VGA_CONFIG => C_VGA_CONFIG)
            port map (
                ClkVgaxCI    => ClkMandelxC ,            --ClkMandelxC,     ClkVgaxC
                RstxRAI      => PllNotLockedxS,  --PllNotLockedxS,      HdmiPllNotLockedxS
                PllLockedxSI => PllLockedxD(0),     --PllLockedxD(0),      HdmiPllLockedxS
                HCountxDI    => HCountIntxD,            --HCountIntxD,         HCountxD
                VCountxDI    => VCountIntxD,            --VCountIntxD,         VCountxD
                VidOnxSI     => '1',             --'1',                 VidOnxS
                DataxDO      => DataImGen2BramMVxD,    --DataImGen2BramMVxD,  DataImGen2HDMIxD
                Color1xDI    => RdDataFlagColor1xDP(((C_PIXEL_SIZE * 3) - 1) downto 0));
                
        c_gen : entity work.c_gen
            generic map (
                C_FXP_SIZE   => C_DATA_SIZE,
                C_X_SIZE     => 1024 , -- TODO change with constante
                C_Y_SIZE     => 768 ,  -- TODO change with constante
                C_SCREEN_RES => C_DATA_SIZE  )  -- TODO what res ? C_PIXEL_SIZE ou 11 ..
            port map (
                ClkxC         => ClkMandelxC ,
                RstxRA        => PllNotLockedxS ,
                ZoomInxSI     => '0' , 
                ZoomOutxSI    => '0' , 
                nextValue     => nextValue_s,
                CRealxDO      => CReal_s ,
                CImaginaryxDO => CImaginary_s ,
                XScreenxDO    => XScreen_s ,
                YScreenxDO    => YScreen_s);
                
                
                
                
                
        mss_cgen_calcul : entity work.mss_cgen_calcul
            port map (
                clk             => ClkMandelxC ,
                rst             => PllNotLockedxS ,
                ready           => ready_s , 
                start           => start_s , 
                nextValue       => nextValue_s);
                
                
                
        mandelbrot_calculator : entity work.mandelbrot_calculator
            generic map (
                comma           => 12,
                max_iter        => MAX_ITER , 
                SIZE            => C_DATA_SIZE  )  
            port map (
                clk             => ClkMandelxC ,
                rst             => PllNotLockedxS ,
                ready           => ready_s , 
                start           => start_s ,
                finished        => finished_s ,
                c_real          => CReal_s ,
                c_imaginary     => CImaginary_s ,
                z_real          => z_real_s ,
                z_imaginary     => z_imaginary_s ,
                iterations      => iterations_s);

            
         HVCountIntxP : process (all) is
         begin  -- process HVCountxP

             if PllNotLockedxS = '1' then
                 HCountIntxD <= (others => '0');
                 VCountIntxD <= (others => '0');
             elsif rising_edge(ClkMandelxC) then
                 HCountIntxD <= HCountIntxD;
                 VCountIntxD <= VCountIntxD;

                 if unsigned(HCountIntxD) = (C_VGA_CONFIG.HActivexD - 1) then
                     HCountIntxD <= (others => '0');

                     if unsigned(VCountIntxD) = (C_VGA_CONFIG.VActivexD - 1) then
                         VCountIntxD <= (others => '0');
                     else
                         VCountIntxD <= std_logic_vector(unsigned(VCountIntxD) + 1);
                     end if;
                 else
                     HCountIntxD <= std_logic_vector(unsigned(HCountIntxD) + 1);
                 end if;
             end if;

         end process HVCountIntxP;

    end block FpgaUserCDxB;


end architecture rtl;
