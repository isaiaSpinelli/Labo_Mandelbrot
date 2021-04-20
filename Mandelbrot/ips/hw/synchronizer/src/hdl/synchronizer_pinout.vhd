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
-- Module Name: synchronizer_pinout - behavioralrtl
-- Target Device: SCALP xc7z015clg485-2
-- Tool version: 2018.2
-- Description: Clock domaines synchronizer pinout
--
-- Last update: 2019-02-19
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity synchronizer_pinout is

    port (
        ClkSys100MhzxCI : in  std_logic;
        ResetxRNI       : in  std_logic;
        BtnCxSI         : in  std_logic;
        Led0xSO         : out std_logic);

end entity synchronizer_pinout;

architecture rtl of synchronizer_pinout is

    -- Components
    component clk_dom_dst
        port (
            SyncClkxCO      : out std_logic;
            resetn          : in  std_logic;
            LockedxSO       : out std_logic;
            ClkSys100MhzxCI : in  std_logic);
    end component;

    component synchronizer is
        port (
            ClkxCI   : in  std_logic;
            ASyncxSI : in  std_logic;
            SyncxSO  : out std_logic);
    end component synchronizer;

    -- Signals
    signal SyncClkxC  : std_logic := '0';
    signal ResetxR    : std_logic := '0';
    signal LockedxS   : std_logic := '0';
    signal BtnCSyncxS : std_logic := '0';

begin  -- architecture rtl

    ResetxAS : ResetxR <= not ResetxRNI;

    PllxI : clk_dom_dst
        port map (
            -- Clock out ports  
            SyncClkxCO      => SyncClkxC,
            -- Status and control signals                
            resetn          => ResetxRNI,
            LockedxSO       => LockedxS,
            -- Clock in ports
            ClkSys100MhzxCI => ClkSys100MhzxCI);

    BtnCFDRExI : FDRE
        generic map (
            INIT => '0')
        port map (
            Q  => BtnCSyncxS,
            C  => ClkSys100MhzxCI,
            CE => '1',
            R  => ResetxR,
            D  => BtnCxSI);

    SynchronizerxI : entity work.synchronizer
        port map (
            ClkxCI   => SyncClkxC,
            ASyncxSI => BtnCSyncxS,
            SyncxSO  => Led0xSO);

end architecture rtl;
