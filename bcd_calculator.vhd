library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcd_calculator is 

    port
    (
        G_CLOCK_50: in std_logic;                       -- 50 MHz clock from the FPGA.
        V_SW:       in std_logic_vector (17 downto 0);  -- Input vector.
        V_BT:       in std_logic_vector (4 downto 0);   -- Input pressure buttons.
        G_HEX0:     out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX1:     out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX2:     out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX3:     out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX4:     out std_logic_vector (6 downto 0);  -- Show the input B.
        G_HEX5:     out std_logic_vector (6 downto 0);  -- Show the input B.
        G_HEX6:     out std_logic_vector (6 downto 0);  -- Show the input B.
        G_HEX7:     out std_logic_vector (6 downto 0)   -- Show the input B.
    );

end entity bcd_calculator;

architecture bcd_calculator_test of bcd_calculator is

    -- These will be used to trigger the storage of both inputs from the user.
    signal storeA: std_logic := '0';
    signal storeB: std_logic := '0';

    -- This will be used to trigger the reset function.
    signal resetTrigger: std_logic := '0';

    -- This will be used to detect when the 7-seg display has cleares it's output after the reset.
    signal updatedDisplay: std_logic := '0';

    -- These will be used to store the outputs from each of the operations.
    signal additionResult:          std_logic_vector (15 downto 0) := "0000000000000000";
    signal multiplicationResult:    std_logic_vector (31 downto 0) := "00000000000000000000000000000000";
    signal carryOutAdder:           std_logic                      := '0';

    -- This will be used to store a and b input itself.
    signal a: std_logic_vector (15 downto 0) := "0000000000000000";
    signal b: std_logic_vector (15 downto 0) := "0000000000000000";

begin
    
    -- Importing the n-bit adder from another vhdl file.
    nBitAdder: entity work.n_somador (teste)

    port map (
        x => a,
        y => b,
        z => additionResult,
        carry_out => carryOutAdder
    );

    -- Importing the n-bit multiplier from another vhdl file.
    nBitMultiplier: entity work.n_by_m_multiplier (architecture_nbmm)

    port map (
        x => a,
        y => b,
        z => multiplicationResult,
        clk => G_CLOCK_50,
        reset => resetTrigger,
        done => open,
        start => '1'
    );
    -- This will be controller to store the A input.
    process (V_BT (0))
        
        variable storeADelay: std_logic_vector (2 downto 0) := "111";

        begin

            if rising_edge (G_CLOCK_50) then

                if resetTrigger = '1' then
                    storeA <= '0';

                else
                    storeADelay (0) := V_BT (0);
                    storeADelay (1) := storeADelay (0);
                    storeADelay (2) := storeADelay (1);
                    
                    if storeADelay = "000" then
                        storeA <= '1';
                        storeADelay := "111";       
                    end if;
                end if;
            end if;
    end process;

    -- This will be controller to store the B input.
    process (V_BT (1))
        
        variable storeBDelay: std_logic_vector (2 downto 0) := "111";

        begin

            if rising_edge (G_CLOCK_50) then

                if resetTrigger = '1' then
                    storeB <= '0';

                else
                    storeBDelay (0) := V_BT (0);
                    storeBDelay (1) := storeBDelay (0);
                    storeBDelay (2) := storeBDelay (1);
                    
                    if storeBDelay = "000" then
                        storeB <= '1';
                        storeBDelay := "111";       
                    end if;
                end if;
            end if;
    end process;

    -- This will be the reset function.
    process (V_BT (2))
        
        variable storeResetDelay: std_logic_vector (2 downto 0) := "111";

        begin

            if rising_edge (G_CLOCK_50) then

                if updatedDisplay = '1' then
                    resetTrigger <= '0';

                else
                    storeResetDelay (0) := V_BT (2);
                    storeResetDelay (1) := storeResetDelay (0);
                    storeResetDelay (2) := storeResetDelay (1);
                    
                    if storeResetDelay = "000" then
                        resetTrigger <= '1';
                        storeResetDelay := "111";       
                    end if;
                end if;
            end if;
    end process;

    -- This will be responsible to show the input and output in the 7-seg display.
    process (V_SW)

        variable thousandsInputA:                           std_logic_vector (3 downto 0) := "0000";
        variable hundredsInputA:                            std_logic_vector (3 downto 0) := "0000";
        variable tensInputA:                                std_logic_vector (3 downto 0) := "0000";
        variable unitsInputA:                               std_logic_vector (3 downto 0) := "0000";
        variable thousandsInputB:                           std_logic_vector (3 downto 0) := "0000";
        variable hundredsInputB:                            std_logic_vector (3 downto 0) := "0000";
        variable tensInputB:                                std_logic_vector (3 downto 0) := "0000";
        variable unitsInputB:                               std_logic_vector (3 downto 0) := "0000";

        variable tensThousandsAdditionOutput:               std_logic                     := '0';
        variable thousandsAdditionOutput:                   std_logic_vector (3 downto 0) := "0000";
        variable hundredsAdditionOutput:                    std_logic_vector (3 downto 0) := "0000";
        variable tensAdditionOutput:                        std_logic_vector (3 downto 0) := "0000";
        variable unitsAdditionOutput:                       std_logic_vector (3 downto 0) := "0000";

        variable tensMillionsMultiplicationOutput:          std_logic_vector (3 downto 0) := "0000";
        variable millionsMultiplicationOutput:              std_logic_vector (3 downto 0) := "0000";
        variable hundredsThousandsMultiplicationOutput:     std_logic_vector (3 downto 0) := "0000";
        variable tensThousandsMultiplicationOutput:         std_logic_vector (3 downto 0) := "0000";
        variable thousandsMultiplicationOutput:             std_logic_vector (3 downto 0) := "0000";
        variable hundredsMultiplicationOutput:              std_logic_vector (3 downto 0) := "0000";
        variable tensMultiplicationOutput:                  std_logic_vector (3 downto 0) := "0000";
        variable unitsMultiplicationOutput:                 std_logic_vector (3 downto 0) := "0000";

        variable tempVectorAdditionOutput:                  std_logic_vector (15 downto 0) := "0000000000000000";
        variable tempVectorMultiplicationOutput:            std_logic_vector (31 downto 0) := "00000000000000000000000000000000";
        variable tempVectorInput:                           std_logic_vector (15 downto 0) := "0000000000000000";

        begin

            updatedDisplay <= '0'; 

            if resetTrigger = '1' then


                updatedDisplay                          <= '1';
                tempVectorInput                         := "0000000000000000";
                a                                       <= "0000000000000000";
                b                                       <= "0000000000000000";
                
                thousandsInputA                         := "0000";
                hundredsInputA                          := "0000";
                tensInputA                              := "0000";
                unitsInputA                             := "0000";
                thousandsInputB                         := "0000";
                hundredsInputB                          := "0000";
                tensInputB                              := "0000";
                unitsInputB                             := "0000";

                tensThousandsAdditionOutput             := '0';
                thousandsAdditionOutput                 := "0000";
                hundredsAdditionOutput                  := "0000";
                tensAdditionOutput                      := "0000";
                unitsAdditionOutput                     := "0000";

                tensMillionsMultiplicationOutput        := "0000";
                millionsMultiplicationOutput            := "0000";
                hundredsThousandsMultiplicationOutput   := "0000";
                tensThousandsMultiplicationOutput       := "0000";
                thousandsMultiplicationOutput           := "0000";
                hundredsMultiplicationOutput            := "0000";
                tensMultiplicationOutput                := "0000";
                unitsMultiplicationOutput               := "0000";

            elsif storeA = '1' and storeB = '1' and V_SW (17) = '1' then
                
                tensMillionsMultiplicationOutput       := multiplicationResult (31 downto 28);
                millionsMultiplicationOutput           := multiplicationResult (27 downto 24);
                hundredsThousandsMultiplicationOutput  := multiplicationResult (23 downto 20);
                tensThousandsMultiplicationOutput      := multiplicationResult (19 downto 16);
                thousandsMultiplicationOutput          := multiplicationResult (15 downto 12);
                hundredsMultiplicationOutput           := multiplicationResult (11 downto 8);
                tensMultiplicationOutput               := multiplicationResult (7 downto 4);
                unitsMultiplicationOutput              := multiplicationResult (3 downto 0);

                case tensMillionsMultiplicationOutput is
                    when "0000" => G_HEX7 <= "1000000";
                    when "0001" => G_HEX7 <= "1111001";
                    when "0010" => G_HEX7 <= "0100100";
                    when "0011" => G_HEX7 <= "0110000";
                    when "0100" => G_HEX7 <= "0011001";
                    when "0101" => G_HEX7 <= "0010010";
                    when "0110" => G_HEX7 <= "0000010";
                    when "0111" => G_HEX7 <= "1011000";
                    when "1000" => G_HEX7 <= "0000000";
                    when "1001" => G_HEX7 <= "0010000";
                    when "1010" => G_HEX7 <= "0001000";
                    when "1011" => G_HEX7 <= "0000011";
                    when "1100" => G_HEX7 <= "1000110";
                    when "1101" => G_HEX7 <= "0100001";
                    when "1110" => G_HEX7 <= "0000110";
                    when others => G_HEX7 <= "0001110";
                end case;

                case millionsMultiplicationOutput is
                    when "0000" => G_HEX6 <= "1000000";
                    when "0001" => G_HEX6 <= "1111001";
                    when "0010" => G_HEX6 <= "0100100";
                    when "0011" => G_HEX6 <= "0110000";
                    when "0100" => G_HEX6 <= "0011001";
                    when "0101" => G_HEX6 <= "0010010";
                    when "0110" => G_HEX6 <= "0000010";
                    when "0111" => G_HEX6 <= "1011000";
                    when "1000" => G_HEX6 <= "0000000";
                    when "1001" => G_HEX6 <= "0010000";
                    when "1010" => G_HEX6 <= "0001000";
                    when "1011" => G_HEX6 <= "0000011";
                    when "1100" => G_HEX6 <= "1000110";
                    when "1101" => G_HEX6 <= "0100001";
                    when "1110" => G_HEX6 <= "0000110";
                    when others => G_HEX6 <= "0001110";
                end case;

                case hundredsThousandsMultiplicationOutput is
                    when "0000" => G_HEX5 <= "1000000";
                    when "0001" => G_HEX5 <= "1111001";
                    when "0010" => G_HEX5 <= "0100100";
                    when "0011" => G_HEX5 <= "0110000";
                    when "0100" => G_HEX5 <= "0011001";
                    when "0101" => G_HEX5 <= "0010010";
                    when "0110" => G_HEX5 <= "0000010";
                    when "0111" => G_HEX5 <= "1011000";
                    when "1000" => G_HEX5 <= "0000000";
                    when "1001" => G_HEX5 <= "0010000";
                    when "1010" => G_HEX5 <= "0001000";
                    when "1011" => G_HEX5 <= "0000011";
                    when "1100" => G_HEX5 <= "1000110";
                    when "1101" => G_HEX5 <= "0100001";
                    when "1110" => G_HEX5 <= "0000110";
                    when others => G_HEX5 <= "0001110";
                end case;

                case tensThousandsMultiplicationOutput is
                    when "0000" => G_HEX4 <= "1000000";
                    when "0001" => G_HEX4 <= "1111001";
                    when "0010" => G_HEX4 <= "0100100";
                    when "0011" => G_HEX4 <= "0110000";
                    when "0100" => G_HEX4 <= "0011001";
                    when "0101" => G_HEX4 <= "0010010";
                    when "0110" => G_HEX4 <= "0000010";
                    when "0111" => G_HEX4 <= "1011000";
                    when "1000" => G_HEX4 <= "0000000";
                    when "1001" => G_HEX4 <= "0010000";
                    when "1010" => G_HEX4 <= "0001000";
                    when "1011" => G_HEX4 <= "0000011";
                    when "1100" => G_HEX4 <= "1000110";
                    when "1101" => G_HEX4 <= "0100001";
                    when "1110" => G_HEX4 <= "0000110";
                    when others => G_HEX4 <= "0001110";
                end case;

                case thousandsMultiplicationOutput is
                    when "0000" => G_HEX3 <= "1000000";
                    when "0001" => G_HEX3 <= "1111001";
                    when "0010" => G_HEX3 <= "0100100";
                    when "0011" => G_HEX3 <= "0110000";
                    when "0100" => G_HEX3 <= "0011001";
                    when "0101" => G_HEX3 <= "0010010";
                    when "0110" => G_HEX3 <= "0000010";
                    when "0111" => G_HEX3 <= "1011000";
                    when "1000" => G_HEX3 <= "0000000";
                    when "1001" => G_HEX3 <= "0010000";
                    when "1010" => G_HEX3 <= "0001000";
                    when "1011" => G_HEX3 <= "0000011";
                    when "1100" => G_HEX3 <= "1000110";
                    when "1101" => G_HEX3 <= "0100001";
                    when "1110" => G_HEX3 <= "0000110";
                    when others => G_HEX3 <= "0001110";
                end case;

                case hundredsMultiplicationOutput is
                    when "0000" => G_HEX2 <= "1000000";
                    when "0001" => G_HEX2 <= "1111001";
                    when "0010" => G_HEX2 <= "0100100";
                    when "0011" => G_HEX2 <= "0110000";
                    when "0100" => G_HEX2 <= "0011001";
                    when "0101" => G_HEX2 <= "0010010";
                    when "0110" => G_HEX2 <= "0000010";
                    when "0111" => G_HEX2 <= "1011000";
                    when "1000" => G_HEX2 <= "0000000";
                    when "1001" => G_HEX2 <= "0010000";
                    when "1010" => G_HEX2 <= "0001000";
                    when "1011" => G_HEX2 <= "0000011";
                    when "1100" => G_HEX2 <= "1000110";
                    when "1101" => G_HEX2 <= "0100001";
                    when "1110" => G_HEX2 <= "0000110";
                    when others => G_HEX2 <= "0001110";
                end case;
                
                case tensMultiplicationOutput is
                    when "0000" => G_HEX1 <= "1000000";
                    when "0001" => G_HEX1 <= "1111001";
                    when "0010" => G_HEX1 <= "0100100";
                    when "0011" => G_HEX1 <= "0110000";
                    when "0100" => G_HEX1 <= "0011001";
                    when "0101" => G_HEX1 <= "0010010";
                    when "0110" => G_HEX1 <= "0000010";
                    when "0111" => G_HEX1 <= "1011000";
                    when "1000" => G_HEX1 <= "0000000";
                    when "1001" => G_HEX1 <= "0010000";
                    when "1010" => G_HEX1 <= "0001000";
                    when "1011" => G_HEX1 <= "0000011";
                    when "1100" => G_HEX1 <= "1000110";
                    when "1101" => G_HEX1 <= "0100001";
                    when "1110" => G_HEX1 <= "0000110";
                    when others => G_HEX1 <= "0001110";
                end case;
                
                case unitsMultiplicationOutput is
                    when "0000" => G_HEX0 <= "1000000";
                    when "0001" => G_HEX0 <= "1111001";
                    when "0010" => G_HEX0 <= "0100100";
                    when "0011" => G_HEX0 <= "0110000";
                    when "0100" => G_HEX0 <= "0011001";
                    when "0101" => G_HEX0 <= "0010010";
                    when "0110" => G_HEX0 <= "0000010";
                    when "0111" => G_HEX0 <= "1011000";
                    when "1000" => G_HEX0 <= "0000000";
                    when "1001" => G_HEX0 <= "0010000";
                    when "1010" => G_HEX0 <= "0001000";
                    when "1011" => G_HEX0 <= "0000011";
                    when "1100" => G_HEX0 <= "1000110";
                    when "1101" => G_HEX0 <= "0100001";
                    when "1110" => G_HEX0 <= "0000110";
                    when others => G_HEX0 <= "0001110";
                end case;

            elsif storeA = '1' and storeB = '1' and V_SW (16) = '1' then

                tensThousandsAdditionOutput     := carryOutAdder;
                thousandsAdditionOutput         := additionResult (15 downto 12);
                hundredsAdditionOutput          := additionResult (11 downto 8);
                tensAdditionOutput              := additionResult (7 downto 4);
                unitsAdditionOutput             := additionResult (3 downto 0);

                case tensThousandsAdditionOutput is
                    when '0'    => G_HEX4 <= "1000000";
                    when '1'    => G_HEX4 <= "1111001";
                    when others => G_HEX4 <= "0001110";
                end case;

                case thousandsAdditionOutput is
                    when "0000" => G_HEX3 <= "1000000";
                    when "0001" => G_HEX3 <= "1111001";
                    when "0010" => G_HEX3 <= "0100100";
                    when "0011" => G_HEX3 <= "0110000";
                    when "0100" => G_HEX3 <= "0011001";
                    when "0101" => G_HEX3 <= "0010010";
                    when "0110" => G_HEX3 <= "0000010";
                    when "0111" => G_HEX3 <= "1011000";
                    when "1000" => G_HEX3 <= "0000000";
                    when "1001" => G_HEX3 <= "0010000";
                    when "1010" => G_HEX3 <= "0001000";
                    when "1011" => G_HEX3 <= "0000011";
                    when "1100" => G_HEX3 <= "1000110";
                    when "1101" => G_HEX3 <= "0100001";
                    when "1110" => G_HEX3 <= "0000110";
                    when others => G_HEX3 <= "0001110";
                end case;

                case hundredsAdditionOutput is
                    when "0000" => G_HEX2 <= "1000000";
                    when "0001" => G_HEX2 <= "1111001";
                    when "0010" => G_HEX2 <= "0100100";
                    when "0011" => G_HEX2 <= "0110000";
                    when "0100" => G_HEX2 <= "0011001";
                    when "0101" => G_HEX2 <= "0010010";
                    when "0110" => G_HEX2 <= "0000010";
                    when "0111" => G_HEX2 <= "1011000";
                    when "1000" => G_HEX2 <= "0000000";
                    when "1001" => G_HEX2 <= "0010000";
                    when "1010" => G_HEX2 <= "0001000";
                    when "1011" => G_HEX2 <= "0000011";
                    when "1100" => G_HEX2 <= "1000110";
                    when "1101" => G_HEX2 <= "0100001";
                    when "1110" => G_HEX2 <= "0000110";
                    when others => G_HEX2 <= "0001110";
                end case;
                
                case tensAdditionOutput is
                    when "0000" => G_HEX1 <= "1000000";
                    when "0001" => G_HEX1 <= "1111001";
                    when "0010" => G_HEX1 <= "0100100";
                    when "0011" => G_HEX1 <= "0110000";
                    when "0100" => G_HEX1 <= "0011001";
                    when "0101" => G_HEX1 <= "0010010";
                    when "0110" => G_HEX1 <= "0000010";
                    when "0111" => G_HEX1 <= "1011000";
                    when "1000" => G_HEX1 <= "0000000";
                    when "1001" => G_HEX1 <= "0010000";
                    when "1010" => G_HEX1 <= "0001000";
                    when "1011" => G_HEX1 <= "0000011";
                    when "1100" => G_HEX1 <= "1000110";
                    when "1101" => G_HEX1 <= "0100001";
                    when "1110" => G_HEX1 <= "0000110";
                    when others => G_HEX1 <= "0001110";
                end case;
                
                case unitsAdditionOutput is
                    when "0000" => G_HEX0 <= "1000000";
                    when "0001" => G_HEX0 <= "1111001";
                    when "0010" => G_HEX0 <= "0100100";
                    when "0011" => G_HEX0 <= "0110000";
                    when "0100" => G_HEX0 <= "0011001";
                    when "0101" => G_HEX0 <= "0010010";
                    when "0110" => G_HEX0 <= "0000010";
                    when "0111" => G_HEX0 <= "1011000";
                    when "1000" => G_HEX0 <= "0000000";
                    when "1001" => G_HEX0 <= "0010000";
                    when "1010" => G_HEX0 <= "0001000";
                    when "1011" => G_HEX0 <= "0000011";
                    when "1100" => G_HEX0 <= "1000110";
                    when "1101" => G_HEX0 <= "0100001";
                    when "1110" => G_HEX0 <= "0000110";
                    when others => G_HEX0 <= "0001110";
                end case;

            else 

                for i in 0 to 15 loop
                    tempVectorInput (i) := V_SW (i);
                end loop;

                if storeA = '0' then

                    thousandsInputA := tempVectorInput (15 downto 12);
                    hundredsInputA  := tempVectorInput (11 downto 8);
                    tensInputA      := tempVectorInput (7 downto 4);
                    unitsInputA     := tempVectorInput (3 downto 0);

                end if;

                if storeA = '1' then
                    a <= tempVectorInput (15 downto 0);
                    thousandsInputB := tempVectorInput (15 downto 12);
                    hundredsInputB  := tempVectorInput (11 downto 8);
                    tensInputB      := tempVectorInput (7 downto 4);
                    unitsInputB     := tempVectorInput (3 downto 0);
                end if;

                if storeB = '1' then
                    b <= tempVectorInput (15 downto 0);
                end if;

                -- Tables to convert the B input to 7-seg.
                case thousandsInputB is
                    when "0000" => G_HEX3 <= "1000000";
                    when "0001" => G_HEX3 <= "1111001";
                    when "0010" => G_HEX3 <= "0100100";
                    when "0011" => G_HEX3 <= "0110000";
                    when "0100" => G_HEX3 <= "0011001";
                    when "0101" => G_HEX3 <= "0010010";
                    when "0110" => G_HEX3 <= "0000010";
                    when "0111" => G_HEX3 <= "1011000";
                    when "1000" => G_HEX3 <= "0000000";
                    when "1001" => G_HEX3 <= "0010000";
                    when "1010" => G_HEX3 <= "0001000";
                    when "1011" => G_HEX3 <= "0000011";
                    when "1100" => G_HEX3 <= "1000110";
                    when "1101" => G_HEX3 <= "0100001";
                    when "1110" => G_HEX3 <= "0000110";
                    when others => G_HEX3 <= "0001110";
                end case;

                case hundredsInputB is
                    when "0000" => G_HEX2 <= "1000000";
                    when "0001" => G_HEX2 <= "1111001";
                    when "0010" => G_HEX2 <= "0100100";
                    when "0011" => G_HEX2 <= "0110000";
                    when "0100" => G_HEX2 <= "0011001";
                    when "0101" => G_HEX2 <= "0010010";
                    when "0110" => G_HEX2 <= "0000010";
                    when "0111" => G_HEX2 <= "1011000";
                    when "1000" => G_HEX2 <= "0000000";
                    when "1001" => G_HEX2 <= "0010000";
                    when "1010" => G_HEX2 <= "0001000";
                    when "1011" => G_HEX2 <= "0000011";
                    when "1100" => G_HEX2 <= "1000110";
                    when "1101" => G_HEX2 <= "0100001";
                    when "1110" => G_HEX2 <= "0000110";
                    when others => G_HEX2 <= "0001110";
                end case;
                
                case tensInputB is
                    when "0000" => G_HEX1 <= "1000000";
                    when "0001" => G_HEX1 <= "1111001";
                    when "0010" => G_HEX1 <= "0100100";
                    when "0011" => G_HEX1 <= "0110000";
                    when "0100" => G_HEX1 <= "0011001";
                    when "0101" => G_HEX1 <= "0010010";
                    when "0110" => G_HEX1 <= "0000010";
                    when "0111" => G_HEX1 <= "1011000";
                    when "1000" => G_HEX1 <= "0000000";
                    when "1001" => G_HEX1 <= "0010000";
                    when "1010" => G_HEX1 <= "0001000";
                    when "1011" => G_HEX1 <= "0000011";
                    when "1100" => G_HEX1 <= "1000110";
                    when "1101" => G_HEX1 <= "0100001";
                    when "1110" => G_HEX1 <= "0000110";
                    when others => G_HEX1 <= "0001110";
                end case;
                
                case unitsInputB is
                    when "0000" => G_HEX0 <= "1000000";
                    when "0001" => G_HEX0 <= "1111001";
                    when "0010" => G_HEX0 <= "0100100";
                    when "0011" => G_HEX0 <= "0110000";
                    when "0100" => G_HEX0 <= "0011001";
                    when "0101" => G_HEX0 <= "0010010";
                    when "0110" => G_HEX0 <= "0000010";
                    when "0111" => G_HEX0 <= "1011000";
                    when "1000" => G_HEX0 <= "0000000";
                    when "1001" => G_HEX0 <= "0010000";
                    when "1010" => G_HEX0 <= "0001000";
                    when "1011" => G_HEX0 <= "0000011";
                    when "1100" => G_HEX0 <= "1000110";
                    when "1101" => G_HEX0 <= "0100001";
                    when "1110" => G_HEX0 <= "0000110";
                    when others => G_HEX0 <= "0001110";
                end case;

                -- Tables to convert the A input to 7-seg.
                case thousandsInputA is
                    when "0000" => G_HEX7 <= "1000000";
                    when "0001" => G_HEX7 <= "1111001";
                    when "0010" => G_HEX7 <= "0100100";
                    when "0011" => G_HEX7 <= "0110000";
                    when "0100" => G_HEX7 <= "0011001";
                    when "0101" => G_HEX7 <= "0010010";
                    when "0110" => G_HEX7 <= "0000010";
                    when "0111" => G_HEX7 <= "1011000";
                    when "1000" => G_HEX7 <= "0000000";
                    when "1001" => G_HEX7 <= "0010000";
                    when "1010" => G_HEX7 <= "0001000";
                    when "1011" => G_HEX7 <= "0000011";
                    when "1100" => G_HEX7 <= "1000110";
                    when "1101" => G_HEX7 <= "0100001";
                    when "1110" => G_HEX7 <= "0000110";
                    when others => G_HEX7 <= "0001110";
                end case;

                case hundredsInputA is
                    when "0000" => G_HEX6 <= "1000000";
                    when "0001" => G_HEX6 <= "1111001";
                    when "0010" => G_HEX6 <= "0100100";
                    when "0011" => G_HEX6 <= "0110000";
                    when "0100" => G_HEX6 <= "0011001";
                    when "0101" => G_HEX6 <= "0010010";
                    when "0110" => G_HEX6 <= "0000010";
                    when "0111" => G_HEX6 <= "1011000";
                    when "1000" => G_HEX6 <= "0000000";
                    when "1001" => G_HEX6 <= "0010000";
                    when "1010" => G_HEX6 <= "0001000";
                    when "1011" => G_HEX6 <= "0000011";
                    when "1100" => G_HEX6 <= "1000110";
                    when "1101" => G_HEX6 <= "0100001";
                    when "1110" => G_HEX6 <= "0000110";
                    when others => G_HEX6 <= "0001110";
                end case;
                
                case tensInputA is
                    when "0000" => G_HEX5 <= "1000000";
                    when "0001" => G_HEX5 <= "1111001";
                    when "0010" => G_HEX5 <= "0100100";
                    when "0011" => G_HEX5 <= "0110000";
                    when "0100" => G_HEX5 <= "0011001";
                    when "0101" => G_HEX5 <= "0010010";
                    when "0110" => G_HEX5 <= "0000010";
                    when "0111" => G_HEX5 <= "1011000";
                    when "1000" => G_HEX5 <= "0000000";
                    when "1001" => G_HEX5 <= "0010000";
                    when "1010" => G_HEX5 <= "0001000";
                    when "1011" => G_HEX5 <= "0000011";
                    when "1100" => G_HEX5 <= "1000110";
                    when "1101" => G_HEX5 <= "0100001";
                    when "1110" => G_HEX5 <= "0000110";
                    when others => G_HEX5 <= "0001110";
                end case;
                
                case unitsInputA is
                    when "0000" => G_HEX4 <= "1000000";
                    when "0001" => G_HEX4 <= "1111001";
                    when "0010" => G_HEX4 <= "0100100";
                    when "0011" => G_HEX4 <= "0110000";
                    when "0100" => G_HEX4 <= "0011001";
                    when "0101" => G_HEX4 <= "0010010";
                    when "0110" => G_HEX4 <= "0000010";
                    when "0111" => G_HEX4 <= "1011000";
                    when "1000" => G_HEX4 <= "0000000";
                    when "1001" => G_HEX4 <= "0010000";
                    when "1010" => G_HEX4 <= "0001000";
                    when "1011" => G_HEX4 <= "0000011";
                    when "1100" => G_HEX4 <= "1000110";
                    when "1101" => G_HEX4 <= "0100001";
                    when "1110" => G_HEX4 <= "0000110";
                    when others => G_HEX4 <= "0001110";
                end case;
            end if;
    end process;
end architecture;
