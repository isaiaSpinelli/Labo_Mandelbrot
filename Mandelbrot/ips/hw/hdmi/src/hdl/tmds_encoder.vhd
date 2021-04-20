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
-- Module Name: tmds_encoder - behavioural
-- Target Device: All
-- Tool version: 2018.3
-- Description: TMDS Encoder
--
-- Last update: 2019-02-15
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdmi_interface_pkg.all;

entity tmds_encoder is

    generic (
        C_TMDS_DATA_SIZE         : integer := 8;
        C_TMDS_ENCODED_DATA_SIZE : integer := 10);

    port (
        ClkxCI             : in  std_logic;
        TmdsDataxDI        : in  std_logic_vector((C_TMDS_DATA_SIZE - 1) downto 0);
        ControlxDI         : in  std_logic_vector(1 downto 0);
        VidOnxSI           : in  std_logic;
        TmdsEncodedDataxDO : out std_logic_vector((C_TMDS_ENCODED_DATA_SIZE - 1) downto 0));

end entity tmds_encoder;

architecture behavioural of tmds_encoder is

    constant C_XOR_XNOR_DATA_SIZE       : integer := 9;
    constant C_NOO_DATA_SIZE            : integer := 4;
    constant C_WORD_DATA_SIZE           : integer := 9;
    constant C_WORD_DISPARITY_DATA_SIZE : integer := 4;
    constant C_DC_BIAS_DATA_SIZE        : integer := 4;

    signal XorMinTransxD       : std_logic_vector((C_XOR_XNOR_DATA_SIZE - 1) downto 0)       := (others => '0');
    signal XnorMinTransxD      : std_logic_vector((C_XOR_XNOR_DATA_SIZE - 1) downto 0)       := (others => '0');
    signal NumberOfOnesxD      : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0)            := (others => '0');
    signal DataWordxD          : std_logic_vector((C_WORD_DATA_SIZE - 1) downto 0)           := (others => '0');
    signal DataWordInvxD       : std_logic_vector((C_WORD_DATA_SIZE - 1) downto 0)           := (others => '0');
    signal DataWordDisparityxD : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
    signal DcBiasxD            : std_logic_vector((C_DC_BIAS_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal DataWord8xD         : std_logic_vector((C_DC_BIAS_DATA_SIZE - 1) downto 0)        := (others => '0');
    signal DataWordInv8xD      : std_logic_vector((C_DC_BIAS_DATA_SIZE - 1) downto 0)        := (others => '0');

begin  -- architecture behavioural

    -- Asynchronous statements

    DataWord8xB : block is
    begin  -- block DataWord8xB
        
        DataWord8xAS    : DataWord8xD    <= "000" & DataWordxD(8);
        DataWordInv8xAS : DataWordInv8xD <= "000" & DataWordInvxD(8);
        
    end block DataWord8xB;

    MinimizeTransitionsxB : block is
    begin  -- block MinimizeTransitionsxB
        
        -- XOR
        XorMinTrans0xAS  : XorMinTransxD(0)  <= TmdsDataxDI(0);
        XorMinTrans1xAS  : XorMinTransxD(1)  <= TmdsDataxDI(1) xor XorMinTransxD(0);
        XorMinTrans2xAS  : XorMinTransxD(2)  <= TmdsDataxDI(2) xor XorMinTransxD(1);
        XorMinTrans3xAS  : XorMinTransxD(3)  <= TmdsDataxDI(3) xor XorMinTransxD(2);
        XorMinTrans4xAS  : XorMinTransxD(4)  <= TmdsDataxDI(4) xor XorMinTransxD(3);
        XorMinTrans5xAS  : XorMinTransxD(5)  <= TmdsDataxDI(5) xor XorMinTransxD(4);
        XorMinTrans6xAS  : XorMinTransxD(6)  <= TmdsDataxDI(6) xor XorMinTransxD(5);
        XorMinTrans7xAS  : XorMinTransxD(7)  <= TmdsDataxDI(7) xor XorMinTransxD(6);
        XorMinTrans8xAS  : XorMinTransxD(8)  <= '1';
        -- XNOR
        XnorMinTrans0xAS : XnorMinTransxD(0) <= TmdsDataxDI(0);
        XnorMinTrans1xAS : XnorMinTransxD(1) <= TmdsDataxDI(1) xnor XnorMinTransxD(0);
        XnorMinTrans2xAS : XnorMinTransxD(2) <= TmdsDataxDI(2) xnor XnorMinTransxD(1);
        XnorMinTrans3xAS : XnorMinTransxD(3) <= TmdsDataxDI(3) xnor XnorMinTransxD(2);
        XnorMinTrans4xAS : XnorMinTransxD(4) <= TmdsDataxDI(4) xnor XnorMinTransxD(3);
        XnorMinTrans5xAS : XnorMinTransxD(5) <= TmdsDataxDI(5) xnor XnorMinTransxD(4);
        XnorMinTrans6xAS : XnorMinTransxD(6) <= TmdsDataxDI(6) xnor XnorMinTransxD(5);
        XnorMinTrans7xAS : XnorMinTransxD(7) <= TmdsDataxDI(7) xnor XnorMinTransxD(6);
        XnorMinTrans8xAS : XnorMinTransxD(8) <= '0';
        
    end block MinimizeTransitionsxB;

    NumberOfOnesxB : block is

        signal NumberOfOnesInitxD : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData0xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData1xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData2xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData3xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData4xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData5xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData6xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');
        signal TmdsData7xD        : std_logic_vector((C_NOO_DATA_SIZE - 1) downto 0) := (others => '0');

    begin  -- block NumberOfOnesxB

        NumberOfOnesInitxAS : NumberOfOnesInitxD <= "0000";
        TmdsData0xAS        : TmdsData0xD        <= "000" & TmdsDataxDI(0);
        TmdsData1xAS        : TmdsData1xD        <= "000" & TmdsDataxDI(1);
        TmdsData2xAS        : TmdsData2xD        <= "000" & TmdsDataxDI(2);
        TmdsData3xAS        : TmdsData3xD        <= "000" & TmdsDataxDI(3);
        TmdsData4xAS        : TmdsData4xD        <= "000" & TmdsDataxDI(4);
        TmdsData5xAS        : TmdsData5xD        <= "000" & TmdsDataxDI(5);
        TmdsData6xAS        : TmdsData6xD        <= "000" & TmdsDataxDI(6);
        TmdsData7xAS        : TmdsData7xD        <= "000" & TmdsDataxDI(7);

        NumberOfOnesxAS : NumberOfOnesxD <= std_logic_vector(
            to_unsigned(to_integer(unsigned(NumberOfOnesInitxD)) +
                        to_integer(unsigned(TmdsData0xD)) +
                        to_integer(unsigned(TmdsData1xD)) +
                        to_integer(unsigned(TmdsData2xD)) +
                        to_integer(unsigned(TmdsData3xD)) +
                        to_integer(unsigned(TmdsData4xD)) +
                        to_integer(unsigned(TmdsData5xD)) +
                        to_integer(unsigned(TmdsData6xD)) +
                        to_integer(unsigned(TmdsData7xD)),
                        C_NOO_DATA_SIZE));
        
    end block NumberOfOnesxB;

    -- purpose: Encoding selection process
    -- type   : combinational
    -- inputs : all
    -- outputs: 
    EncodingSelectionxP : process (all) is
    begin  -- process EncodingSelectionxP
        DataWordxD    <= XorMinTransxD;
        DataWordInvxD <= not XorMinTransxD;

        if (to_integer(unsigned(NumberOfOnesxD)) > 4) or
            ((to_integer(unsigned(NumberOfOnesxD)) = 4) and
             (TmdsDataxDI(0) = '0')) then
            DataWordxD    <= XnorMinTransxD;
            DataWordInvxD <= not XnorMinTransxD;
        end if;
    end process EncodingSelectionxP;

    DataWordDisparityxB : block is

        signal DataWordDisparityInitxD : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord0xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord1xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord2xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord3xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord4xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord5xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord6xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');
        signal DataWord7xD             : std_logic_vector((C_WORD_DISPARITY_DATA_SIZE - 1) downto 0) := (others => '0');

    begin  -- block DataWordDisparityxB
        
        DataWordDisparityInitxAS : DataWordDisparityInitxD <= "1100";
        DataWord0xAS             : DataWord0xD             <= "000" & DataWordxD(0);
        DataWord1xAS             : DataWord1xD             <= "000" & DataWordxD(1);
        DataWord2xAS             : DataWord2xD             <= "000" & DataWordxD(2);
        DataWord3xAS             : DataWord3xD             <= "000" & DataWordxD(3);
        DataWord4xAS             : DataWord4xD             <= "000" & DataWordxD(4);
        DataWord5xAS             : DataWord5xD             <= "000" & DataWordxD(5);
        DataWord6xAS             : DataWord6xD             <= "000" & DataWordxD(6);
        DataWord7xAS             : DataWord7xD             <= "000" & DataWordxD(7);

        DataWordDisparityxAS : DataWordDisparityxD <= std_logic_vector(
            to_unsigned(to_integer(unsigned(DataWordDisparityInitxD)) +
                        to_integer(unsigned(DataWord0xD)) +
                        to_integer(unsigned(DataWord1xD)) +
                        to_integer(unsigned(DataWord2xD)) +
                        to_integer(unsigned(DataWord3xD)) +
                        to_integer(unsigned(DataWord4xD)) +
                        to_integer(unsigned(DataWord5xD)) +
                        to_integer(unsigned(DataWord6xD)) +
                        to_integer(unsigned(DataWord7xD)),
                        C_WORD_DISPARITY_DATA_SIZE));
        
    end block DataWordDisparityxB;

    -- Synchronous statements

    -- purpose: Encoding the TMDS output
    -- type   : combinational
    -- inputs : all
    -- outputs: 
    TmdsEncodedDataxP : process (ClkxCI) is
    begin  -- process TmdsEncodedDataxP
        if rising_edge(ClkxCI) then
            if VidOnxSI = '0' then
                DcBiasxD <= (others => '0');

                case ControlxDI is
                    when "00"   => TmdsEncodedDataxDO <= "1101010100";
                    when "01"   => TmdsEncodedDataxDO <= "0010101011";
                    when "10"   => TmdsEncodedDataxDO <= "0101010100";
                    when others => TmdsEncodedDataxDO <= "1010101011";
                end case;
            else
                if (DcBiasxD = "0000") or (to_integer(unsigned(DataWordDisparityxD)) = 0) then
                    if DataWordxD(8) = '1' then
                        TmdsEncodedDataxDO <= "01" & DataWordxD(7 downto 0);
                        DcBiasxD           <= std_logic_vector(unsigned(DcBiasxD) + unsigned(DataWordDisparityxD));
                    else
                        TmdsEncodedDataxDO <= "10" & DataWordInvxD(7 downto 0);
                        DcBiasxD           <= std_logic_vector(unsigned(DcBiasxD) - unsigned(DataWordDisparityxD));
                    end if;
                elsif ((DcBiasxD(3) = '0') and (DataWordDisparityxD(3) = '0')) or
                    ((DcBiasxD(3) = '1') and (DataWordDisparityxD(3) = '1')) then
                    TmdsEncodedDataxDO <= '1' & DataWordxD(8) & DataWordInvxD(7 downto 0);
                    DcBiasxD <= std_logic_vector(to_unsigned(to_integer(unsigned(DcBiasxD)) +
                                                             to_integer(unsigned(DataWord8xD)) -
                                                             to_integer(unsigned(DataWordDisparityxD)),
                                                             C_DC_BIAS_DATA_SIZE));
                else
                    TmdsEncodedDataxDO <= '0' & DataWordxD;
                    DcBiasxD <= std_logic_vector(to_unsigned(to_integer(unsigned(DcBiasxD)) -
                                                             to_integer(unsigned(DataWordInv8xD)) +
                                                             to_integer(unsigned(DataWordDisparityxD)),
                                                             C_DC_BIAS_DATA_SIZE));
                end if;
            end if;
        end if;
    end process TmdsEncodedDataxP;

end architecture behavioural;
