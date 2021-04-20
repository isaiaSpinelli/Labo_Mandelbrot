----------------------------------------------------------------------------------
-- Company: hepia // HES-SO
-- Engineer: Laurent Gantel <laurent.gantel@hesge.ch>
-- 
-- Module Name: tb_axi4lite_if - arch 
-- Target Devices: Xilinx Artix7 xc7a100tcsg324-1
-- Tool versions: 2014.2
-- Description: Testbench for the AXI4-Lite interface
--
-- Last update: 2019-02-12
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_axi4lite_if is
end entity tb_axi4lite_if;


architecture testbench of tb_axi4lite_if is

    constant C_DATA_WIDTH : integer := 32;
    constant C_ADDR_WIDTH : integer := 10;

    constant C_AXI4_ARADDR_SIZE : integer := 32;
    constant C_AXI4_RDATA_SIZE  : integer := 32;
    constant C_AXI4_RRESP_SIZE  : integer := 2;
    constant C_AXI4_AWADDR_SIZE : integer := 32;
    constant C_AXI4_WDATA_SIZE  : integer := 32;
    constant C_AXI4_WSTRB_SIZE  : integer := 4;
    constant C_AXI4_BRESP_SIZE  : integer := 2;
    constant C_AXI4_DATA_SIZE   : integer := 32;
    constant C_AXI4_ADDR_SIZE   : integer := 10;

    component axi4lite_sl_if is
        generic (
            C_AXI4_ARADDR_SIZE : integer;
            C_AXI4_RDATA_SIZE  : integer;
            C_AXI4_RRESP_SIZE  : integer;
            C_AXI4_AWADDR_SIZE : integer;
            C_AXI4_WDATA_SIZE  : integer;
            C_AXI4_WSTRB_SIZE  : integer;
            C_AXI4_BRESP_SIZE  : integer;
            C_AXI4_DATA_SIZE   : integer;
            C_AXI4_ADDR_SIZE   : integer);
        port (
            SAxiClkxCI     : in  std_logic;
            SAxiResetxRANI : in  std_logic;
            SAxiAWAddrxDI  : in  std_logic_vector((C_AXI4_AWADDR_SIZE - 1) downto 0);
            SAxiAWValidxSI : in  std_logic;
            SAxiAWReadyxSO : out std_logic;
            SAxiWDataxDI   : in  std_logic_vector((C_AXI4_WDATA_SIZE - 1) downto 0);
            SAxiWStrbxDI   : in  std_logic_vector((C_AXI4_WSTRB_SIZE - 1) downto 0);
            SAxiWValidxSI  : in  std_logic;
            SAxiWReadyxSO  : out std_logic;
            SAxiBRespxDO   : out std_logic_vector((C_AXI4_BRESP_SIZE - 1) downto 0);
            SAxiBValidxSO  : out std_logic;
            SAxiBReadyxSI  : in  std_logic;
            SAxiARAddrxDI  : in  std_logic_vector((C_AXI4_ARADDR_SIZE - 1) downto 0);
            SAxiARValidxSI : in  std_logic;
            SAxiARReadyxSO : out std_logic;
            SAxiRDataxDO   : out std_logic_vector((C_AXI4_RDATA_SIZE - 1) downto 0);
            SAxiRRespxDO   : out std_logic_vector((C_AXI4_RRESP_SIZE - 1) downto 0);
            SAxiRValidxSO  : out std_logic;
            SAxiRReadyxSI  : in  std_logic;
            WrDataxDO      : out std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
            WrAddrxDO      : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
            WrValidxSO     : out std_logic;
            RdDataxDI      : in  std_logic_vector((C_AXI4_DATA_SIZE - 1) downto 0);
            RdAddrxDO      : out std_logic_vector((C_AXI4_ADDR_SIZE - 1) downto 0);
            RdValidxSO     : out std_logic);
    end component axi4lite_sl_if;

    -- component axi4lite_slave_if is
    --   generic (
    --     C_DATA_WIDTH : integer;
    --     C_ADDR_WIDTH : integer
    --     );
    --   port (
    --     s_axi_aclk    : in  std_logic;
    --     s_axi_aresetn : in  std_logic;
    --     s_axi_awaddr  : in  std_logic_vector(31 downto 0);
    --     s_axi_awvalid : in  std_logic;
    --     s_axi_awready : out std_logic;
    --     s_axi_wdata   : in  std_logic_vector(31 downto 0);
    --     s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    --     s_axi_wvalid  : in  std_logic;
    --     s_axi_wready  : out std_logic;
    --     s_axi_bresp   : out std_logic_vector(1 downto 0);
    --     s_axi_bvalid  : out std_logic;
    --     s_axi_bready  : in  std_logic;
    --     s_axi_araddr  : in  std_logic_vector(31 downto 0);
    --     s_axi_arvalid : in  std_logic;
    --     s_axi_arready : out std_logic;
    --     s_axi_rdata   : out std_logic_vector(31 downto 0);
    --     s_axi_rresp   : out std_logic_vector(1 downto 0);
    --     s_axi_rvalid  : out std_logic;
    --     s_axi_rready  : in  std_logic;
    --     wr_valid_o      : out std_logic;
    --     wr_addr_o       : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
    --     wr_data_o       : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
    --     rd_valid_o      : out std_logic;
    --     rd_addr_o       : out std_logic_vector((C_ADDR_WIDTH - 1) downto 0);
    --     rd_data_i       : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0)
    --     );
    -- end component axi4lite_slave_if;

    signal s_axi_aclk    : std_logic := '1';
    signal s_axi_aresetn : std_logic := '0';

    signal s_axi_awaddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_awvalid : std_logic                     := '0';
    signal s_axi_awready : std_logic                     := '0';
    signal s_axi_wdata   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_wstrb   : std_logic_vector(3 downto 0)  := (others => '0');
    signal s_axi_wvalid  : std_logic                     := '0';
    signal s_axi_wready  : std_logic                     := '0';
    signal s_axi_bresp   : std_logic_vector(1 downto 0)  := (others => '0');
    signal s_axi_bvalid  : std_logic                     := '0';
    signal s_axi_bready  : std_logic                     := '0';
    signal s_axi_araddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_arvalid : std_logic                     := '0';
    signal s_axi_arready : std_logic                     := '0';
    signal s_axi_rdata   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axi_rresp   : std_logic_vector(1 downto 0)  := (others => '0');
    signal s_axi_rvalid  : std_logic                     := '0';
    signal s_axi_rready  : std_logic                     := '0';

    signal wr_valid_o : std_logic                                     := '0';
    signal wr_addr_o  : std_logic_vector((C_ADDR_WIDTH - 1) downto 0) := (others => '0');
    signal wr_data_o  : std_logic_vector((C_DATA_WIDTH - 1) downto 0) := (others => '0');
    signal rd_valid_o : std_logic                                     := '0';
    signal rd_addr_o  : std_logic_vector((C_ADDR_WIDTH - 1) downto 0) := (others => '0');
    signal rd_data_i  : std_logic_vector((C_DATA_WIDTH - 1) downto 0) := (others => '0');

    constant s_axi_aclk_period : time := 10 ns;

    signal rd_data : std_logic_vector(31 downto 0) := (others => '0');


    ----------------------------------------------------------------
    -- Write to AXI4-Lite interface
    ----------------------------------------------------------------
    procedure axi4lite_write (
        constant wr_addr     : in  std_logic_vector(31 downto 0);
        constant wr_data     : in  std_logic_vector(31 downto 0);
        -- AXI4-Lite interface
        signal s_axi_awready : in  std_logic;
        signal s_axi_awvalid : out std_logic;
        signal s_axi_awaddr  : out std_logic_vector(31 downto 0);
        signal s_axi_wready  : in  std_logic;
        signal s_axi_wvalid  : out std_logic;
        signal s_axi_wstrb   : out std_logic_vector(3 downto 0);
        signal s_axi_wdata   : out std_logic_vector(31 downto 0);
        signal s_axi_bvalid  : in  std_logic;
        signal s_axi_bready  : out std_logic
        ) is
    begin
        -- Set the address
        s_axi_awvalid <= '1';
        s_axi_awaddr  <= wr_addr;
        -- Set the data
        s_axi_wvalid  <= '1';
        s_axi_wdata   <= wr_data;
        s_axi_wstrb   <= "1111";
        wait for s_axi_aclk_period;

        if s_axi_awready = '0' then
            wait until s_axi_awready = '1';
            wait for s_axi_aclk_period;
        end if;
        s_axi_awvalid <= '0';
        s_axi_awaddr  <= (others => '0');

        if s_axi_wready = '0' then
            wait until s_axi_wready = '1';
            wait for s_axi_aclk_period;
        end if;
        s_axi_wvalid <= '0';
        s_axi_wdata  <= (others => '0');
        s_axi_wstrb  <= "0000";

        -- Valid the transaction
        s_axi_bready <= '1';
        if s_axi_bvalid = '0' then
            wait until s_axi_bvalid = '1';
        end if;
        wait for s_axi_aclk_period;
        s_axi_bready <= '0';
        wait for s_axi_aclk_period;
    end procedure axi4lite_write;


    ----------------------------------------------------------------
    -- Read from AXI4-Lite interface
    ----------------------------------------------------------------
    procedure axi4lite_read (
        constant rd_addr     : in  std_logic_vector(31 downto 0);
        signal rd_data       : out std_logic_vector(31 downto 0);
        -- AXI4-Lite interface
        signal s_axi_arready : in  std_logic;
        signal s_axi_arvalid : out std_logic;
        signal s_axi_araddr  : out std_logic_vector(31 downto 0);
        signal s_axi_rvalid  : in  std_logic;
        signal s_axi_rdata   : in  std_logic_vector(31 downto 0);
        signal s_axi_rready  : out std_logic
        ) is
    begin
        -- Set the address
        if s_axi_arready = '0' then
            wait until s_axi_arready = '1';
        end if;
        wait for s_axi_aclk_period;
        s_axi_arvalid <= '1';
        s_axi_araddr  <= rd_addr;
        wait for s_axi_aclk_period;
        s_axi_arvalid <= '0';
        s_axi_araddr  <= (others => '0');

        -- Get the data
        if s_axi_rvalid = '0' then
            wait until s_axi_rvalid = '1';
        end if;
        wait for s_axi_aclk_period;
        s_axi_rready <= '1';
        rd_data      <= s_axi_rdata;
        wait for s_axi_aclk_period;
        s_axi_rready <= '0';
        wait for s_axi_aclk_period;
    end procedure axi4lite_read;

begin

    s_axi_aclk <= not s_axi_aclk after s_axi_aclk_period / 2;


    reset_proc : process
    begin
        s_axi_aresetn <= '0';
        wait for s_axi_aclk_period * 10;
        s_axi_aresetn <= '1';

        wait;
    end process reset_proc;


    axi4lite_sl_if_1 : entity work.axi4lite_sl_if
        generic map (
            C_AXI4_ARADDR_SIZE => C_AXI4_ARADDR_SIZE,
            C_AXI4_RDATA_SIZE  => C_AXI4_RDATA_SIZE,
            C_AXI4_RRESP_SIZE  => C_AXI4_RRESP_SIZE,
            C_AXI4_AWADDR_SIZE => C_AXI4_AWADDR_SIZE,
            C_AXI4_WDATA_SIZE  => C_AXI4_WDATA_SIZE,
            C_AXI4_WSTRB_SIZE  => C_AXI4_WSTRB_SIZE,
            C_AXI4_BRESP_SIZE  => C_AXI4_BRESP_SIZE,
            C_AXI4_DATA_SIZE   => C_AXI4_DATA_SIZE,
            C_AXI4_ADDR_SIZE   => C_AXI4_ADDR_SIZE)
        port map (
            SAxiClkxCI     => s_axi_aclk,
            SAxiResetxRANI => s_axi_aresetn,
            SAxiAWAddrxDI  => s_axi_awaddr,
            SAxiAWValidxSI => s_axi_awvalid,
            SAxiAWReadyxSO => s_axi_awready,
            SAxiWDataxDI   => s_axi_wdata,
            SAxiWStrbxDI   => s_axi_wstrb,
            SAxiWValidxSI  => s_axi_wvalid,
            SAxiWReadyxSO  => s_axi_wready,
            SAxiBRespxDO   => s_axi_bresp,
            SAxiBValidxSO  => s_axi_bvalid,
            SAxiBReadyxSI  => s_axi_bready,
            SAxiARAddrxDI  => s_axi_araddr,
            SAxiARValidxSI => s_axi_arvalid,
            SAxiARReadyxSO => s_axi_arready,
            SAxiRDataxDO   => s_axi_rdata,
            SAxiRRespxDO   => s_axi_rresp,
            SAxiRValidxSO  => s_axi_rvalid,
            SAxiRReadyxSI  => s_axi_rready,
            WrDataxDO      => wr_data_o,
            WrAddrxDO      => wr_addr_o,
            WrValidxSO     => wr_valid_o,
            RdDataxDI      => rd_data_i,
            RdAddrxDO      => rd_addr_o,
            RdValidxSO     => rd_valid_o);

    -- axi4lite_slave_if_1 : entity work.axi4lite_slave_if
    --   generic map (
    --     C_DATA_WIDTH => C_DATA_WIDTH,
    --     C_ADDR_WIDTH => C_ADDR_WIDTH
    --     )
    --   port map (
    --     s_axi_aclk    => s_axi_aclk,
    --     s_axi_aresetn => s_axi_aresetn,
    --     s_axi_awaddr  => s_axi_awaddr,
    --     s_axi_awvalid => s_axi_awvalid,
    --     s_axi_awready => s_axi_awready,
    --     s_axi_wdata   => s_axi_wdata,
    --     s_axi_wstrb   => s_axi_wstrb,
    --     s_axi_wvalid  => s_axi_wvalid,
    --     s_axi_wready  => s_axi_wready,
    --     s_axi_bresp   => s_axi_bresp,
    --     s_axi_bvalid  => s_axi_bvalid,
    --     s_axi_bready  => s_axi_bready,
    --     s_axi_araddr  => s_axi_araddr,
    --     s_axi_arvalid => s_axi_arvalid,
    --     s_axi_arready => s_axi_arready,
    --     s_axi_rdata   => s_axi_rdata,
    --     s_axi_rresp   => s_axi_rresp,
    --     s_axi_rvalid  => s_axi_rvalid,
    --     s_axi_rready  => s_axi_rready,
    --     wr_valid_o      => wr_valid_o,
    --     wr_addr_o       => wr_addr_o,
    --     wr_data_o       => wr_data_o,
    --     rd_valid_o      => rd_valid_o,
    --     rd_addr_o       => rd_addr_o,
    --     rd_data_i       => rd_data_i
    --     );


    waveform_proc : process
    begin
        wait until s_axi_aresetn = '1';
        wait for s_axi_aclk_period * 4;

        ----------------------------------------------------------------
        -- Write data to the AXI4-Lite interface
        ----------------------------------------------------------------
        axi4lite_write(X"00000004", X"11223344",
                       s_axi_awready, s_axi_awvalid, s_axi_awaddr, s_axi_wready,
                       s_axi_wvalid, s_axi_wstrb, s_axi_wdata, s_axi_bvalid, s_axi_bready
                       );


        ----------------------------------------------------------------
        -- Read from the BRAM
        ----------------------------------------------------------------
        axi4lite_read(X"00000004", rd_data,
                      s_axi_arready, s_axi_arvalid, s_axi_araddr,
                      s_axi_rvalid, s_axi_rdata, s_axi_rready
                      );

        wait for s_axi_aclk_period;
        assert rd_data = X"CAFEFACE" report "#Error: invalid read result" severity failure;


        wait for s_axi_aclk_period * 20;
        assert false report "-- Simulation completed successfully --" severity failure;

        wait;
    end process waveform_proc;


    check_wr_process : process
    begin
        wait until s_axi_aresetn = '1';
        wait for s_axi_aclk_period;

        wait until wr_valid_o = '1';
        wait for s_axi_aclk_period;
        assert wr_addr_o = "0000000100" report "# Error: invalid address" severity failure;
        assert wr_data_o = X"11223344" report "# Error: invalid data" severity failure;

        wait for s_axi_aclk_period * 20;
        assert false report "-- Simulation completed successfully --" severity failure;

        wait;
    end process check_wr_process;


    data_mem_proc : process
    begin
        wait until s_axi_aresetn = '1';
        wait for s_axi_aclk_period;

        wait until rd_valid_o = '1';
        wait for s_axi_aclk_period;

        if rd_addr_o = std_logic_vector(to_unsigned(4, C_ADDR_WIDTH)) then
            rd_data_i <= X"CAFEFACE";
        end if;

        wait;
    end process data_mem_proc;

end testbench;
