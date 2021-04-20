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
-- Module Name: synchronizer - behavioral
-- Target Device: SCALP xc7z015clg485-2
-- Tool version: 2018.2
-- Description: Clock domaines synchronizer
--
-- Last update: 2019-02-19
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synchronizer is

    port (
        ClkxCI   : in  std_logic;
        ASyncxSI : in  std_logic;
        SyncxSO  : out std_logic);

end entity synchronizer;

architecture behavioral of synchronizer is

    -- Attributes declarations           
    -- tig="true"         - Specifies a timing ignore for the asynchronous input.
    attribute tig                         : string;
    -- iob="false"        - Specifies to not place the register into the IOB allowing
    --                      both synchronization registers to exist in the same slice
    --                      allowing for the shortest propagation time between them.
    attribute iob                         : string;
    -- async_reg="true"   - Specifies registers will be receiving asynchronous
    --                      data input to allow for better timing simulation
    --                      characteristics.
    attribute async_reg                   : string;
    -- shift_extract="no" - Specifies to the synthesis tool to not infer an SRL.
    attribute shift_extract               : string;
    -- hblknm="sync_reg"  - Specifies to pack both registers into the same slice,
    --                      called sync_reg.
    -- attribute hblknm                      : string;
    -- Signals declarations
    signal ShiftRegxD                     : std_logic_vector(1 downto 0) := (others => '0');
    -- Attributes specifications
    attribute tig of ASyncxSI             : signal is "true";
    -- attribute iob of ASyncxSI             : signal is "false";
    -- attribute tig of ShiftRegxD           : signal is "true";
    attribute iob of ShiftRegxD           : signal is "false";
    attribute async_reg of ShiftRegxD     : signal is "true";
    attribute shift_extract of ShiftRegxD : signal is "true";

begin  -- architecture behavioral

    ResyncAsyncInputxP : process (ClkxCI) is
    begin  -- process ResyncAsyncInputxP
        if rising_edge(ClkxCI) then
            SyncxSO    <= ShiftRegxD(1);
            ShiftRegxD <= ShiftRegxD(0) & ASyncxSI;
        end if;
    end process ResyncAsyncInputxP;

end architecture behavioral;
