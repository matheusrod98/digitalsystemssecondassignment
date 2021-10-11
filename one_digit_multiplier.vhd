library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
				
entity one_digit_multiplier is
    
    port (
             a: in std_logic_vector (3 downto 0);
			 b: in std_logic_vector (3 downto 0);
			 d: out std_logic_vector (3 downto 0);
			 u: out std_logic_vector (3 downto 0)
    );

end one_digit_multiplier;

architecture test of one_digit_multiplier is

    signal p:  std_logic_vector (7 downto 0);
	signal uu: std_logic_vector (4 downto 0);
	signal dd: std_logic_vector (3 downto 0);
	signal gt9, gt20, gt10st19: std_logic;

begin
    
    p        <= a * b;
	uu       <= p (3 downto 0) + ("00" & p (4) & p (4) & '0') + ("00" & p (6 downto 5) & '0');
	dd       <= p (6 downto 4) + ("00" & p (6 downto 5));
	gt9      <= uu (4) or (uu (3) and (uu (2) or uu (1)));
	gt20     <= uu (4) and (uu (3) or uu (2));
	gt10st19 <= gt9 and not (gt20);
	d        <= dd + ('0' & '0' & gt20 & gt10st19);
	u        <= uu (3 downto 0) + (gt20 & gt9 & gt10st19 & '0');

end test;
