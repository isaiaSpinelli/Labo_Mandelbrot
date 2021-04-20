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
-- Module Name: ublaze_pinout - rtl
-- Target Device: Mandelbrot xc7a200tsbg484-1
-- Tool version: 2018.2
-- Description: Microblaze Pinout
--
-- Last update: 2019-02-20
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity ublaze_pinout is

    generic (
        C_GPIO_SIZE      : integer := 8;
        C_AXI4_DATA_SIZE : integer := 32;
        C_AXI4_ADDR_SIZE : integer := 12);

    port (
        SysClk100MhzxCI : in  std_logic;
        ResetxRNI       : in  std_logic;
        BtnCxSI         : in  std_logic;
        LedxDO          : out std_logic_vector((C_GPIO_SIZE - 1) downto 0));

end entity ublaze_pinout;

architecture rtl of ublaze_pinout is

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

    -- Signals
    signal UserClkxC                             : std_logic                                         := '0';
    signal PllLockedxS                           : std_logic                                         := '0';
    signal PllNotLockedxS                        : std_logic                                         := '1';
    signal GpioxD                                : std_logic_vector((C_GPIO_SIZE - 1) downto 0)      := (others => '0');
    signal LedxD                                 : std_logic_vector((C_GPIO_SIZE - 1) downto 0)      := (others => '0');
    -- Register Bank Signals
    signal WrDataxD                              : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal WrAddrxD                              : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal WrValidxS                             : std_logic                                         := '0';
    signal RdDataxD                              : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal RdAddrxD                              : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal RdValidxS                             : std_logic                                         := '0';
    -- Interrupt Signals
    signal InterruptxS                           : std_logic                                         := '0';
    -- Register Signals
    signal InterruptRegPortxDP                   : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor1RegPortxDP                  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor2RegPortxDP                  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor3RegPortxDP                  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal InterruptRegPortxDN                   : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor1RegPortxDN                  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor2RegPortxDN                  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    signal FlagColor3RegPortxDN                  : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0) := (others => '0');
    -- Debug Attributes
    -- Attributes Declaration
    attribute keep                               : string;
    attribute mark_debug                         : string;
    -- Attributes Specification
    attribute keep of InterruptRegPortxDP        : signal is "true";
    attribute mark_debug of InterruptRegPortxDP  : signal is "true";
    attribute keep of FlagColor1RegPortxDP       : signal is "true";
    attribute mark_debug of FlagColor1RegPortxDP : signal is "true";
    attribute keep of FlagColor2RegPortxDP       : signal is "true";
    attribute mark_debug of FlagColor2RegPortxDP : signal is "true";
    attribute keep of FlagColor3RegPortxDP       : signal is "true";
    attribute mark_debug of FlagColor3RegPortxDP : signal is "true";

begin  -- architecture rtl

    -- Asynchronous statements

    IOEntityxB : block is
    begin  -- block IOEntityxB

        LedOutxAS : LedxDO <= LedxD;

    end block IOEntityxB;

    -- Synchronous statements

    UblazeSoCxB : block is
    begin  -- block UblazeCorexB

        -- For User Active High Reset
        PllNotLockedxAS : PllNotLockedxS <= not PllLockedxS;

        UBlazeSoCxI : entity work.ublaze_core
            generic map (
                C_GPIO_SIZE      => C_GPIO_SIZE,
                C_AXI4_DATA_SIZE => C_AXI4_DATA_SIZE,
                C_AXI4_ADDR_SIZE => C_AXI4_ADDR_SIZE)
            port map (
                SysClkxCI    => SysClk100MhzxCI,
                UserClkxCO   => UserClkxC,
                ResetxRNI    => ResetxRNI,
                PllLockedxSO => PllLockedxS,
                GpioxDO      => GpioxD,
                WrDataxDO    => WrDataxD,
                WrAddrxDO    => WrAddrxD,
                WrValidxSO   => WrValidxS,
                RdDataxDI    => RdDataxD,
                RdAddrxDO    => RdAddrxD,
                RdValidxSO   => RdValidxS,
                InterruptxSI => InterruptxS);

    end block UblazeSoCxB;

    LedsBufxB : block is
    begin  -- block LedsBufxB

        LedsBufVectxG : for i in 0 to (C_GPIO_SIZE - 1) generate

            LedFDRExI : FDRE
                generic map (
                    INIT => '0')
                port map (
                    Q  => LedxD(i),
                    C  => UserClkxC,
                    CE => '1',
                    R  => PllNotLockedxS,  -- Rst
                    D  => GpioxD(i));

        end generate LedsBufVectxG;

    end block LedsBufxB;

    InterruptBufxB : block is
    begin  -- block InterruptxB

        InterruptFDRExI : FDRE
            generic map (
                INIT => '0')
            port map (
                Q  => InterruptxS,
                C  => UserClkxC,
                CE => '1',
                R  => PllNotLockedxS,   -- Rst
                D  => BtnCxSI);

    end block InterruptBufxB;

    RegBankxB : block is
    begin  -- block RegBankxB

        WriteRegPortxP : process (FlagColor1RegPortxDP, FlagColor2RegPortxDP,
                                  FlagColor3RegPortxDP, InterruptRegPortxDP,
                                  WrAddrxD, WrDataxD, WrValidxS) is
        begin  -- process WriteRegPortxP
            InterruptRegPortxDN  <= InterruptRegPortxDP;
            FlagColor1RegPortxDN <= FlagColor1RegPortxDP;
            FlagColor2RegPortxDN <= FlagColor2RegPortxDP;
            FlagColor3RegPortxDN <= FlagColor3RegPortxDP;

            if WrValidxS = '1' then
                case WrAddrxD is
                    when x"000" => InterruptRegPortxDN  <= WrDataxD;
                    when x"004" => InterruptRegPortxDN  <= InterruptRegPortxDP or WrDataxD;
                    when x"008" => InterruptRegPortxDN  <= InterruptRegPortxDP and not WrDataxD;
                    when x"00C" => FlagColor1RegPortxDN <= WrDataxD;
                    when x"010" => FlagColor2RegPortxDN <= WrDataxD;
                    when x"014" => FlagColor3RegPortxDN <= WrDataxD;
                    when others => null;
                end case;
            end if;
        end process WriteRegPortxP;

        ReadRegPortxP : process (PllNotLockedxS, UserClkxC) is
        begin  -- process ReadRegPortxP
            if PllNotLockedxS = '1' then
                RdDataxD <= (others => '0');
            elsif rising_edge(UserClkxC) then
                RdDataxD <= (others => '0');

                if RdValidxS = '1' then
                    case RdAddrxD is
                        when x"000" => RdDataxD <= InterruptRegPortxDP;
                        when x"00C" => RdDataxD <= FlagColor1RegPortxDP;
                        when x"010" => RdDataxD <= FlagColor2RegPortxDP;
                        when x"014" => RdDataxD <= FlagColor3RegPortxDP;
                        when others => RdDataxD <= (others => '0');
                    end case;
                end if;
            end if;
        end process ReadRegPortxP;

        RegBankxP : process (PllNotLockedxS, UserClkxC) is
        begin  -- process RegBankxP
            if PllNotLockedxS = '1' then
                InterruptRegPortxDP  <= x"000000aa";
                FlagColor1RegPortxDP <= x"000000bb";
                FlagColor2RegPortxDP <= x"000000cc";
                FlagColor3RegPortxDP <= x"000000dd";
            elsif rising_edge(UserClkxC) then
                InterruptRegPortxDP  <= InterruptRegPortxDN;
                FlagColor1RegPortxDP <= FlagColor1RegPortxDN;
                FlagColor2RegPortxDP <= FlagColor2RegPortxDN;
                FlagColor3RegPortxDP <= FlagColor3RegPortxDN;
            end if;
        end process RegBankxP;

    end block RegBankxB;

end architecture rtl;
