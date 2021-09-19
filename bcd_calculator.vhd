library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcd_calculator is 

    port
    (
        V_SW:   in std_logic_vector (13 downto 0);  -- Input vector.
        G_HEX0: out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX1: out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX2: out std_logic_vector (6 downto 0);  -- Show the input A.
        G_HEX3: out std_logic_vector (6 downto 0)  -- Show the input A.
    );

end entity bcd_calculator;

architecture bcd_calculator_test of bcd_calculator is

begin

    -- This will show the inputs in the 7-seg display.
    process (V_SW)

        variable temp:  std_logic_vector (29 downto 0);
        variable u:     std_logic_vector (3 downto 0) := "0000"; -- Units. 
        variable t:     std_logic_vector (3 downto 0) := "0000"; -- Tens.
        variable h:     std_logic_vector (3 downto 0) := "0000"; -- Hundreds.
        variable k:     std_logic_vector (3 downto 0) := "0000"; -- Thousands.

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

            k := temp (29 downto 26);
            h := temp (25 downto 22);
            t := temp (21 downto 18);
            u := temp (17 downto 14);

            -- Tables to convert the input to 7-seg.

            case k is
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

            case h is
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
            
            case t is
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
            
            case u is
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

    end process;
end architecture;
