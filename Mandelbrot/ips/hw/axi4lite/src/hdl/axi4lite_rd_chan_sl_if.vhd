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
-- Module Name: axi4lite_rd_chan_sl_if - behavioural
-- Target Device: All
-- Tool version: 2018.2
-- Description: AXI4 Lite Read Channel Slave Side
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

entity axi4lite_rd_chan_sl_if is

    generic (
        C_AXI4_ARADDR_SIZE : integer := 32;
        C_AXI4_RDATA_SIZE  : integer := 32;
        C_AXI4_RRESP_SIZE  : integer := 2;
        C_AXI4_DATA_SIZE   : integer := 32;
        C_AXI4_ADDR_SIZE   : integer := 12);

    port (
        -- Clock and Reset
        SAxiClkxCI     : in  std_logic;
        SAxiResetxRANI : in  std_logic;
        -- Read Address Channel
        SAxiARAddrxDI  : in  std_logic_vector((C_AXI4_ARADDR_SIZE - 1) downto 0);
        SAxiARValidxSI : in  std_logic;
        SAxiARReadyxSO : out std_logic;
        -- Read Data Channel
        SAxiRDataxDO   : out std_logic_vector((C_AXI4_RDATA_SIZE - 1) downto 0);
        SAxiRRespxDO   : out std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0);
        SAxiRValidxSO  : out std_logic;
        SAxiRReadyxSI  : in  std_logic;
        -- Signal for Reading in a Register Bank
        DataxDI        : in  std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
        AddrxDO        : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
        ValidxSO       : out std_logic);

end entity axi4lite_rd_chan_sl_if;

architecture behavioural of axi4lite_rd_chan_sl_if is

    -- Constants
    constant C_AXI4_RRESP_OKAY   : std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0) := "00";
    constant C_AXI4_RRESP_EXOKAY : std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0) := "01";
    constant C_AXI4_RRESP_SLVERR : std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0) := "10";
    constant C_AXI4_RRESP_DECERR : std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0) := "11";

    -- Signals
    signal SAxiARReadyxS : std_logic := '0';
    signal SAxiRValidxS  : std_logic := '0';
    -- signal SAxiRDataxD   : std_logic_vector((C_AXI4_RDATA_SIZE - 1) downto 0) := (others => '0');
    -- signal SAxiRRespxD   : std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0) := C_AXI4_RRESP_OKAY;

begin  -- architecture behavioural

    -- Asynchronous statements

    assert C_AXI4_RDATA_SIZE = C_AXI4_DATA_SIZE
        report "RDATA and DATA vectors must be the same" severity failure;

    assert C_AXI4_ARADDR_SIZE >= C_AXI4_ADDR_SIZE
        report "ARADDR and ADDR vectors must be the same" severity failure;

    -- DebugxB : block is

    --     -- Debug Signals
    --     signal DebugSAxiARAddrxD  : std_logic_vector((C_AXI4_ARADDR_SIZE - 1) downto 0) := (others => '0');
    --     signal DebugSAxiARValidxS : std_logic                                           := '0';
    --     signal DebugSAxiARReadyxS : std_logic                                           := '0';
    --     signal DebugSAxiRDataxD   : std_logic_vector((C_AXI4_RDATA_SIZE - 1) downto 0)  := (others => '0');
    --     signal DebugSAxiRRespxD   : std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0)  := (others => '0');
    --     signal DebugSAxiRValidxS  : std_logic                                           := '0';
    --     signal DebugSAxiRReadyxS  : std_logic                                           := '0';
    --     signal DebugRdDataxD      : std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0)   := (others => '0');
    --     signal DebugRdAddrxD      : std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0)   := (others => '0');
    --     signal DebugRdValidxS     : std_logic                                           := '0';

    --     -- Debug Attributes
    --     -- Attributes Declaration
    --     attribute keep                             : string;
    --     attribute mark_debug                       : string;
    --     -- Attributes Specification
    --     attribute keep of DebugSAxiARAddrxD        : signal is "true";
    --     attribute mark_debug of DebugSAxiARAddrxD  : signal is "true";
    --     attribute keep of DebugSAxiARValidxS       : signal is "true";
    --     attribute mark_debug of DebugSAxiARValidxS : signal is "true";
    --     attribute keep of DebugSAxiARReadyxS       : signal is "true";
    --     attribute mark_debug of DebugSAxiARReadyxS : signal is "true";
    --     attribute keep of DebugSAxiRDataxD         : signal is "true";
    --     attribute mark_debug of DebugSAxiRDataxD   : signal is "true";
    --     attribute keep of DebugSAxiRRespxD         : signal is "true";
    --     attribute mark_debug of DebugSAxiRRespxD   : signal is "true";
    --     attribute keep of DebugSAxiRValidxS        : signal is "true";
    --     attribute mark_debug of DebugSAxiRValidxS  : signal is "true";
    --     attribute keep of DebugSAxiRReadyxS        : signal is "true";
    --     attribute mark_debug of DebugSAxiRReadyxS  : signal is "true";
    --     attribute keep of DebugRdDataxD            : signal is "true";
    --     attribute mark_debug of DebugRdDataxD      : signal is "true";
    --     attribute keep of DebugRdAddrxD            : signal is "true";
    --     attribute mark_debug of DebugRdAddrxD      : signal is "true";
    --     attribute keep of DebugRdValidxS           : signal is "true";
    --     attribute mark_debug of DebugRdValidxS     : signal is "true";

    -- begin  -- block DebugxB

    --     DebugSAxiARAddrxAS  : DebugSAxiARAddrxD                              <= SAxiARAddrxDI;
    --     DebugSAxiARValidxAS : DebugSAxiARValidxS                             <= SAxiARValidxSI;
    --     DebugSAxiARReadyxAS : DebugSAxiARReadyxS                             <= SAxiARReadyxS;
    --     DebugSAxiRDataxAS   : DebugSAxiRDataxD                               <= DataxDI;
    --     DebugSAxiRRespxAS   : DebugSAxiRRespxD                               <= C_AXI4_RRESP_OKAY;
    --     DebugSAxiRValidxAS  : DebugSAxiRValidxS                              <= SAxiRValidxS;
    --     DebugSAxiRReadyxAS  : DebugSAxiRReadyxS                              <= SAxiRReadyxSI;
    --     DebugDataxAS        : DebugRdDataxD                                  <= DataxDI;
    --     DebugAddrxAS        : DebugRdAddrxD((C_AXI4_ADDR_SIZE - 1) downto 0) <= SAxiARAddrxDI((C_AXI4_ADDR_SIZE - 1) downto 0);
    --     DebugValidxAS       : DebugRdValidxS                                 <= SAxiARValidxSI;

    -- end block DebugxB;

    IOEntityxB : block is
    begin  -- block IOEntityxB

        SAxiARReadyxAS : SAxiARReadyxSO                           <= SAxiARReadyxS;
        SAxiRValidxAS  : SAxiRValidxSO                            <= SAxiRValidxS;
        SAxiRDataxAS   : SAxiRDataxDO                             <= DataxDI;
        ValidxAS       : ValidxSO                                 <= SAxiARValidxSI;  --
        --SAxiRValidxS;
        AddrxAS        : AddrxDO((C_AXI4_ADDR_SIZE - 1) downto 0) <= SAxiARAddrxDI((C_AXI4_ADDR_SIZE - 1) downto 0);
        SAxiRRespxAS   : SAxiRRespxDO                             <= C_AXI4_RRESP_OKAY;

    end block IOEntityxB;

    -- Synchronous statements

    ReadAddrChanxP : process (SAxiClkxCI, SAxiResetxRANI) is

        variable StateAfterResetxS : boolean := true;

    begin  -- process ReadAddrChanxP
        if SAxiResetxRANI = '0' then
            SAxiARReadyxS     <= '0';
            StateAfterResetxS := true;
        elsif rising_edge(SAxiClkxCI) then
            if StateAfterResetxS = true then
                SAxiARReadyxS     <= '1';
                StateAfterResetxS := false;
            else
                SAxiARReadyxS <= SAxiARReadyxS;
            end if;

            if SAxiARValidxSI = '1' then
                SAxiARReadyxS <= '0';
            end if;

            if SAxiARReadyxS <= '0' and SAxiRReadyxSI = '1' then
                SAxiARReadyxS <= '1';
            end if;
        end if;
    end process ReadAddrChanxP;

    ReadDataChanxP : process (SAxiClkxCI, SAxiResetxRANI) is
    begin  -- process ReadDataChanxP
        if SAxiResetxRANI = '0' then
            SAxiRValidxS <= '0';
        elsif rising_edge(SAxiClkxCI) then
            SAxiRValidxS <= SAxiRValidxS;

            if SAxiARValidxSI = '1' and SAxiARReadyxS = '1' then
                SAxiRValidxS <= '1';
            end if;

            if SAxiRValidxS = '1' and SAxiRReadyxSI = '1' then
                SAxiRValidxS <= '0';
            end if;
        end if;
    end process ReadDataChanxP;

end architecture behavioural;
