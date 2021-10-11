library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity n_digit_adder is

    generic (n : integer := 4);
	
    port (    

        x:          in  std_logic_vector (4 * n - 1 downto 0);
	    y:          in  std_logic_vector (4 * n - 1 downto 0);
		z:          out std_logic_vector (4 * n - 1 downto 0);
		carry_out:  out std_logic
    );

end n_digit_adder;

architecture test of n_digit_adder is

signal carries: std_logic_vector (n downto 0);
signal z1:      std_logic_vector (4 * n - 1 downto 0);

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
	
	carries(0) <= '0';   

	a1_iteration: for i in 0 to n-1 generate  
	adder: one_digit_adder 
	
    port map ( 

        a => x (4 * i + 3 downto 4 * i),       
	    b => y (4 * i + 3 downto 4 * i),       
		c => z1 (4 * i + 3 downto 4 * i),       
	    cy_in => carries (i),       
		cy_out => carries (i + 1)
    );

end generate;
   
	z <= z1;
	carry_out <= carries (n - 1); 
	
end test;		
