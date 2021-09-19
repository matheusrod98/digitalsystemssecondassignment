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

    -- These will be used to store both inputs from the user.
    signal storeA: std_logic := '0';
    signal storeB: std_logic := '0';

begin
    
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

    -- This will show the inputs in the 7-seg display.
    process (V_SW)

        variable temp:         std_logic_vector (29 downto 0);

        variable thousandsA:   std_logic_vector (3 downto 0) := "0000"; -- Thousands of the A input.
        variable hundredsA:    std_logic_vector (3 downto 0) := "0000"; -- Hundreds of the A input.
        variable tensA:        std_logic_vector (3 downto 0) := "0000"; -- Tens of the A input.
        variable unitsA:       std_logic_vector (3 downto 0) := "0000"; -- Units of the A input.

        variable thousandsB:   std_logic_vector (3 downto 0) := "0000"; -- Thousands of the B input.
        variable hundredsB:    std_logic_vector (3 downto 0) := "0000"; -- Hundreds of the B input.
        variable tensB:        std_logic_vector (3 downto 0) := "0000"; -- Tens of the B input.
        variable unitsB:       std_logic_vector (3 downto 0) := "0000"; -- Units of the B input.

        begin

            -- Double-dabble to convert a binary vector to a BCD vector.
            for i in 0 to 29 loop
                temp (i) := '0';
            end loop;
        
            temp (13 downto 0) := V_SW; 

            for i in 0 to 13 loop

                if temp (17 downto 14) > 4 then
                    temp (17 downto 14) := temp (17 downto 14) + 3;
                end if;

                if temp (21 downto 18) > 4 then
                    temp (21 downto 18) := temp (21 downto 18) + 3;
                end if;

                if temp (25 downto 22) > 4 then
                    temp (25 downto 22) := temp (25 downto 22) + 3;
                end if;

                temp (29 downto 1) := temp (28 downto 0);
            end loop;
            
            if storeA = '0' then
                thousandsA := temp (29 downto 26);
                hundredsA  := temp (25 downto 22);
                tensA      := temp (21 downto 18);
                unitsA     := temp (17 downto 14);
            end if;

            if (storeB = '0') and (storeA = '1') then
                thousandsB := temp (29 downto 26);
                hundredsB  := temp (25 downto 22);
                tensB      := temp (21 downto 18);
                unitsB     := temp (17 downto 14);
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
