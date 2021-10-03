LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL; 

ENTITY n_somador IS
	generic(n:INTEGER:= 4);
	PORT(    x:   IN  STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
				y:   IN  STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
				z:   OUT STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
				carry_out:  OUT STD_LOGIC);
END n_somador;

ARCHITECTURE teste OF n_somador IS 
CONSTANT i1: STD_LOGIC_VECTOR(4*n-1 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1,4*n);
SIGNAL carries,carries2: STD_LOGIC_VECTOR(n DOWNTO 0);
SIGNAL y1: STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
SIGNAL z1,z2,z3: STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
SIGNAL oc, output_selection: STD_LOGIC; 

COMPONENT somador_de_1_digito IS 
	PORT(   a:        IN    STD_LOGIC_VECTOR(3 DOWNTO 0);   
			  b:        IN    STD_LOGIC_VECTOR(3 DOWNTO 0);   
			  c:        OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
			  cy_in:    IN    STD_LOGIC;  
			  cy_out:   INOUT STD_LOGIC);
END COMPONENT;

BEGIN
	
	carries(0) <= '0';   
	a1_iteration: FOR i IN 0 TO n-1 GENERATE  
	somador: somador_de_1_digito 
	PORT MAP( a => x(4*i+3 DOWNTO 4*i),       
				 b => y(4*i+3 DOWNTO 4*i),       
				 c => z1(4*i+3 DOWNTO 4*i),       
				 cy_in => carries(i),       
				 cy_out => carries(i+1));     
END GENERATE;
   
	z<=z1  ;
	carry_out <= oc XOR '0';   
	
	END teste;
			