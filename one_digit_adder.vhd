library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 

entity one_digit_adder is 

	port (    
        
        a:      in    std_logic_vector (3 downto 0);   
		b:      in    std_logic_vector (3 downto 0);   
		c:      out   std_logic_vector (3 downto 0); 
		cy_in:  in    std_logic;
		cy_out: inout std_logic
    );

end one_digit_adder;

architecture test of one_digit_adder is

	signal sum:    std_logic_vector (4 downto 0); 
	signal adjust: std_logic_vector (3 downto 0);

begin   

	sum <= '0' & a + b + cy_in;                        
	cy_out <= sum (4) or (sum (3) and (sum (2) or sum (1)));
	adjust <= '0' & cy_out & cy_out & '0';
	c <= sum (3 downto 0) + adjust;

end test; 
