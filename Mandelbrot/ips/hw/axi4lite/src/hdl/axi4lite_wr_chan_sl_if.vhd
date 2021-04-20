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
-- Module Name: axi4lite_wr_chan_sl_if - behavioural
-- Target Device: All
-- Tool version: 2018.2
-- Description: AXI4 Lite Write Channel Slave Side
--
-- Last update: 2019-02-25
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

entity axi4lite_wr_chan_sl_if is

    generic (
        C_AXI4_AWADDR_SIZE : integer := 32;
        C_AXI4_WDATA_SIZE  : integer := 32;
        C_AXI4_WSTRB_SIZE  : integer := 4;
        C_AXI4_BRESP_SIZE  : integer := 2;
        C_AXI4_DATA_SIZE   : integer := 32;
        C_AXI4_ADDR_SIZE   : integer := 12);

    port (
        -- Clock and Reset
        SAxiClkxCI     : in  std_logic;
        SAxiResetxRANI : in  std_logic;
        -- Write Address Channel
        SAxiAWAddrxDI  : in  std_logic_vector((C_AXI4_AWADDR_SIZE - 1) downto 0);
        SAxiAWValidxSI : in  std_logic;
        SAxiAWReadyxSO : out std_logic;
        -- Write Data Channel
        SAxiWDataxDI   : in  std_logic_vector((C_AXI4_WDATA_SIZE - 1) downto 0);
        SAxiWStrbxDI   : in  std_logic_vector((C_AXI4_WSTRB_SIZE - 1) downto 0);
        SAxiWValidxSI  : in  std_logic;
        SAxiWReadyxSO  : out std_logic;
        -- Write Response Channel
        SAxiBRespxDO   : out std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0);
        SAxiBValidxSO  : out std_logic;
        SAxiBReadyxSI  : in  std_logic;
        -- Signal for Writing in a Register Bank
        DataxDO        : out std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
        AddrxDO        : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
        ValidxSO       : out std_logic);

end entity axi4lite_wr_chan_sl_if;

architecture behavioural of axi4lite_wr_chan_sl_if is

    -- Constants
    constant C_AXI4_BRESP_OKAY   : std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0) := "00";
    constant C_AXI4_BRESP_EXOKAY : std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0) := "01";
    constant C_AXI4_BRESP_SLVERR : std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0) := "10";
    constant C_AXI4_BRESP_DECERR : std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0) := "11";

    -- Signals
    -- signal SAxiBRespxD   : std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0) := (others => '0');
    signal SAxiBValidxS  : std_logic                                         := '0';
    signal SAxiWReadyxS  : std_logic                                         := '0';
    signal SAxiAWReadyxS : std_logic                                         := '0';
    signal AddrxDN       : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');
    signal AddrxDP       : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0) := (others => '0');

begin  -- architecture behavioural

    -- Asynchronous statements

    assert C_AXI4_WDATA_SIZE = C_AXI4_DATA_SIZE
        report "WDATA and DATA vectors must be the same" severity failure;

    assert C_AXI4_AWADDR_SIZE >= C_AXI4_ADDR_SIZE
        report "AWADDR and ADDR vectors must be the same" severity failure;

    -- DebugxB : block is

    --     -- Debug Signals
    --     signal DebugSAxiAWAddrxD  : std_logic_vector((C_AXI4_AWADDR_SIZE - 1) downto 0) := (others => '0');
    --     signal DebugSAxiAWValidxS : std_logic                                           := '0';
    --     signal DebugSAxiAWReadyxS : std_logic                                           := '0';
    --     signal DebugSAxiWDataxD   : std_logic_vector((C_AXI4_WDATA_SIZE - 1) downto 0)  := (others => '0');
    --     signal DebugSAxiWStrbxD   : std_logic_vector((C_AXI4_WSTRB_SIZE - 1) downto 0)  := (others => '0');
    --     signal DebugSAxiWValidxS  : std_logic                                           := '0';
    --     signal DebugSAxiWReadyxS  : std_logic                                           := '0';
    --     signal DebugSAxiBRespxD   : std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0)  := (others => '0');
    --     signal DebugSAxiBValidxS  : std_logic                                           := '0';
    --     signal DebugSAxiBReadyxS  : std_logic                                           := '0';
    --     signal DebugWrDataxD      : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0)   := (others => '0');
    --     signal DebugWrAddrxD      : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0)   := (others => '0');
    --     signal DebugWrValidxS     : std_logic                                           := '0';

    --     -- Debug Attributes
    --     -- Attributes Declaration
    --     attribute keep                             : string;
    --     attribute mark_debug                       : string;
    --     -- Attributes Specification
    --     attribute keep of DebugSAxiAWAddrxD        : signal is "true";
    --     attribute mark_debug of DebugSAxiAWAddrxD  : signal is "true";
    --     attribute keep of DebugSAxiAWValidxS       : signal is "true";
    --     attribute mark_debug of DebugSAxiAWValidxS : signal is "true";
    --     attribute keep of DebugSAxiAWReadyxS       : signal is "true";
    --     attribute mark_debug of DebugSAxiAWReadyxS : signal is "true";
    --     attribute keep of DebugSAxiWDataxD         : signal is "true";
    --     attribute mark_debug of DebugSAxiWDataxD   : signal is "true";
    --     attribute keep of DebugSAxiWStrbxD         : signal is "true";
    --     attribute mark_debug of DebugSAxiWStrbxD   : signal is "true";
    --     attribute keep of DebugSAxiWValidxS        : signal is "true";
    --     attribute mark_debug of DebugSAxiWValidxS  : signal is "true";
    --     attribute keep of DebugSAxiWReadyxS        : signal is "true";
    --     attribute mark_debug of DebugSAxiWReadyxS  : signal is "true";
    --     attribute keep of DebugSAxiBRespxD         : signal is "true";
    --     attribute mark_debug of DebugSAxiBRespxD   : signal is "true";
    --     attribute keep of DebugSAxiBValidxS        : signal is "true";
    --     attribute mark_debug of DebugSAxiBValidxS  : signal is "true";
    --     attribute keep of DebugSAxiBReadyxS        : signal is "true";
    --     attribute mark_debug of DebugSAxiBReadyxS  : signal is "true";
    --     attribute keep of DebugWrDataxD            : signal is "true";
    --     attribute mark_debug of DebugWrDataxD      : signal is "true";
    --     attribute keep of DebugWrAddrxD            : signal is "true";
    --     attribute mark_debug of DebugWrAddrxD      : signal is "true";
    --     attribute keep of DebugWrValidxS           : signal is "true";
    --     attribute mark_debug of DebugWrValidxS     : signal is "true";

    -- begin  -- block DebugxB

    --     DebugSAxiAWAddrxAS  : DebugSAxiAWAddrxD                              <= SAxiAWAddrxDI;
    --     DebugSAxiAWValidxAS : DebugSAxiAWValidxS                             <= SAxiAWValidxSI;
    --     DebugSAxiAWReadyxAS : DebugSAxiAWReadyxS                             <= SAxiAWReadyxS;
    --     DebugSAxiWDataxAS   : DebugSAxiWDataxD                               <= SAxiWDataxDI;
    --     DebugSAxiWStrbxAS   : DebugSAxiWStrbxD                               <= SAxiWStrbxDI;
    --     DebugSAxiWValidxAS  : DebugSAxiWValidxS                              <= SAxiWValidxSI;
    --     DebugSAxiWReadyxAS  : DebugSAxiWReadyxS                              <= SAxiWReadyxS;
    --     DebugSAxiBRespxAS   : DebugSAxiBRespxD                               <= C_AXI4_BRESP_OKAY;
    --     DebugSAxiBValidxAS  : DebugSAxiBValidxS                              <= SAxiBValidxS;
    --     DebugSAxiBReadyxAS  : DebugSAxiBReadyxS                              <= SAxiBReadyxSI;
    --     DebugWrDataxAS      : DebugWrDataxD                                  <= SAxiWDataxDI;
    --     DebugWrAddrxAS      : DebugWrAddrxD((C_AXI4_ADDR_SIZE - 1) downto 0) <= AddrxDP((C_AXI4_ADDR_SIZE - 1) downto 0);
    --     DebugWrValidxAS     : DebugWrValidxS                                 <= SAxiWValidxSI;

    -- end block DebugxB;

    IOEntityxB : block is
    begin  -- block IOEntityxB

        SAxiBRespxAS   : SAxiBRespxDO                             <= C_AXI4_BRESP_OKAY;
        SAxiBValidxAS  : SAxiBValidxSO                            <= SAxiBValidxS;
        SAxiWReadyxAS  : SAxiWReadyxSO                            <= SAxiWReadyxS;
        SAxiAWReadyxAS : SAxiAWReadyxSO                           <= SAxiAWReadyxS;
        ValidxAS       : ValidxSO                                 <= SAxiWValidxSI;
        DataxAS        : DataxDO                                  <= SAxiWDataxDI;
        AddrOutxAS     : AddrxDO                                  <= AddrxDP;
        AddrxAS        : AddrxDN((C_AXI4_ADDR_SIZE - 1) downto 0) <= SAxiAWAddrxDI((C_AXI4_ADDR_SIZE - 1) downto 0) when
                                                              SAxiAWValidxSI = '1' else
                                                              AddrxDP((C_AXI4_ADDR_SIZE - 1) downto 0);
        -- AddrxAS        : AddrxDO((C_AXI4_ADDR_SIZE - 1) downto 0) <= SAxiAWAddrxDI((C_AXI4_ADDR_SIZE - 1) downto 0);

    end block IOEntityxB;

    -- Synchronous statements

    AddrRegxP : process (SAxiClkxCI, SAxiResetxRANI) is
    begin  -- process AddrRegxP
        if SAxiResetxRANI = '0' then
            AddrxDP <= (others => '0');
        elsif rising_edge(SAxiClkxCI) then
            AddrxDP <= AddrxDN;
        end if;
    end process AddrRegxP;

    WriteAddrChanxP : process (SAxiClkxCI, SAxiResetxRANI) is

        variable StateAfterResetxS : boolean := true;

    begin  -- process WriteAddrChanxP
        if SAxiResetxRANI = '0' then
            SAxiAWReadyxS     <= '0';
            StateAfterResetxS := true;
        elsif rising_edge(SAxiClkxCI) then
            if StateAfterResetxS = true then
                SAxiAWReadyxS     <= '1';
                StateAfterResetxS := false;
            else
                SAxiAWReadyxS <= SAxiAWReadyxS;
            end if;

            if SAxiAWValidxSI = '1' then
                SAxiAWReadyxS <= '0';
            end if;

            if SAxiWValidxSI = '1' then
                SAxiAWReadyxS <= '1';
            end if;
        end if;
    end process WriteAddrChanxP;

    WriteDataChanxP : process (SAxiClkxCI, SAxiResetxRANI) is
    begin  -- process WriteDataChanxP
        if SAxiResetxRANI = '0' then
            SAxiWReadyxS <= '0';
        elsif rising_edge(SAxiClkxCI) then
            SAxiWReadyxS <= SAxiWReadyxS;

            if SAxiAWValidxSI = '1' and SAxiAWReadyxS = '1' then
                SAxiWReadyxS <= '1';
            end if;

            if SAxiWValidxSI = '1' and SAxiWReadyxS = '1' then
                SAxiWReadyxS <= '0';
            end if;
        end if;
    end process WriteDataChanxP;

    WriteRespChanxP : process (SAxiClkxCI, SAxiResetxRANI) is
    begin  -- process WriteRespChanxP
        if SAxiResetxRANI = '0' then
            SAxiBValidxS <= '0';
        elsif rising_edge(SAxiClkxCI) then
            SAxiBValidxS <= SAxiBValidxS;

            if SAxiWValidxSI = '1' and SAxiWReadyxS = '1' then
                SAxiBValidxS <= '1';
            end if;

            if SAxiBValidxS = '1' and SAxiBReadyxSI = '1' then
                SAxiBValidxS <= '0';
            end if;
        end if;
    end process WriteRespChanxP;

end architecture behavioural;
