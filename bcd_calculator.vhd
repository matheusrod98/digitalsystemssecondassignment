library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcd_calculator is 

    port
    (
        G_CLOCK_50: in std_logic;                       -- 50 MHz clock from the FPGA.
        V_SW:       in std_logic_vector (13 downto 0);  -- Input vector.
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

    -- This will be used to store the result of the calculations in binary.
    signal result: std_logic_vector (26 downto 0) := "000000000000000000000000000";

    -- This will be used to store a and b input itself.
    signal a: std_logic_vector (15 downto 0) := "000000000000000";
    signal b: std_logic_vector (15 downto 0) := "000000000000000";

begin
    
    -- Importing the n-bit adder from another vhdl file.
    nBitAdder: entity work.n_somador.vhd (teste)

    port map (
        x => a,
        y => b,
        z => result,
        carry_out => open
    );

    -- This will be controller to store the A input.
    process (V_BT (0))
        
        variable storeADelay: std_logic_vector (2 downto 0) := "111";

        begin

            if rising_edge (G_CLOCK_50) then
                storeADelay (0) := V_BT (0);
                storeADelay (1) := storeADelay (0);
                storeADelay (2) := storeADelay (1);
                
                if storeADelay = "000" then
                    storeA <= '1';
                    storeADelay := "111";       
                end if;

            end if;
    end process;

    -- This will be controller to store the B input.
    process (V_BT (1))
        
        variable storeBDelay: std_logic_vector (2 downto 0) := "111";

        begin

            if rising_edge (G_CLOCK_50) then
                storeBDelay (0) := V_BT (1);
                storeBDelay (1) := storeBDelay (0);
                storeBDelay (2) := storeBDelay (1);
                
                if storeBDelay = "000" then
                    storeB <= '1';
                    storeBDelay := "111";       
                end if;

            end if;
    end process;

    -- This will be the reset function.
    process (V_BT (2))
        
        variable storeResetDelay: std_logic_vector (2 downto 0) := "111";

        begin

            if rising_edge (G_CLOCK_50) then
                storeResetDelay (0) := V_BT (2);
                storeResetDelay (1) := storeResetDelay (0);
                storeResetDelay (2) := storeResetDelay (1);
                
                if storeResetDelay = "000" then
                    resetTrigger <= '1';
                    storeResetDelay := "111";       
                end if;

            end if;
    end process;

    -- This will be the interface controller.
    process (V_SW)

        -- These will be used to show the input in the 7-seg displays.
        variable thousandsA:   std_logic_vector (3 downto 0) := "0000"; -- Thousands of the A input.
        variable hundredsA:    std_logic_vector (3 downto 0) := "0000"; -- Hundreds of the A input.
        variable tensA:        std_logic_vector (3 downto 0) := "0000"; -- Tens of the A input.
        variable unitsA:       std_logic_vector (3 downto 0) := "0000"; -- Units of the A input.
        variable thousandsB:   std_logic_vector (3 downto 0) := "0000"; -- Thousands of the B input.
        variable hundredsB:    std_logic_vector (3 downto 0) := "0000"; -- Hundreds of the B input.
        variable tensB:        std_logic_vector (3 downto 0) := "0000"; -- Tens of the B input.
        variable unitsB:       std_logic_vector (3 downto 0) := "0000"; -- Units of the B input.

        thousandsA:= V_SW (15 downto 12);
        hundredsA  := V_SW (11 downto 8);
        tensA      := V_SW (7 downto 4);
        unitsA     := V_SW (3 downto 0);

        if storeA = '1' then
            a <= V_SW (15 downto 0);
            thousandsB := V_SW (15 downto 12);
            hundredsB  := V_SW (11 downto 8);
            tensB      := V_SW (7 downto 4);
            unitsB     := V_SW (3 downto 0);
        end if;

        if storeB = '1' then
            b <= V_SW (15 downto 0);
        end if;

        if resetTrigger = 1 then
            
            thousandsA := "0000";
            hundredsA  := "0000";
            tensA      := "0000";
            unitsA     := "0000";
            thousandsB := "0000";
            hundredsB  := "0000";
            tensB      := "0000";
            unitsB     := "0000";
            a <= "0000000000000000";
            b <= "0000000000000000";

        end if;

        -- Tables to convert the B input to 7-seg.
        case thousandsB is
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

        case hundredsB is
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
        
        case tensB is
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
        
        case unitsB is
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
        case thousandsA is
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

        case hundredsA is
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
        
        case tensA is
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
        
        case unitsA is
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
    end process;
end architecture;
