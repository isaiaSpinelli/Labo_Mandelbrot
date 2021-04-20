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
-- Module Name: axi4lite_sl_if - behavioural
-- Target Device: All
-- Tool version: 2018.2
-- Description: AXI4 Lite Slave Side
--
-- Last update: 2019-02-12
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

entity axi4lite_sl_if is

    generic (
        C_AXI4_ARADDR_SIZE : integer := 32;
        C_AXI4_RDATA_SIZE  : integer := 32;
        C_AXI4_RRESP_SIZE  : integer := 2;
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
        -- Write Channel
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
        -- Read Channel
        -- Read Address Channel
        SAxiARAddrxDI  : in  std_logic_vector((C_AXI4_ARADDR_SIZE - 1) downto 0);
        SAxiARValidxSI : in  std_logic;
        SAxiARReadyxSO : out std_logic;
        -- Read Data Channel
        SAxiRDataxDO   : out std_logic_vector((C_AXI4_RDATA_SIZE - 1) downto 0);
        SAxiRRespxDO   : out std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0);
        SAxiRValidxSO  : out std_logic;
        SAxiRReadyxSI  : in  std_logic;
        -- Signal for Writing in a Register Bank
        WrDataxDO      : out std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
        WrAddrxDO      : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
        WrValidxSO     : out std_logic;
        -- Signal for Reading in a Register Bank
        RdDataxDI      : in  std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
        RdAddrxDO      : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
        RdValidxSO     : out std_logic;
        -- Interrupt Interface
        InterruptxSI   : in  std_logic;
        InterruptxSO   : out std_logic);

end entity axi4lite_sl_if;

architecture rtl of axi4lite_sl_if is

    -- Components
    component axi4lite_wr_chan_sl_if is
        generic (
            C_AXI4_AWADDR_SIZE : integer;
            C_AXI4_WDATA_SIZE  : integer;
            C_AXI4_WSTRB_SIZE  : integer;
            C_AXI4_BRESP_SIZE  : integer;
            C_AXI4_DATA_SIZE   : integer;
            C_AXI4_ADDR_SIZE   : integer);
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
    end component axi4lite_wr_chan_sl_if;

    component axi4lite_rd_chan_sl_if is
        generic (
            C_AXI4_ARADDR_SIZE : integer;
            C_AXI4_RDATA_SIZE  : integer;
            C_AXI4_RRESP_SIZE  : integer;
            C_AXI4_DATA_SIZE   : integer;
            C_AXI4_ADDR_SIZE   : integer);
        port (
            SAxiClkxCI     : in  std_logic;
            SAxiResetxRANI : in  std_logic;
            SAxiARAddrxDI  : in  std_logic_vector((C_AXI4_ARADDR_SIZE - 1) downto 0);
            SAxiARValidxSI : in  std_logic;
            SAxiARReadyxSO : out std_logic;
            SAxiRDataxDO   : out std_logic_vector((C_AXI4_RDATA_SIZE - 1) downto 0);
            SAxiRRespxDO   : out std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0);
            SAxiRValidxSO  : out std_logic;
            SAxiRReadyxSI  : in  std_logic;
            DataxDI        : in  std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
            AddrxDO        : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
            ValidxSO       : out std_logic);
    end component axi4lite_rd_chan_sl_if;

    -- Signals

begin  -- architecture rtl

    -- Asynchronous statements

    assert C_AXI4_RDATA_SIZE = C_AXI4_DATA_SIZE
        report "RDATA and DATA vectors must be the same" severity failure;

    assert C_AXI4_ARADDR_SIZE >= C_AXI4_ADDR_SIZE
        report "ARADDR and ADDR vectors must be the same" severity failure;

    assert C_AXI4_WDATA_SIZE = C_AXI4_DATA_SIZE
        report "WDATA and DATA vectors must be the same" severity failure;

    assert C_AXI4_AWADDR_SIZE >= C_AXI4_ADDR_SIZE
        report "AWADDR and ADDR vectors must be the same" severity failure;

    InterruptxB : block is
    begin  -- block InterruptxB

        InterruptxSO <= InterruptxSI;

    end block InterruptxB;

    -- Synchronous statements

    Axi4LiteSlIfxB : block is
    begin  -- block Axi4LiteSlIfxB

        Axi4LiteWrChanSlIfxI : entity work.axi4lite_wr_chan_sl_if
            generic map (
                C_AXI4_AWADDR_SIZE => C_AXI4_AWADDR_SIZE,
                C_AXI4_WDATA_SIZE  => C_AXI4_WDATA_SIZE,
                C_AXI4_WSTRB_SIZE  => C_AXI4_WSTRB_SIZE,
                C_AXI4_BRESP_SIZE  => C_AXI4_BRESP_SIZE,
                C_AXI4_DATA_SIZE   => C_AXI4_DATA_SIZE,
                C_AXI4_ADDR_SIZE   => C_AXI4_ADDR_SIZE)
            port map (
                -- Clock and Reset
                SAxiClkxCI     => SAxiClkxCI,
                SAxiResetxRANI => SAxiResetxRANI,
                -- Write Address Channel
                SAxiAWAddrxDI  => SAxiAWAddrxDI,
                SAxiAWValidxSI => SAxiAWValidxSI,
                SAxiAWReadyxSO => SAxiAWReadyxSO,
                -- Write Data Channel
                SAxiWDataxDI   => SAxiWDataxDI,
                SAxiWStrbxDI   => SAxiWStrbxDI,
                SAxiWValidxSI  => SAxiWValidxSI,
                SAxiWReadyxSO  => SAxiWReadyxSO,
                -- Write Response Channel
                SAxiBRespxDO   => SAxiBRespxDO,
                SAxiBValidxSO  => SAxiBValidxSO,
                SAxiBReadyxSI  => SAxiBReadyxSI,
                -- Signal for Writing in a Register Bank
                DataxDO        => WrDataxDO,
                AddrxDO        => WrAddrxDO,
                ValidxSO       => WrValidxSO);

        Axi4LiteRdChanSlIfxI : entity work.axi4lite_rd_chan_sl_if
            generic map (
                C_AXI4_ARADDR_SIZE => C_AXI4_ARADDR_SIZE,
                C_AXI4_RDATA_SIZE  => C_AXI4_RDATA_SIZE,
                C_AXI4_RRESP_SIZE  => C_AXI4_RRESP_SIZE,
                C_AXI4_DATA_SIZE   => C_AXI4_DATA_SIZE,
                C_AXI4_ADDR_SIZE   => C_AXI4_ADDR_SIZE)
            port map (
                -- Clock and Reset
                SAxiClkxCI     => SAxiClkxCI,
                SAxiResetxRANI => SAxiResetxRANI,
                -- Read Address Channel
                SAxiARAddrxDI  => SAxiARAddrxDI,
                SAxiARValidxSI => SAxiARValidxSI,
                SAxiARReadyxSO => SAxiARReadyxSO,
                -- Read Data Channel
                SAxiRDataxDO   => SAxiRDataxDO,
                SAxiRRespxDO   => SAxiRRespxDO,
                SAxiRValidxSO  => SAxiRValidxSO,
                SAxiRReadyxSI  => SAxiRReadyxSI,
                -- Signal for Reading in a Register Bank
                DataxDI        => RdDataxDI,
                AddrxDO        => RdAddrxDO,
                ValidxSO       => RdValidxSO);

    end block Axi4LiteSlIfxB;

end architecture rtl;
