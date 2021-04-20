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
-- Module Name: cdc_sync - behavioural
-- Target Device: All
-- Tool version: 2018.3
-- Description: Clock Domain Crossing Synchronizer
--
-- Last update: 2019-02-18
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

entity cdc_sync is

    generic (
        -- 0 is pusle sync
        -- 1 is level sync
        -- 2 is ack based level sync
        C_CDC_TYPE     : integer range 0 to 2  := 1;
        -- 0 is reset not needed
        -- 1 is reset needed
        C_RESET_STATE  : integer range 0 to 1  := 0;
        -- 0 is bus input
        -- 1 is single bit input
        C_SINGLE_BIT   : integer range 0 to 1  := 1;
        C_FLOP_INPUT   : integer range 0 to 1  := 1;
        -- Vector data width
        C_VECTOR_WIDTH : integer range 0 to 32 := 2;
        C_MTBF_STAGES  : integer range 0 to 6  := 5);

    port (
        -- Source Clock Domain
        -- Clock of originating domain.
        PrimaryClkxCAI     : in  std_logic;
        -- Sync reset of originating clock domain.
        PrimaryResetxRNI   : in  std_logic;
        -- Input signal bit. This should be a pure flop outpus without any
        -- combi logic.
        PrimaryxSI         : in  std_logic;
        -- Bus signal.
        PrimaryxDI         : in  std_logic_vector((C_VECTOR_WIDTH - 1) downto 0);
        -- Ack signal. Valid for one clock period in PrimaryClkxCAI domain.
        -- Used only when C_CDC_TYPE = 2.
        PrimaryAckxSO      : out std_logic;
        -- Destination Clock Domain
        -- Destination clock.
        SecondaryClkxCAI   : in  std_logic;
        -- Sync reset of destination domain.
        SecondaryResetxRNI : in  std_logic;
        -- Sync'ed output in destination domain. Single bit.
        SecondaryxSO       : out std_logic;
        -- Sync'ed output in destination domain. Bus.
        SecondaryxDO       : out std_logic_vector((C_VECTOR_WIDTH - 1) downto 0));

end entity cdc_sync;

architecture behavioral of cdc_sync is

begin  -- architecture behavioral

    -- Pulse Synchronizer Generator
    GeneratePulseCDCxG : if C_CDC_TYPE = 0 generate

        PulseSyncxB : block is

            -- Signals
            signal PrimaryInXoredxS                     : std_logic := '0';
            signal PrimaryInD1CDCFromxS                 : std_logic := '0';
            signal SecondaryOutD1xS                     : std_logic := '0';
            signal SecondaryOutD2xS                     : std_logic := '0';
            signal SecondaryOutD3xS                     : std_logic := '0';
            signal SecondaryOutD4xS                     : std_logic := '0';
            signal SecondaryOutD5xS                     : std_logic := '0';
            signal SecondaryOutD6xS                     : std_logic := '0';
            signal SecondaryOutD7xS                     : std_logic := '0';
            signal SecondaryOutRExS                     : std_logic := '0';
            -- Attributes
            attribute async_reg                         : string;
            attribute shift_extract                     : string;
            attribute async_reg of SecondaryOutD1xS     : signal is "true";
            attribute shift_extract of SecondaryOutD1xS : signal is "no";
            attribute async_reg of SecondaryOutD2xS     : signal is "true";
            attribute shift_extract of SecondaryOutD2xS : signal is "no";
            attribute async_reg of SecondaryOutD3xS     : signal is "true";
            attribute shift_extract of SecondaryOutD3xS : signal is "no";
            attribute async_reg of SecondaryOutD4xS     : signal is "true";
            attribute shift_extract of SecondaryOutD4xS : signal is "no";
            attribute async_reg of SecondaryOutD5xS     : signal is "true";
            attribute shift_extract of SecondaryOutD5xS : signal is "no";
            attribute async_reg of SecondaryOutD6xS     : signal is "true";
            attribute shift_extract of SecondaryOutD6xS : signal is "no";
            attribute async_reg of SecondaryOutD7xS     : signal is "true";
            attribute shift_extract of SecondaryOutD7xS : signal is "no";

        begin  -- block PulseSyncxB

            -- Asynchronous statements

            PrimaryXoredxAS : PrimaryInXoredxS <= PrimaryxSI xor PrimaryInD1CDCFromxS;

            -- Stage 2
            MTBFStage2xG : if C_MTBF_STAGES = 2 or C_MTBF_STAGES = 1 generate

                SecondaryOutREStage2xAS : SecondaryOutRExS <= SecondaryOutD2xS xor SecondaryOutD3xS;

            end generate MTBFStage2xG;

            -- Stage 3
            MTBFStage3xG : if C_MTBF_STAGES = 3 generate

                SecondaryOutREStage3xAS : SecondaryOutRExS <= SecondaryOutD3xS xor SecondaryOutD4xS;

            end generate MTBFStage3xG;

            -- Stage 4
            MTBFStage4xG : if C_MTBF_STAGES = 4 generate

                SecondaryOutREStage4xAS : SecondaryOutRExS <= SecondaryOutD4xS xor SecondaryOutD5xS;

            end generate MTBFStage4xG;

            -- Stage 5
            MTBFStage5xG : if C_MTBF_STAGES = 5 generate

                SecondaryOutREStage5xAS : SecondaryOutRExS <= SecondaryOutD5xS xor SecondaryOutD6xS;

            end generate MTBFStage5xG;

            -- Stage 6
            MTBFStage6xG : if C_MTBF_STAGES = 6 generate

                SecondaryOutREStage6xAS : SecondaryOutRExS <= SecondaryOutD6xS xor SecondaryOutD7xS;

            end generate MTBFStage6xG;

            -- Synchronous statements

            RegPrimaryInputxP : process (PrimaryClkxCAI) is
            begin  -- process RegPrimaryInputxP
                if rising_edge(PrimaryClkxCAI) then
                    if PrimaryResetxRNI = '0' and C_RESET_STATE = 1 then
                        PrimaryInD1CDCFromxS <= '0';
                    else
                        PrimaryInD1CDCFromxS <= PrimaryInXoredxS;
                    end if;
                end if;
            end process RegPrimaryInputxP;

            PrimaryInputCrossToSecondaryxP : process (SecondaryClkxCAI) is
            begin  -- process PrimaryInputCrossToSecondaryxP
                if rising_edge(SecondaryClkxCAI) then
                    if SecondaryResetxRNI = '0' and C_RESET_STATE = 1 then
                        SecondaryOutD1xS <= '0';
                        SecondaryOutD2xS <= '0';
                        SecondaryOutD3xS <= '0';
                        SecondaryOutD4xS <= '0';
                        SecondaryOutD5xS <= '0';
                        SecondaryOutD6xS <= '0';
                        SecondaryOutD7xS <= '0';
                        SecondaryxSO     <= '0';
                    else
                        SecondaryOutD1xS <= PrimaryInD1CDCFromxS;
                        SecondaryOutD2xS <= SecondaryOutD1xS;
                        SecondaryOutD3xS <= SecondaryOutD2xS;
                        SecondaryOutD4xS <= SecondaryOutD3xS;
                        SecondaryOutD5xS <= SecondaryOutD4xS;
                        SecondaryOutD6xS <= SecondaryOutD5xS;
                        SecondaryOutD7xS <= SecondaryOutD6xS;
                        SecondaryxSO     <= SecondaryOutRExS;
                    end if;
                end if;
            end process PrimaryInputCrossToSecondaryxP;

        end block PulseSyncxB;

    end generate GeneratePulseCDCxG;

    -- Level Synchronizer Without Ack Generator
    GenerateLevelWithoutAckxG : if C_CDC_TYPE = 1 generate

        LevelSyncWithoutAckxB : block is
        begin  -- block LevelSyncWithoutAckxB

            -- Single Bit Level
            SingleBitLevelxG : if C_SINGLE_BIT = 1 generate

                -- Signals
                signal PrimaryLevelInD1CDCFromxS                 : std_logic := '0';
                signal PrimaryLevelInxS                          : std_logic := '0';
                signal SecondaryLevelOutD1xS                     : std_logic := '0';
                signal SecondaryLevelOutD2xS                     : std_logic := '0';
                signal SecondaryLevelOutD3xS                     : std_logic := '0';
                signal SecondaryLevelOutD4xS                     : std_logic := '0';
                signal SecondaryLevelOutD5xS                     : std_logic := '0';
                signal SecondaryLevelOutD6xS                     : std_logic := '0';
                -- Attributes
                -- attribute keep                                   : string;
                attribute async_reg                              : string;
                attribute shift_extract                          : string;
                -- attribute keep of PrimaryLevelInD1CDCFromxS      : signal is "true";
                -- attribute async_reg of PrimaryLevelInxS          : signal is "true";
                -- attribute shift_extract of PrimaryLevelInxS      : signal is "no";
                attribute async_reg of SecondaryLevelOutD1xS     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD1xS : signal is "no";
                attribute async_reg of SecondaryLevelOutD2xS     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD2xS : signal is "no";
                attribute async_reg of SecondaryLevelOutD3xS     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD3xS : signal is "no";
                attribute async_reg of SecondaryLevelOutD4xS     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD4xS : signal is "no";
                attribute async_reg of SecondaryLevelOutD5xS     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD5xS : signal is "no";
                attribute async_reg of SecondaryLevelOutD6xS     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD6xS : signal is "no";

            begin

                -- With Flip-Flop Input Stage
                InputFlopxG : if C_FLOP_INPUT = 1 generate

                    -- Asynchronous statements

                    PrimaryLevelInWithFlopxAS : PrimaryLevelInxS <= PrimaryLevelInD1CDCFromxS;

                    -- Synchronous statements

                    RegPrimaryLevelInputxP : process (PrimaryClkxCAI) is
                    begin  -- process RegPrimaryLevelInputxP
                        if rising_edge(PrimaryClkxCAI) then
                            if PrimaryResetxRNI = '0' and C_RESET_STATE = 1 then
                                PrimaryLevelInD1CDCFromxS <= '0';
                            else
                                PrimaryLevelInD1CDCFromxS <= PrimaryxSI;
                            end if;
                        end if;
                    end process RegPrimaryLevelInputxP;

                end generate InputFlopxG;

                -- Without Flip-Flop Input Stage
                NoInputFlopxG : if C_FLOP_INPUT = 0 generate

                    -- Asynchronous statements
                    PrimaryLevelInWithoutFlopxAS : PrimaryLevelInxS <= PrimaryxSI;

                end generate NoInputFlopxG;

                -- Asynchronous statements

                -- Stage 1
                MTBFLevelSingleBitStage1xG : if C_MTBF_STAGES = 1 generate

                    SecondaryOutLevelSingleBitD1xAS : SecondaryxSO <= SecondaryLevelOutD1xS;

                end generate MTBFLevelSingleBitStage1xG;

                -- Stage 2
                MTBFLevelSingleBitStage2xG : if C_MTBF_STAGES = 2 generate

                    SecondaryOutLevelSingleBitD2xAS : SecondaryxSO <= SecondaryLevelOutD2xS;

                end generate MTBFLevelSingleBitStage2xG;

                -- Stage 3
                MTBFLevelSingleBitStage3xG : if C_MTBF_STAGES = 3 generate

                    SecondaryOutLevelSingleBitD3xAS : SecondaryxSO <= SecondaryLevelOutD3xS;

                end generate MTBFLevelSingleBitStage3xG;

                -- Stage 4
                MTBFLevelSingleBitStage4xG : if C_MTBF_STAGES = 4 generate

                    SecondaryOutLevelSingleBitD4xAS : SecondaryxSO <= SecondaryLevelOutD4xS;

                end generate MTBFLevelSingleBitStage4xG;

                -- Stage 5
                MTBFLevelSingleBitStage5xG : if C_MTBF_STAGES = 5 generate

                    SecondaryOutLevelSingleBitD5xAS : SecondaryxSO <= SecondaryLevelOutD5xS;

                end generate MTBFLevelSingleBitStage5xG;

                -- Stage 6
                MTBFLevelSingleBitStage6xG : if C_MTBF_STAGES = 6 generate

                    SecondaryOutLevelSingleBitD6xAS : SecondaryxSO <= SecondaryLevelOutD6xS;

                end generate MTBFLevelSingleBitStage6xG;

                -- Synchronous statements

                PrimaryInputCrossToSecondarySingleBitxP : process (SecondaryClkxCAI) is
                begin  -- process PrimaryInputCrossToSecondarySingleBitxP
                    if rising_edge(SecondaryClkxCAI) then
                        if SecondaryResetxRNI = '0' and C_RESET_STATE = 1 then
                            SecondaryLevelOutD1xS <= '0';
                            SecondaryLevelOutD2xS <= '0';
                            SecondaryLevelOutD3xS <= '0';
                            SecondaryLevelOutD4xS <= '0';
                            SecondaryLevelOutD5xS <= '0';
                            SecondaryLevelOutD6xS <= '0';
                        else
                            SecondaryLevelOutD1xS <= PrimaryLevelInxS;
                            SecondaryLevelOutD2xS <= SecondaryLevelOutD1xS;
                            SecondaryLevelOutD3xS <= SecondaryLevelOutD2xS;
                            SecondaryLevelOutD4xS <= SecondaryLevelOutD3xS;
                            SecondaryLevelOutD5xS <= SecondaryLevelOutD4xS;
                            SecondaryLevelOutD6xS <= SecondaryLevelOutD5xS;
                        end if;
                    end if;
                end process PrimaryInputCrossToSecondarySingleBitxP;

            end generate SingleBitLevelxG;

            -- Multi Bit Level
            MultiBitLevelxG : if C_SINGLE_BIT = 0 generate

                -- Signals
                signal PrimaryLevelInD1CDCFromxD                 : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal PrimaryLevelInxD                          : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal SecondaryLevelOutD1xD                     : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal SecondaryLevelOutD2xD                     : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal SecondaryLevelOutD3xD                     : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal SecondaryLevelOutD4xD                     : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal SecondaryLevelOutD5xD                     : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                signal SecondaryLevelOutD6xD                     : std_logic_vector((C_VECTOR_WIDTH - 1) downto 0) := (others => '0');
                -- Attributes
                attribute async_reg                              : string;
                attribute shift_extract                          : string;
                attribute async_reg of SecondaryLevelOutD1xD     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD1xD : signal is "no";
                attribute async_reg of SecondaryLevelOutD2xD     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD2xD : signal is "no";
                attribute async_reg of SecondaryLevelOutD3xD     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD3xD : signal is "no";
                attribute async_reg of SecondaryLevelOutD4xD     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD4xD : signal is "no";
                attribute async_reg of SecondaryLevelOutD5xD     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD5xD : signal is "no";
                attribute async_reg of SecondaryLevelOutD6xD     : signal is "true";
                attribute shift_extract of SecondaryLevelOutD6xD : signal is "no";

            begin

                -- With Flip-Flop Input Stage
                InputFlopxG : if C_FLOP_INPUT = 1 generate

                    -- Asynchronous statements

                    PrimaryLevelInWithFlopxAS : PrimaryLevelInxD <= PrimaryLevelInD1CDCFromxD;

                    -- Synchronous statements

                    RegPrimaryLevelInputxP : process (PrimaryClkxCAI) is
                    begin  -- process RegPrimaryLevelInputxP
                        if rising_edge(PrimaryClkxCAI) then
                            if PrimaryResetxRNI = '0' and C_RESET_STATE = 1 then
                                PrimaryLevelInD1CDCFromxD <= (others => '0');
                            else
                                PrimaryLevelInD1CDCFromxD <= PrimaryxDI;
                            end if;
                        end if;
                    end process RegPrimaryLevelInputxP;

                end generate InputFlopxG;

                -- Without Flip-Flop Input Stage
                NoInputFlopxG : if C_FLOP_INPUT = 0 generate

                    -- Asynchronous statements

                    PrimaryLevelInWithoutFlopxAS : PrimaryLevelInxD <= PrimaryxDI;

                end generate NoInputFlopxG;

                -- Asynchronous statements

                -- Stage 1
                MTBFLevelMultiBitStage1xG : if C_MTBF_STAGES = 1 generate

                    SecondaryOutLevelMultiBitD1xAS : SecondaryxDO <= SecondaryLevelOutD1xD;

                end generate MTBFLevelMultiBitStage1xG;

                -- Stage 2
                MTBFLevelMultiBitStage2xG : if C_MTBF_STAGES = 2 generate

                    SecondaryOutLevelMultiBitD2xAS : SecondaryxDO <= SecondaryLevelOutD2xD;

                end generate MTBFLevelMultiBitStage2xG;

                -- Stage 3
                MTBFLevelMultiBitStage3xG : if C_MTBF_STAGES = 3 generate

                    SecondaryOutLevelMultiBitD3xAS : SecondaryxDO <= SecondaryLevelOutD3xD;

                end generate MTBFLevelMultiBitStage3xG;

                -- Stage 4
                MTBFLevelMultiBitStage4xG : if C_MTBF_STAGES = 4 generate

                    SecondaryOutLevelMultiBitD4xAS : SecondaryxDO <= SecondaryLevelOutD4xD;

                end generate MTBFLevelMultiBitStage4xG;

                -- Stage 5
                MTBFLevelMultiBitStage5xG : if C_MTBF_STAGES = 5 generate

                    SecondaryOutLevelMultiBitD5xAS : SecondaryxDO <= SecondaryLevelOutD5xD;

                end generate MTBFLevelMultiBitStage5xG;

                -- Stage 6
                MTBFLevelMultiBitStage6xG : if C_MTBF_STAGES = 6 generate

                    SecondaryOutLevelMultiBitD6xAS : SecondaryxDO <= SecondaryLevelOutD6xD;

                end generate MTBFLevelMultiBitStage6xG;

                -- Synchronous statements

                PrimaryInputCrossToSecondaryMultiBitxP : process (SecondaryClkxCAI) is
                begin  -- process PrimaryInputCrossToSecondaryMultiBitxP
                    if rising_edge(SecondaryClkxCAI) then
                        if SecondaryResetxRNI = '0' and C_RESET_STATE = 1 then
                            SecondaryLevelOutD1xD <= (others => '0');
                            SecondaryLevelOutD2xD <= (others => '0');
                            SecondaryLevelOutD3xD <= (others => '0');
                            SecondaryLevelOutD4xD <= (others => '0');
                            SecondaryLevelOutD5xD <= (others => '0');
                            SecondaryLevelOutD6xD <= (others => '0');
                        else
                            SecondaryLevelOutD1xD <= PrimaryLevelInxD;
                            SecondaryLevelOutD2xD <= SecondaryLevelOutD1xD;
                            SecondaryLevelOutD3xD <= SecondaryLevelOutD2xD;
                            SecondaryLevelOutD4xD <= SecondaryLevelOutD3xD;
                            SecondaryLevelOutD5xD <= SecondaryLevelOutD4xD;
                            SecondaryLevelOutD6xD <= SecondaryLevelOutD5xD;
                        end if;
                    end if;
                end process PrimaryInputCrossToSecondaryMultiBitxP;

            end generate MultiBitLevelxG;

        end block LevelSyncWithoutAckxB;

    end generate GenerateLevelWithoutAckxG;

    -- Level Synchronizer With Ack Generator
    GenerateLevelWithAckxG : if C_CDC_TYPE = 2 generate

        LevelSyncWithAckxB : block is

            -- Signals
            signal PrimaryLevelInD1CDCFromxS                 : std_logic := '0';
            signal PrimaryLevelInxS                          : std_logic := '0';
            signal PrimaryLevelPulseAckxS                    : std_logic := '0';
            signal PrimaryLevelOutD1xS                       : std_logic := '0';
            signal PrimaryLevelOutD2xS                       : std_logic := '0';
            signal PrimaryLevelOutD3xS                       : std_logic := '0';
            signal PrimaryLevelOutD4xS                       : std_logic := '0';
            signal PrimaryLevelOutD5xS                       : std_logic := '0';
            signal PrimaryLevelOutD6xS                       : std_logic := '0';
            signal SecondaryLevelOutxS                       : std_logic := '0';
            signal SecondaryLevelOutD1xS                     : std_logic := '0';
            signal SecondaryLevelOutD2xS                     : std_logic := '0';
            signal SecondaryLevelOutD3xS                     : std_logic := '0';
            signal SecondaryLevelOutD4xS                     : std_logic := '0';
            signal SecondaryLevelOutD5xS                     : std_logic := '0';
            signal SecondaryLevelOutD6xS                     : std_logic := '0';
            -- Attributes
            attribute async_reg                              : string;
            attribute shift_extract                          : string;
            attribute async_reg of SecondaryLevelOutD1xS     : signal is "true";
            attribute shift_extract of SecondaryLevelOutD1xS : signal is "no";
            attribute async_reg of SecondaryLevelOutD2xS     : signal is "true";
            attribute shift_extract of SecondaryLevelOutD2xS : signal is "no";
            attribute async_reg of SecondaryLevelOutD3xS     : signal is "true";
            attribute shift_extract of SecondaryLevelOutD3xS : signal is "no";
            attribute async_reg of SecondaryLevelOutD4xS     : signal is "true";
            attribute shift_extract of SecondaryLevelOutD4xS : signal is "no";
            attribute async_reg of SecondaryLevelOutD5xS     : signal is "true";
            attribute shift_extract of SecondaryLevelOutD5xS : signal is "no";
            attribute async_reg of SecondaryLevelOutD6xS     : signal is "true";
            attribute shift_extract of SecondaryLevelOutD6xS : signal is "no";
            attribute async_reg of PrimaryLevelOutD1xS       : signal is "true";
            attribute shift_extract of PrimaryLevelOutD1xS   : signal is "no";
            attribute async_reg of PrimaryLevelOutD2xS       : signal is "true";
            attribute shift_extract of PrimaryLevelOutD2xS   : signal is "no";
            attribute async_reg of PrimaryLevelOutD3xS       : signal is "true";
            attribute shift_extract of PrimaryLevelOutD3xS   : signal is "no";
            attribute async_reg of PrimaryLevelOutD4xS       : signal is "true";
            attribute shift_extract of PrimaryLevelOutD4xS   : signal is "no";
            attribute async_reg of PrimaryLevelOutD5xS       : signal is "true";
            attribute shift_extract of PrimaryLevelOutD5xS   : signal is "no";
            attribute async_reg of PrimaryLevelOutD6xS       : signal is "true";
            attribute shift_extract of PrimaryLevelOutD6xS   : signal is "no";

        begin  -- block LevelSyncWithAck

            -- With Flip-Flop Input Stage
            InputFlopxG : if C_FLOP_INPUT = 1 generate

                -- Asynchronous statements

                PrimaryLevelInWithFlopxAS : PrimaryLevelInxS <= PrimaryLevelInD1CDCFromxS;

                -- Synchronous statements

                RegPrimaryLevelInputxP : process (PrimaryClkxCAI) is
                begin  -- process RegPrimaryLevelInputxP
                    if rising_edge(PrimaryClkxCAI) then
                        if PrimaryResetxRNI = '0' and C_RESET_STATE = 1 then
                            PrimaryLevelInD1CDCFromxS <= '0';
                        else
                            PrimaryLevelInD1CDCFromxS <= PrimaryxSI;
                        end if;
                    end if;
                end process RegPrimaryLevelInputxP;

            end generate InputFlopxG;

            -- Without Flip-Flop Input Stage
            NoInputFlopxG : if C_FLOP_INPUT = 0 generate

                -- Asynchronous statements

                PrimaryLevelInWithoutFlopxAS : PrimaryLevelInxS <= PrimaryxSI;

            end generate NoInputFlopxG;

            -- Asynchronous statements

            SecondaryLevelOutxAS : SecondaryxSO <= SecondaryLevelOutxS;

            -- Stage 2
            MTBFLevelSingleBitStage2xG : if C_MTBF_STAGES = 2 or C_MTBF_STAGES = 1 generate

                SecondaryOutLevelSingleBitD2xAS : SecondaryLevelOutxS    <= SecondaryLevelOutD2xS;
                PrimaryLevelPulseAckD2xAS       : PrimaryLevelPulseAckxS <= PrimaryLevelOutD2xS xor PrimaryLevelOutD3xS;

            end generate MTBFLevelSingleBitStage2xG;

            -- Stage 3
            MTBFLevelSingleBitStage3xG : if C_MTBF_STAGES = 3 generate

                SecondaryOutLevelSingleBitD3xAS : SecondaryLevelOutxS    <= SecondaryLevelOutD3xS;
                PrimaryLevelPulseAckD3xAS       : PrimaryLevelPulseAckxS <= PrimaryLevelOutD3xS xor PrimaryLevelOutD4xS;

            end generate MTBFLevelSingleBitStage3xG;

            -- Stage 4
            MTBFLevelSingleBitStage4xG : if C_MTBF_STAGES = 4 generate

                SecondaryOutLevelSingleBitD4xAS : SecondaryLevelOutxS    <= SecondaryLevelOutD4xS;
                PrimaryLevelPulseAckD4xAS       : PrimaryLevelPulseAckxS <= PrimaryLevelOutD4xS xor PrimaryLevelOutD5xS;

            end generate MTBFLevelSingleBitStage4xG;

            -- Stage 5
            MTBFLevelSingleBitStage5xG : if C_MTBF_STAGES = 5 generate

                SecondaryOutLevelSingleBitD5xAS : SecondaryLevelOutxS    <= SecondaryLevelOutD5xS;
                PrimaryLevelPulseAckD5xAS       : PrimaryLevelPulseAckxS <= PrimaryLevelOutD5xS xor PrimaryLevelOutD6xS;

            end generate MTBFLevelSingleBitStage5xG;

            -- Stage 6
            MTBFLevelSingleBitStage6xG : if C_MTBF_STAGES = 6 generate

                SecondaryOutLevelSingleBitD6xAS : SecondaryLevelOutxS    <= SecondaryLevelOutD6xS;
                PrimaryLevelPulseAckD6xAS       : PrimaryLevelPulseAckxS <= PrimaryLevelOutD6xS xor PrimaryLevelOutD6xS;

            end generate MTBFLevelSingleBitStage6xG;

            -- Synchronous statements

            PrimaryInputCrossToSecondarySingleBitxP : process (SecondaryClkxCAI) is
            begin  -- process PrimaryInputCrossToSecondarySingleBitxP
                if rising_edge(SecondaryClkxCAI) then
                    if SecondaryResetxRNI = '0' and C_RESET_STATE = 1 then
                        SecondaryLevelOutD1xS <= '0';
                        SecondaryLevelOutD2xS <= '0';
                        SecondaryLevelOutD3xS <= '0';
                        SecondaryLevelOutD4xS <= '0';
                        SecondaryLevelOutD5xS <= '0';
                        SecondaryLevelOutD6xS <= '0';
                    else
                        SecondaryLevelOutD1xS <= PrimaryLevelInxS;
                        SecondaryLevelOutD2xS <= SecondaryLevelOutD1xS;
                        SecondaryLevelOutD3xS <= SecondaryLevelOutD2xS;
                        SecondaryLevelOutD4xS <= SecondaryLevelOutD3xS;
                        SecondaryLevelOutD5xS <= SecondaryLevelOutD4xS;
                        SecondaryLevelOutD6xS <= SecondaryLevelOutD5xS;
                    end if;
                end if;
            end process PrimaryInputCrossToSecondarySingleBitxP;

            SecondaryInputCrossToPrimarySingleBitxP : process (PrimaryClkxCAI) is
            begin  -- process SecondaryInputCrossToPrimarySingleBitxP
                if rising_edge(PrimaryClkxCAI) then
                    if PrimaryResetxRNI = '0' and C_RESET_STATE = 1 then
                        PrimaryLevelOutD1xS <= '0';
                        PrimaryLevelOutD2xS <= '0';
                        PrimaryLevelOutD3xS <= '0';
                        PrimaryLevelOutD4xS <= '0';
                        PrimaryLevelOutD5xS <= '0';
                        PrimaryLevelOutD6xS <= '0';
                        PrimaryAckxSO       <= '0';
                    else
                        PrimaryLevelOutD1xS <= SecondaryLevelOutxS;
                        PrimaryLevelOutD2xS <= PrimaryLevelOutD1xS;
                        PrimaryLevelOutD3xS <= PrimaryLevelOutD2xS;
                        PrimaryLevelOutD4xS <= PrimaryLevelOutD3xS;
                        PrimaryLevelOutD5xS <= PrimaryLevelOutD4xS;
                        PrimaryLevelOutD6xS <= PrimaryLevelOutD5xS;
                        PrimaryAckxSO       <= PrimaryLevelPulseAckxS;
                    end if;
                end if;
            end process SecondaryInputCrossToPrimarySingleBitxP;

        end block LevelSyncWithAckxB;

    end generate GenerateLevelWithAckxG;

end architecture behavioral;
