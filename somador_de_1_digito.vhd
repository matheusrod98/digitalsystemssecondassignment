LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 


ENTITY somador_de_1_digito IS 
	PORT(    a:        IN    STD_LOGIC_VECTOR(3 DOWNTO 0);   
				b:        IN    STD_LOGIC_VECTOR(3 DOWNTO 0);   
				c:        OUT   STD_LOGIC_VECTOR(3 DOWNTO 0); 
				cy_in:    IN    STD_LOGIC;
				cy_out:   INOUT STD_LOGIC);
END somador_de_1_digito;

ARCHITECTURE teste OF somador_de_1_digito IS
	SIGNAL soma: STD_LOGIC_VECTOR(4 DOWNTO 0); 
	SIGNAL ajuste: STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN   
	soma <= '0' & a + b + cy_in;                        
	cy_out <= soma(4) OR (soma(3) AND (soma(2) OR soma(1)));
	ajuste <= '0' & cy_out & cy_out & '0';
	c <= soma(3 DOWNTO 0) + ajuste;
END teste; 
 
