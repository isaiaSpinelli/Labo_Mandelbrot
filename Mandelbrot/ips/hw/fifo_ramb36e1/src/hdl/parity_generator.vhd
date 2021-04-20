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
-- Module Name: parity_generator - behavioural
-- Target Device: All
-- Tool version: 2018.3
-- Description: Parity Generator
--
-- Last update: 2019-02-14
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity parity_generator is

    generic (
        C_DATA_SIZE   : integer := 8;
        C_PARITY_TYPE : string  := "odd");  -- "even" or "odd"

    port (
        DataxDI   : in  std_logic_vector((C_DATA_SIZE - 1) downto 0);
        ParityxSO : out std_logic);

end entity parity_generator;

architecture behavioral of parity_generator is

    -- Signals
    ---------------------------------------------------------------------------
    signal ParityxS    : std_logic                                    := '0';
    signal ParityEOxS  : std_logic                                    := '0';
    signal ParityXORxD : std_logic_vector((C_DATA_SIZE - 1) downto 0) := (others => '0');

begin  -- architecture behavioral

    -- Asynchronous statements

    assert C_PARITY_TYPE = "even" or C_PARITY_TYPE = "odd"
        report "The value of C_PARITY_TYPE is false" severity failure;

    assert (C_DATA_SIZE mod 8) = 0
        report "The size of C_DATA_SIZE must be a multiple of 8" severity failure;

    IOTopxB : block is
    begin  -- block IOTopxB

        ParityxAS : ParityxSO <= ParityxS;

    end block IOTopxB;

    ParityProcessingxB : block is
    begin  -- block ParityProcessingxB

        EvenParityxG : if C_PARITY_TYPE = "even" generate

            ParityEOxAS : ParityEOxS <= '0';

        end generate EvenParityxG;

        OddParityxG : if C_PARITY_TYPE = "odd" generate

            ParityEOxAS : ParityEOxS <= '1';

        end generate OddParityxG;

        ParityXORxAS : ParityxS <= ParityXORxD(C_DATA_SIZE - 1);

        ParityXORxP : process (DataxDI, ParityEOxS,
                               ParityXORxD) is
        begin  -- process ParityXORxP
            ParityXORxD(0) <= DataxDI(0) xor ParityEOxS;

            for i in 1 to (C_DATA_SIZE - 1) loop
                ParityXORxD(i) <= DataxDI(i) xor ParityXORxD(i - 1);
            end loop;  -- i
        end process ParityXORxP;

    end block ParityProcessingxB;

    -- Synchronous statements

end architecture behavioral;
