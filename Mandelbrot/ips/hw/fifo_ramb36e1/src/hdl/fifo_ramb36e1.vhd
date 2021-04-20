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
-- Module Name: fifo_ramb36e1 - behavioural
-- Target Device: All
-- Tool version: 2018.3
-- Description: Fifo with One Ram Block (36 [Kbits], true dual port)
--
-- Last update: 2019-02-15
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity fifo_ramb36e1 is
    generic (
        C_ALMOST_FULL_LEVEL  : integer := 948;
        C_ALMOST_EMPTY_LEVEL : integer := 76;
        C_FIFO_DATA_SIZE     : integer := 32;
        C_FIFO_PARITY_SIZE   : integer := 4;
        C_OUTPUT_BUFFER      : boolean := false);

    port (
        -- Port A (Write Interface)
        WrClkxCI         : in  std_logic;
        WrRstxRI         : in  std_logic;
        WrEnxSI          : in  std_logic;
        WrDataxDI        : in  std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0);
        WrAlmostFullxSO  : out std_logic;
        WrFullxSO        : out std_logic;
        -- Port B (Read Interface)
        RdClkxCI         : in  std_logic;
        RdRstxRI         : in  std_logic;
        RdEnxSI          : in  std_logic;
        RdDataxDO        : out std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0);
        RdValidxSO       : out std_logic;
        RdChkParityxDO   : out std_logic_vector((C_FIFO_PARITY_SIZE - 1) downto 0);
        RdAlmostEmptyxSO : out std_logic;
        RdEmptyxSO       : out std_logic);

end entity fifo_ramb36e1;

architecture behavioral of fifo_ramb36e1 is

    -- Types and constants
    ---------------------------------------------------------------------------
    constant C_RAMB36E1_DATA_SIZE            : integer := 32;
    constant C_RAMB36E1_BYTE_SIZE            : integer := 8;
    constant C_RAMB36E1_PARITY_SIZE          : integer := 4;
    constant C_RAMB36E1_WORD_SIZE            : integer := C_RAMB36E1_DATA_SIZE + C_RAMB36E1_PARITY_SIZE;
    constant C_RAMB36E1_PTR_SIZE             : integer := 1;
    constant C_RAMB36E1_PARITY_TYPE          : string  := "odd";
    constant C_RAMB36E1_ADDR_SIZE            : integer := 11;
    constant C_RAMB36E1_MEMORY_CELLS         : integer := 32864;
    constant C_RAMB36E1_DEPTH                : integer := 1024;
    constant C_RAMB36E1_PORTAB_RW_WIDTH_SIZE : integer := 36;

    type t_RAMB36E1 is record
        DataOutputxD    : std_logic_vector((C_RAMB36E1_DATA_SIZE - 1) downto 0);
        ParityOutputxD  : std_logic_vector((C_RAMB36E1_PARITY_SIZE - 1) downto 0);
        DataInputxD     : std_logic_vector((C_RAMB36E1_DATA_SIZE - 1) downto 0);
        ParityInputxD   : std_logic_vector((C_RAMB36E1_PARITY_SIZE - 1) downto 0);
        AddrxD          : std_logic_vector((C_RAMB36E1_ADDR_SIZE - 1) downto 0);
        ClkxC           : std_logic;
        EnablexS        : std_logic;
        RegEnablexS     : std_logic;
        SetResetxR      : std_logic;
        RegSetResetxR   : std_logic;
        WriteEnablexS   : std_logic;
        CascadeOutputxS : std_logic;
        CascadeInputxS  : std_logic;
    end record t_RAMB36E1;

    constant C_NO_RAMB36E1 : t_RAMB36E1 :=
        (DataOutputxD    => (others => '0'),
         ParityOutputxD  => (others => '0'),
         DataInputxD     => (others => '0'),
         ParityInputxD   => (others => '0'),
         AddrxD          => (others => '0'),
         ClkxC           => '0',
         EnablexS        => '0',
         RegEnablexS     => '0',
         SetResetxR      => '0',
         RegSetResetxR   => '0',
         WriteEnablexS   => '0',
         CascadeOutputxS => '0',
         CascadeInputxS  => '0');

    constant C_RAMB36E1_ECC_PARITY_SIZE    : integer := 8;
    constant C_RAMB36E1_ECC_READ_ADDR_SIZE : integer := 9;

    type t_ECC_RAMB36E1 is record
        DoubleBitErrorxS       : std_logic;
        ECCParityxD            : std_logic_vector((C_RAMB36E1_ECC_PARITY_SIZE - 1) downto 0);
        ECCReadAddrxD          : std_logic_vector((C_RAMB36E1_ECC_READ_ADDR_SIZE - 1) downto 0);
        SingleBitErrorxS       : std_logic;
        InjectDoubleBitErrorxS : std_logic;
        InjectSingleBitErrorxS : std_logic;
    end record t_ECC_RAMB36E1;

    constant C_NO_ECC_RAMB36E1 : t_ECC_RAMB36E1 :=
        (DoubleBitErrorxS       => '0',
         ECCParityxD            => (others => '0'),
         ECCReadAddrxD          => (others => '0'),
         SingleBitErrorxS       => '0',
         InjectDoubleBitErrorxS => '0',
         InjectSingleBitErrorxS => '0');

    -- Components
    ---------------------------------------------------------------------------
    component parity_generator is
        generic (
            C_DATA_SIZE   : integer;
            C_PARITY_TYPE : string);
        port (
            DataxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
            ParityxSO : out std_logic);
    end component parity_generator;

    -- Signals
    ---------------------------------------------------------------------------
    -- Write
    signal PortAxD           : t_RAMB36E1                                              := C_NO_RAMB36E1;
    -- Read
    signal PortBxD           : t_RAMB36E1                                              := C_NO_RAMB36E1;
    -- Others
    signal ChkParityOutputxD : std_logic_vector((C_RAMB36E1_PARITY_SIZE - 1) downto 0) := (others => '0');
    signal ECCxD             : t_ECC_RAMB36E1                                          := C_NO_ECC_RAMB36E1;
    signal RdValidxS         : std_logic                                               := '0';
    signal RdEmptyxS         : std_logic                                               := '0';
    signal RdEnxS            : std_logic                                               := '0';
    signal RdAlmostEmptyxS   : std_logic                                               := '0';
    signal WrFullxS          : std_logic                                               := '0';
    signal WrAlmostFullxS    : std_logic                                               := '0';
    signal PortBAddrIncxD    : std_logic_vector((C_RAMB36E1_ADDR_SIZE - 1) downto 0)   := (others => '0');
    -- Temp. signal for output registers.    
    signal RegRdDataxD       : std_logic_vector((C_RAMB36E1_DATA_SIZE - 1) downto 0)   := (others => '0');
    signal RegRdValidxS      : std_logic                                               := '0';
    signal RegRdEnxS         : std_logic                                               := '0';
    signal RegRdEmptyxS      : std_logic                                               := '0';

begin  -- architecture behavioral

    -- Asynchronous statements

    assert (C_FIFO_DATA_SIZE = C_RAMB36E1_DATA_SIZE)
        report "The value C_FIFO_DATA_SIZE must be the same as the value C_RAMB36E1_DATA_SIZE" severity failure;

    assert (C_FIFO_PARITY_SIZE = C_RAMB36E1_PARITY_SIZE)
        report "The value C_FIFO_PARITY_SIZE mist be the same as the value C_RAMB36E1_PARITY_SIZE" severity failure;

    assert C_RAMB36E1_PARITY_TYPE = "even" or C_RAMB36E1_PARITY_TYPE = "odd"
        report "The value of C_RAMB36E1_PARITY_TYPE is false" severity failure;

    assert (C_ALMOST_FULL_LEVEL >= 0) and (C_ALMOST_FULL_LEVEL <= (C_RAMB36E1_DEPTH - 1))
        report "The value C_ALMOST_FULL_LEVEL must be between 0 and 1023" severity failure;

    assert (C_ALMOST_EMPTY_LEVEL >= 0) and (C_ALMOST_EMPTY_LEVEL <= (C_RAMB36E1_DEPTH - 1))
        report "The value C_ALMOST_EMPTY_LEVEL must be between 0 and 1023" severity failure;

    -- Debug Block
    ---------------------------------------------------------------------------
    -- DebugxB : block is

    --     -- Attributes
    --     ---------------------------------------------------------------------------
    --     attribute keep                               : string;
    --     attribute mark_debug                         : string;
    --     -- Debug signals
    --     signal DebugFifoRdPtrxD                      : std_logic_vector((C_RAMB36E1_ADDR_SIZE - 2) downto 0) := (others => '0');
    --     signal DebugFifoWrPtrxD                      : std_logic_vector((C_RAMB36E1_ADDR_SIZE - 2) downto 0) := (others => '0');
    --     signal DebugFifoLoopRdBitxS                  : std_logic                                             := '0';
    --     signal DebugFifoLoopWrBitxS                  : std_logic                                             := '0';
    --     signal DebugFifoRdDataxD                     : std_logic_vector((C_FIFO_DATA_SIZE - 1) downto 0)     := (others => '0');
    --     attribute keep of DebugFifoRdPtrxD           : signal is "true";
    --     attribute mark_debug of DebugFifoRdPtrxD     : signal is "true";
    --     attribute keep of DebugFifoWrPtrxD           : signal is "true";
    --     attribute mark_debug of DebugFifoWrPtrxD     : signal is "true";
    --     attribute keep of DebugFifoLoopRdBitxS       : signal is "true";
    --     attribute mark_debug of DebugFifoLoopRdBitxS : signal is "true";
    --     attribute keep of DebugFifoLoopWrBitxS       : signal is "true";
    --     attribute mark_debug of DebugFifoLoopWrBitxS : signal is "true";
    --     attribute keep of DebugFifoRdDataxD          : signal is "true";
    --     attribute mark_debug of DebugFifoRdDataxD    : signal is "true";

    -- begin  -- block DebugxB

    --     DebugFifoWrPtrxAS     : DebugFifoWrPtrxD     <= PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0);
    --     DebugFifoLoopWrBitxAS : DebugFifoLoopWrBitxS <= PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1);
    --     DebugFifoRdPtrxAS     : DebugFifoRdPtrxD     <= PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0);
    --     DebugFifoLoopRdBitxAS : DebugFifoLoopRdBitxS <= PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1);
    --     DebugFifoRdDataxAS    : DebugFifoRdDataxD    <= PortBxD.DataOutputxD;

    -- end block DebugxB;

    -- IO Top Block
    ---------------------------------------------------------------------------
    IOTopxB : block is

        -- Block Signals
        signal RdDataInputxD   : std_logic_vector((C_RAMB36E1_DATA_SIZE - 1) downto 0) := (others => '0');
        signal RdDataOutputxD  : std_logic_vector((C_RAMB36E1_DATA_SIZE - 1) downto 0) := (others => '0');
        signal RdValidInputxS  : std_logic                                             := '0';
        signal RdValidOutputxS : std_logic                                             := '0';
        signal RdEnInputxS     : std_logic                                             := '0';
        signal RdEnOutputxS    : std_logic                                             := '0';

    begin  -- block IOTopxB

        RdChkParityOutxAS   : RdChkParityxDO      <= ChkParityOutputxD;
        WrDataOutxAS        : PortAxD.DataInputxD <= WrDataxDI;
        RdEmptyOutxAS       : RdEmptyxSO          <= RdEmptyxS;
        WrFullOutxAS        : WrFullxSO           <= WrFullxS;
        RdAlmostEmptyOutxAS : RdAlmostEmptyxSO    <= RdAlmostEmptyxS;
        WrAlmostFullOutxAS  : WrAlmostFullxSO     <= WrAlmostFullxS;

        OutputBufferFalsexG : if C_OUTPUT_BUFFER = false generate

            RdDataOutxAS  : RdDataxDO  <= PortBxD.DataOutputxD;
            RdValidOutxAS : RdValidxSO <= RdValidxS;
            RdEnInxAS     : RdEnxS     <= RdEnxSI;

        end generate OutputBufferFalsexG;

        OutputBufferTruexG : if C_OUTPUT_BUFFER = true generate

            RdDataMuxxAS  : RdDataInputxD  <= PortBxD.DataOutputxD when RdEnOutputxS = '1' else RdDataOutputxD;
            RdValidMuxxAS : RdValidInputxS <= RdValidxS            when RdEnOutputxS = '1' else RdValidOutputxS;
            RdEnInputxAS  : RdEnInputxS    <= RdEnxSI;

            RdDataOutRegxG : for i in 0 to (C_RAMB36E1_DATA_SIZE - 1) generate

                RdDataOutFDRExI : FDRE
                    generic map (
                        INIT => '0')
                    port map (
                        Q  => RdDataOutputxD(i),
                        C  => RdClkxCI,
                        CE => '1',
                        R  => RdRstxRI,
                        D  => RdDataInputxD(i));

            end generate RdDataOutRegxG;

            RdValidOutFDRExI : FDRE
                generic map (
                    INIT => '0')
                port map (
                    Q  => RdValidOutputxS,
                    C  => RdClkxCI,
                    CE => '1',
                    R  => RdRstxRI,
                    D  => RdValidInputxS);

            RdEnInFDRExI : FDRE
                generic map (
                    INIT => '0')
                port map (
                    Q  => RdEnOutputxS,
                    C  => RdClkxCI,
                    CE => '1',
                    R  => RdRstxRI,
                    D  => RdEnInputxS);

        end generate OutputBufferTruexG;

        -- Control RdEmpty and WrFull Flags
        FifoCtrlFlagsxB : block is
        begin  -- block FifoCtrlFlagsxB

            RdEmptyxAS : RdEmptyxS
                <= '1' when
                (PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) = PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) and
                (PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0) = PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)) else
                '0';
            WrFullxAS : WrFullxS
                <= '1' when
                (PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) /= PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) and
                (PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0) = PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)) else
                '0';
            RdAlmostEmptyxAS : RdAlmostEmptyxS
                <= '1' when
                (((PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) = PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) and
                  (to_integer(unsigned(PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0))) -
                   to_integer(unsigned(PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)))) <=
                  C_ALMOST_EMPTY_LEVEL) or
                 ((PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) /= PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) and
                  (C_RAMB36E1_DEPTH -
                   (to_integer(unsigned(PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0))) -
                    to_integer(unsigned(PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0))))) <=
                  C_ALMOST_EMPTY_LEVEL)) else
                '0';
            WrAlmostFullxAS : WrAlmostFullxS
                <= '1' when
                (((PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) = PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) and
                  (to_integer(unsigned(PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0))) -
                   to_integer(unsigned(PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)))) >=
                  C_ALMOST_FULL_LEVEL) or
                 ((PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) /= PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) and
                  (C_RAMB36E1_DEPTH -
                   (to_integer(unsigned(PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0))) -
                    to_integer(unsigned(PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0))))) >=
                  C_ALMOST_FULL_LEVEL)) else
                '0';

        end block FifoCtrlFlagsxB;

    end block IOTopxB;

    PortABCtrlxB : block is
    begin  -- block PortABCtrlxB

        PortAClkxAS  : PortAxD.ClkxC         <= WrClkxCI;
        PortBClkxAS  : PortBxD.ClkxC         <= RdClkxCI;
        PortARstxAS  : PortAxD.SetResetxR    <= WrRstxRI;
        PortBRstxAS  : PortBxD.SetResetxR    <= RdRstxRI;
        PortAEnxAS   : PortAxD.EnablexS      <= '1';
        PortBEnxAS   : PortBxD.EnablexS      <= '1';
        PortAWrEnxAS : PortAxD.WriteEnablexS <= '0' when
                                                (PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0) = PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)) and
                                                (PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) /= PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) else
                                                WrEnxSI;

    end block PortABCtrlxB;

    -- Parity Processing Block
    ---------------------------------------------------------------------------
    ParityProcessingxB : block is

        -- Block Signals
        -----------------------------------------------------------------------
        signal ReadParityOutputxD : std_logic_vector((C_RAMB36E1_PARITY_SIZE - 1) downto 0) := (others => '0');

    begin  -- block ParityProcessingxB

        -- Write parity for each byte
        WriteParityxG : for i in 0 to (C_RAMB36E1_PARITY_SIZE - 1) generate

            WriteParityGeneratorxI : entity work.parity_generator
                generic map (
                    C_DATA_SIZE   => C_RAMB36E1_BYTE_SIZE,
                    C_PARITY_TYPE => C_RAMB36E1_PARITY_TYPE)
                port map (
                    DataxDI   => PortAxD.DataInputxD((((i + 1) * C_RAMB36E1_BYTE_SIZE) - 1) downto (i * C_RAMB36E1_BYTE_SIZE)),
                    ParityxSO => PortAxD.ParityInputxD(i));

        end generate WriteParityxG;

        -- Read parity for each byte
        ReadParityxG : for i in 0 to (C_RAMB36E1_PARITY_SIZE - 1) generate

            ReadParityGeneratorxI : entity work.parity_generator
                generic map (
                    C_DATA_SIZE   => C_RAMB36E1_BYTE_SIZE,
                    C_PARITY_TYPE => C_RAMB36E1_PARITY_TYPE)
                port map (
                    DataxDI   => PortBxD.DataOutputxD((((i + 1) * C_RAMB36E1_BYTE_SIZE) - 1) downto (i * C_RAMB36E1_BYTE_SIZE)),
                    ParityxSO => ReadParityOutputxD(i));

        end generate ReadParityxG;

        -- Check parity for each byte
        ChkParityxG : for i in 0 to (C_RAMB36E1_PARITY_SIZE - 1) generate

            ChkParityOutputxAS : ChkParityOutputxD(i) <= not (PortBxD.ParityOutputxD(i) xor ReadParityOutputxD(i));

        end generate ChkParityxG;

    end block ParityProcessingxB;

    ----------------------------------------------------------------------------
    -- RAMB36E1: 36K-bit Configurable Synchronous Block RAM
    --           Artix-7
    -- Xilinx HDL Language Template, version 2018.2
    ----------------------------------------------------------------------------
    RAMB36E1xI : RAMB36E1
        generic map (
            -- Address Collision Mode: "PERFORMANCE" or "DELAYED_WRITE" 
            RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
            -- Collision check: Values ("ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE")
            SIM_COLLISION_CHECK       => "ALL",
            -- DOA_REG, DOB_REG: Optional output register (0 or 1)
            DOA_REG                   => 0,
            DOB_REG                   => 0,
            EN_ECC_READ               => false,         -- Enable ECC decoder,
            -- FALSE, TRUE
            EN_ECC_WRITE              => false,         -- Enable ECC encoder,
                                                        -- FALSE, TRUE
            -- INITP_00 to INITP_0F: Initial contents of the parity memory array
            INITP_00                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_01                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_02                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_03                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_04                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_05                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_06                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_07                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_08                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_09                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_0A                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_0B                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_0C                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_0D                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_0E                  => X"0000000000000000000000000000000000000000000000000000000000000000",
            INITP_0F                  => X"0000000000000000000000000000000000000000000000000000000000000000",
                                                        -- INIT_00 to INIT_7F: Initial contents of the data memory array
            INIT_00                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_01                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_02                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_03                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_04                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_05                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_06                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_07                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_08                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_09                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_0A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_0B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_0C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_0D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_0E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_0F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_10                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_11                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_12                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_13                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_14                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_15                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_16                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_17                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_18                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_19                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_1A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_1B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_1C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_1D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_1E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_1F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_20                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_21                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_22                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_23                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_24                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_25                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_26                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_27                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_28                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_29                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_2F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_30                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_31                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_32                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_33                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_34                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_35                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_36                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_37                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_38                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_39                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_3A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_3B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_3C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_3D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_3E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_3F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_40                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_41                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_42                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_43                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_44                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_45                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_46                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_47                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_48                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_49                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_4A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_4B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_4C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_4D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_4E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_4F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_50                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_51                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_52                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_53                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_54                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_55                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_56                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_57                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_58                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_59                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_5A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_5B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_5C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_5D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_5E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_5F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_60                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_61                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_62                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_63                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_64                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_65                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_66                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_67                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_68                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_69                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_6A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_6B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_6C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_6D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_6E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_6F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_70                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_71                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_72                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_73                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_74                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_75                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_76                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_77                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_78                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_79                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_7A                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_7B                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_7C                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_7D                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_7E                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            INIT_7F                   => X"0000000000000000000000000000000000000000000000000000000000000000",
            -- INIT_A, INIT_B: Initial values on output ports
            INIT_A                    => X"000000000",
            INIT_B                    => X"000000000",
            -- Initialization File: RAM initialization file
            INIT_FILE                 => "NONE",
            -- RAM Mode: "SDP" or "TDP" 
            RAM_MODE                  => "TDP",
            -- RAM_EXTENSION_A, RAM_EXTENSION_B: Selects cascade mode ("UPPER", "LOWER", or "NONE")
            RAM_EXTENSION_A           => "NONE",
            RAM_EXTENSION_B           => "NONE",
            -- READ_WIDTH_A/B, WRITE_WIDTH_A/B: Read/write width per port
            READ_WIDTH_A              => C_RAMB36E1_PORTAB_RW_WIDTH_SIZE,  -- 0-72
            READ_WIDTH_B              => C_RAMB36E1_PORTAB_RW_WIDTH_SIZE,  -- 0-36
            WRITE_WIDTH_A             => C_RAMB36E1_PORTAB_RW_WIDTH_SIZE,  -- 0-36
            WRITE_WIDTH_B             => C_RAMB36E1_PORTAB_RW_WIDTH_SIZE,  -- 0-72
            -- RSTREG_PRIORITY_A, RSTREG_PRIORITY_B: Reset or enable priority ("RSTREG" or "REGCE")
            RSTREG_PRIORITY_A         => "RSTREG",
            RSTREG_PRIORITY_B         => "RSTREG",
            -- SRVAL_A, SRVAL_B: Set/reset value for output
            SRVAL_A                   => X"000000000",
            SRVAL_B                   => X"000000000",
            -- Simulation Device: Must be set to "7SERIES" for simulation behavior
            SIM_DEVICE                => "7SERIES",
            -- WriteMode: Value on output upon a write ("WRITE_FIRST", "READ_FIRST", or "NO_CHANGE")
            WRITE_MODE_A              => "WRITE_FIRST",
            WRITE_MODE_B              => "WRITE_FIRST")
        port map (
            -------------------------------------------------------------------
            -- Error Correction Circuitry Ports
            -------------------------------------------------------------------
            -- ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
            DBITERR                  => ECCxD.DoubleBitErrorxS,  -- 1-bit output: Double bit error status
            ECCPARITY                => ECCxD.ECCParityxD,  -- 8-bit output: Generated error correction parity
            RDADDRECC                => ECCxD.ECCReadAddrxD,  -- 9-bit output: ECC read address
            SBITERR                  => ECCxD.SingleBitErrorxS,  -- 1-bit output: Single bit error status
            -- ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
            INJECTDBITERR            => ECCxD.InjectDoubleBitErrorxS,  -- 1-bit input: Inject a double bit error
            INJECTSBITERR            => ECCxD.InjectSingleBitErrorxS,  -- 1-bit input: Inject a single bit error
            -------------------------------------------------------------------
            -- Cascade Port A and B
            -------------------------------------------------------------------
            -- Cascade Signals: 1-bit (each) output: BRAM cascade ports (to create 64kx1)
            CASCADEOUTA              => PortAxD.CascadeOutputxS,  -- 1-bit output: A port cascade
            CASCADEOUTB              => PortBxD.CascadeOutputxS,  -- 1-bit output: B port cascade
                                                        -- Cascade Signals: 1-bit (each) input: BRAM cascade ports (to create 64kx1)
            CASCADEINA               => PortAxD.CascadeInputxS,  -- 1-bit input: A port cascade
            CASCADEINB               => PortBxD.CascadeInputxS,  -- 1-bit input: B port cascade
            -------------------------------------------------------------------
            -- Port A
            -------------------------------------------------------------------
            -- Port A Data: 32-bit (each) output: Port A data
            DOADO                    => PortAxD.DataOutputxD,  -- 32-bit output: A port data/LSB data
            DOPADOP                  => PortAxD.ParityOutputxD,  -- 4-bit output: A port parity/LSB parity
            -- Port A Data: 32-bit (each) input: Port A data
            DIADI                    => PortAxD.DataInputxD,  -- 32-bit input: A port data/LSB data
            DIPADIP                  => PortAxD.ParityInputxD,  -- 4-bit input: A port parity/LSB parity
            -- Port A Address/Control Signals: 16-bit (each) input: Port A address and control signals (read port
            -- when RAM_MODE="SDP")
            ADDRARDADDR(4 downto 0)  => (others => '0'),
            ADDRARDADDR(14 downto 5) => PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0),  -- 16-bit input: A port address/Read address
            ADDRARDADDR(15)          => '1',
            CLKARDCLK                => PortAxD.ClkxC,  -- 1-bit input: A port clock/Read clock
            ENARDEN                  => PortAxD.EnablexS,  -- 1-bit input: A port enable/Read enable
            REGCEAREGCE              => PortAxD.RegEnablexS,  -- 1-bit input: A port register enable/Register enable
            RSTRAMARSTRAM            => PortAxD.SetResetxR,  -- 1-bit input: A port set/reset
            RSTREGARSTREG            => PortAxD.RegSetResetxR,  -- 1-bit input: A port register set/reset
            WEA(3)                   => PortAxD.WriteEnablexS,  -- 4-bit input: A port write enable
            WEA(2)                   => PortAxD.WriteEnablexS,
            WEA(1)                   => PortAxD.WriteEnablexS,
            WEA(0)                   => PortAxD.WriteEnablexS,
            -------------------------------------------------------------------
            -- Port B
            -------------------------------------------------------------------
            -- Port B Data: 32-bit (each) output: Port B data
            DOBDO                    => PortBxD.DataOutputxD,  -- 32-bit output: B port data/MSB data
            DOPBDOP                  => PortBxD.ParityOutputxD,  -- 4-bit output: B port parity/MSB parity
            -- Port B Data: 32-bit (each) input: Port B data
            DIBDI                    => PortBxD.DataInputxD,  -- 32-bit input: B port data/MSB data
            DIPBDIP                  => PortBxD.ParityInputxD,  -- 4-bit input: B port parity/MSB parity                 
            -- Port B Address/Control Signals: 16-bit (each) input: Port B address and control signals (write port
            -- when RAM_MODE="SDP")
            ADDRBWRADDR(4 downto 0)  => (others => '0'),
            ADDRBWRADDR(14 downto 5) => PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0),  -- 16-bit input: B port address/Write address
            ADDRBWRADDR(15)          => '1',
            CLKBWRCLK                => PortBxD.ClkxC,  -- 1-bit input: B port clock/Write clock
            ENBWREN                  => PortBxD.EnablexS,  -- 1-bit input: B port enable/Write enable
            REGCEB                   => PortBxD.RegEnablexS,  -- 1-bit input: B port register enable
            RSTRAMB                  => PortBxD.SetResetxR,  -- 1-bit input: B port set/reset
            RSTREGB                  => PortBxD.RegSetResetxR,  -- 1-bit input: B port register set/reset
            WEBWE(7)                 => PortBxD.WriteEnablexS,
            WEBWE(6)                 => PortBxD.WriteEnablexS,
            WEBWE(5)                 => PortBxD.WriteEnablexS,
            WEBWE(4)                 => PortBxD.WriteEnablexS,
            WEBWE(3)                 => PortBxD.WriteEnablexS,
            WEBWE(2)                 => PortBxD.WriteEnablexS,
            WEBWE(1)                 => PortBxD.WriteEnablexS,
            WEBWE(0)                 => PortBxD.WriteEnablexS);  -- 8-bit input: B port write enable/Write enable

    -- Synchronous statements

    -- Write Data Processing
    WritePtrxP : process (WrClkxCI) is
    begin  -- process WritePtrxP
        if rising_edge(WrClkxCI) then
            if WrRstxRI = '1' then
                PortAxD.AddrxD <= (others => '0');
            else
                PortAxD.AddrxD <= PortAxD.AddrxD;

                if WrEnxSI = '1' then
                    if (PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0) = PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)) and
                        (PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) /= PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) then
                        PortAxD.AddrxD <= PortAxD.AddrxD;
                    else
                        PortAxD.AddrxD <= std_logic_vector(unsigned(PortAxD.AddrxD) + C_RAMB36E1_PTR_SIZE);
                    end if;
                end if;
            end if;
        end if;
    end process WritePtrxP;

    -- Read Data Processing
    ReadPtrxP : process (RdClkxCI) is
    begin  -- process ReadPtrxP
        if rising_edge(RdClkxCI) then
            if RdRstxRI = '1' then
                PortBxD.AddrxD <= (others => '0');
                RdValidxS      <= '0';
            else
                PortBxD.AddrxD <= PortBxD.AddrxD;
                RdValidxS      <= '0';

                if RdEnxS = '1' then
                    if (PortAxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0) = PortBxD.AddrxD((C_RAMB36E1_ADDR_SIZE - 2) downto 0)) and
                        (PortAxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1) = PortBxD.AddrxD(C_RAMB36E1_ADDR_SIZE - 1)) then
                        PortBxD.AddrxD <= PortBxD.AddrxD;
                        RdValidxS      <= '0';
                    else
                        PortBxD.AddrxD <= std_logic_vector(unsigned(PortBxD.AddrxD) + C_RAMB36E1_PTR_SIZE);
                        RdValidxS      <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process ReadPtrxP;

end architecture behavioral;
