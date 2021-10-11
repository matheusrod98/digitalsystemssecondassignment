library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;

entity four_one_multiplier is

    generic (n: integer := 4);
	
    port (
             x: in std_logic_vector (4 * n - 1 downto 0);
		     y: in std_logic_vector (n - 1 downto 0);
			 z: out std_logic_vector (4 * n + 3 downto 0)
    );

end four_one_multiplier;

architecture test of four_one_multiplier is
	
    signal dd, uu:   std_logic_vector (4 * n - 1 downto 0);
	signal ddc, uuc: std_logic_vector (4 * n + 3 downto 0);
	signal carries:  std_logic_vector (n + 1 downto 0);

    component one_digit_multiplier is

        port (
                 a: in std_logic_vector (3 downto 0);
			     b: in std_logic_vector (3 downto 0);
			     d: out std_logic_vector (3 downto 0);
			     u: out std_logic_vector (3 downto 0)
        );

    end component;

    component one_digit_adder is

        port (
                 a:      in    std_logic_vector (3 downto 0);   
				 b:      in    std_logic_vector (3 downto 0);   
				 c:      out   std_logic_vector (3 downto 0); 
				 cy_in:  in    std_logic;
				 cy_out: inout std_logic
        );

    end component;

begin

    a_iteration: for i in 0 to 3 generate
        
        multiplier: one_digit_multiplier

        port map (
                 a => x (4 * i + 3 downto 4 * i),       
				 b => y,       
				 d => dd (4 * i + 3 downto 4 * i),       
				 u => uu (4 * i + 3 downto 4 * i)
        );

    end generate;

    ddc <= dd & "0000";
    uuc <= "0000" & uu;
    carries (0) <= '0';

    b_iteration: for i in 0 to 4 generate

        addition: one_digit_adder
        
        port map (
                     a => ddc (4 * i + 3 downto 4 * i),       
				     b => uuc (4 * i + 3 downto 4 * i),       
				     c => z (4 * i + 3 downto 4 * i),       
				     cy_in => carries (i),       
				     cy_out => carries (i + 1)
        );

    end generate;
end test;
