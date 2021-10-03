LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
				
Entity multiplicador_de_1_digito is
	port( a: in STD_LOGIC_VECTOR(3 DOWNTO 0);
			b: in STD_LOGIC_VECTOR(3 DOWNTO 0);
			d: out STD_LOGIC_VECTOR(3 DOWNTO 0);
			u: out STD_LOGIC_VECTOR(3 DOWNTO 0));
end multiplicador_de_1_digito;
Architecture teste of multiplicador_de_1_digito is
	signal p:  STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal uu:  STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal dd:  STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal gt9,gt20,gt10st19: std_logic;
	begin
		p <= a*b;
		uu <= p(3 downto 0) +("00" & p(4)& p(4) &'0') + ("00"& p(6 downto 5)&'0');
		dd <= p(6 downto 4) + ("00"&p(6 downto 5));
		gt9<= uu(4) or (uu(3) and (uu(2) or uu(1)));
		gt20 <= uu(4) and (uu(3) or uu(2));
		gt10st19 <= gt9 and not (gt20);
		d<= dd + ('0'&'0' & gt20 & gt10st19);
		u<= uu(3 downto 0) + (gt20 & gt9 & gt10st19 &'0');
end teste;