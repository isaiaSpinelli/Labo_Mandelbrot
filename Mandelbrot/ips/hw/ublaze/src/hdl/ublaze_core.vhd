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
-- Module Name: ublaze_core - rtl
-- Target Device: Mandelbrot xc7a200tsbg484-1
-- Tool version: 2018.2
-- Description: Microblaze Core
--
-- Last update: 2019-02-15
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

entity ublaze_core is

    generic (
        C_GPIO_SIZE      : integer := 8;
        C_AXI4_DATA_SIZE : integer := 32;
        C_AXI4_ADDR_SIZE : integer := 12);

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

end entity ublaze_core;

architecture rtl of ublaze_core is

    -- Components
    component ublaze_sopc is
        port (
            SysClkxCI     : in  std_logic;
            UserClkxCO    : out std_logic;
            ResetxRNI     : in  std_logic;
            PllLockedxSO  : out std_logic;
            GpioxDO_tri_o : out std_logic_vector ((C_GPIO_SIZE - 1) downto 0);
            WrDataxDO     : out std_logic_vector ((C_AXI4_DATA_SIZE - 1) downto 0);
            WrAddrxDO     : out std_logic_vector ((C_AXI4_ADDR_SIZE - 1) downto 0);
            WrValidxSO    : out std_logic;
            RdDataxDI     : in  std_logic_vector ((C_AXI4_DATA_SIZE - 1) downto 0);
            RdAddrxDO     : out std_logic_vector ((C_AXI4_ADDR_SIZE - 1) downto 0);
            RdValidxSO    : out std_logic;
            InterruptxSI  : in  std_logic);
    end component ublaze_sopc;

begin  -- architecture rtl

    -- Asynchronous statements

    -- Synchronous statements

    UblazeSoPCxB : block is
    begin  -- block UblazeSystemxB

        UblazeCorexI : component ublaze_sopc
            port map (
                SysClkxCI                                  => SysClkxCI,
                UserClkxCO                                 => UserClkxCO,
                ResetxRNI                                  => ResetxRNI,
                PllLockedxSO                               => PllLockedxSO,
                GpioxDO_tri_o((C_GPIO_SIZE - 1) downto 0)  => GpioxDO((C_GPIO_SIZE - 1) downto 0),
                WrDataxDO((C_AXI4_DATA_SIZE - 1) downto 0) => WrDataxDO((C_AXI4_DATA_SIZE - 1) downto 0),
                WrAddrxDO((C_AXI4_ADDR_SIZE - 1) downto 0) => WrAddrxDO((C_AXI4_ADDR_SIZE - 1) downto 0),
                WrValidxSO                                 => WrValidxSO,
                RdDataxDI((C_AXI4_DATA_SIZE - 1) downto 0) => RdDataxDI((C_AXI4_DATA_SIZE - 1) downto 0),
                RdAddrxDO((C_AXI4_ADDR_SIZE - 1) downto 0) => RdAddrxDO((C_AXI4_ADDR_SIZE - 1) downto 0),
                RdValidxSO                                 => RdValidxSO,
                InterruptxSI                               => InterruptxSI);

    end block UblazeSoPCxB;

end architecture rtl;
