LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
Entity multiplicador_4_x_1 is
	generic(n:INTEGER:= 4);
	port( x: in STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
			y: in STD_LOGIC_VECTOR(n-1 DOWNTO 0);
			z: out STD_LOGIC_VECTOR(4*n+3 DOWNTO 0));
end multiplicador_4_x_1;

architecture teste of multiplicador_4_x_1 is
	signal dd, uu: STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
	signal ddc, uuc: STD_LOGIC_VECTOR(4*n+3 DOWNTO 0);
	signal carries: STD_LOGIC_VECTOR(n+1 DOWNTO 0);
	
component multiplicador_de_1_digito is
	port ( a: in STD_LOGIC_VECTOR(3 DOWNTO 0);
			b: in STD_LOGIC_VECTOR(3 DOWNTO 0);
			d: out STD_LOGIC_VECTOR(3 DOWNTO 0);
			u: out STD_LOGIC_VECTOR(3 DOWNTO 0));
end component;
component somador_de_1_digito is
	PORT(    a:        IN    STD_LOGIC_VECTOR(3 DOWNTO 0);   
				b:        IN    STD_LOGIC_VECTOR(3 DOWNTO 0);   
				c:        OUT   STD_LOGIC_VECTOR(3 DOWNTO 0); 
				cy_in:    IN    STD_LOGIC;
				cy_out:   INOUT STD_LOGIC);
end component;
	begin 
	a_iteration: FOR i IN 0 TO 3 GENERATE  
	multiplicador: multiplicador_de_1_digito
	PORT MAP( a => x(4*i+3 DOWNTO 4*i),       
				 b => y,       
				 d => dd(4*i+3 DOWNTO 4*i),       
				 u => uu(4*i+3 DOWNTO 4*i));       
				     
END GENERATE;	
	ddc<=dd &"0000";
	uuc<="0000"& uu;
	carries(0)<='0';
	
	b_iteration: FOR i IN 0 TO 4 GENERATE  
	addition: somador_de_1_digito 
	PORT MAP( a => ddc(4*i+3 DOWNTO 4*i),       
				 b => uuc(4*i+3 DOWNTO 4*i),       
				 c => z(4*i+3 DOWNTO 4*i),       
				 cy_in => carries(i),       
				 cy_out => carries(i+1));     
END GENERATE;
end teste;
	