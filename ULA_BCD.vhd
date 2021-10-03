LIBRARY IEEE;
 USE IEEE.STD_LOGIC_1164.ALL;
 USE IEEE.STD_LOGIC_ARITH.ALL;
 USE IEEE.STD_LOGIC_UNSIGNED.ALL; 
 
 ENTITY n_by_m_multiplier IS
		generic(n,m:INTEGER:= 4);
	PORT(   x:  IN  STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
			  y:  IN  STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
			start: IN  STD_LOGIC; 
			clk:   IN  STD_LOGIC;
			reset: IN  STD_LOGIC;
			done:  OUT    STD_LOGIC;
			z:  INOUT  STD_LOGIC_VECTOR(4*(n+m)-1 DOWNTO 0));
END n_by_m_multiplier;
 ARCHITECTURE architecture_nbmm OF n_by_m_multiplier IS 

	TYPE states IS RANGE 0 TO 3; SIGNAL 
	current_state: states; 
	CONSTANT initial_zeroes: STD_LOGIC_VECTOR(4*m-5 DOWNTO 0) := (OTHERS => '0');
	SIGNAL int_y: STD_LOGIC_VECTOR(4*n+3 DOWNTO 0);
	siGNAL x_by_yi: STD_LOGIC_VECTOR(4*n+3 DOWNTO 0);
	SIGNAL next_z: STD_LOGIC_VECTOR(4*(n+m)-1 DOWNTO 0);
	SIGNAL z_by_10, long_x_by_yi: STD_LOGIC_VECTOR(4*(n+m)-1 DOWNTO 0);
	SIGNAL load, shift, end_of_computation: STD_LOGIC;
COMPONENT multiplicador_4_x_1 IS  
		generic(n:INTEGER:= 4);
	PORT(   x:  IN   STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
			  y:  IN   STD_LOGIC_VECTOR(3 DOWNTO 0);
			  z:  OUT  STD_LOGIC_VECTOR(4*n+3 DOWNTO 0));
END COMPONENT; 

COMPONENT n_somador IS
		generic(n:INTEGER:= 4);
	PORT(   x:   IN  STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);
			 y:   IN  STD_LOGIC_VECTOR(4*n-1 DOWNTO 0);  
			               
			 z:   OUT STD_LOGIC_VECTOR(4*n-1 DOWNTO 0); 
			 carry_out:  OUT STD_LOGIC);                
END COMPONENT; 
	BEGIN   
	multiplicador:multiplicador_4_x_1      
		generic map (n=>n)
	PORT MAP(      x => x,     
						y => int_y(4*m+3 DOWNTO 4*m),     
						z => x_by_yi);   
					   long_x_by_yi <= initial_zeroes&x_by_yi;  
	
	somador: n_somador      
		  generic map (n=>n+m)
	PORT MAP(       x => long_x_by_yi,       
						 y => z_by_10,                                 
						 z => next_z); 
		 
	z_by_10 <= z(4*(n+m)-5 DOWNTO 0)&"0000"; 
register_y: PROCESS(clk)   
	BEGIN     
	IF clk'EVENT AND clk = '1' THEN       
		IF load = '1' THEN 
			int_y <= y & "1111";       
		ELSIF shift = '1' THEN 
			int_y <= int_y(4*m-1 DOWNTO 0) & "0000";       
		END IF;     
	END IF;  
END PROCESS;   
register_z: PROCESS(clk)   
	BEGIN     
	IF clk'EVENT AND clk = '1' THEN       
		IF load = '1' THEN z <= (OTHERS => '0');       
		ELSIF shift = '1' THEN z <= next_z;       
		END IF;     
	END IF;   
END PROCESS;   

end_of_computation <= int_y(4*m+3) AND int_y(4*m+2); 


control_unit_output: PROCESS(current_state, end_of_computation)   
BEGIN     
	CASE current_state IS       
		WHEN 0 to 1 => 
			shift <= '0'; 
			load <= '0'; 
			done <= '1';       
		WHEN 2 => 
			shift <= '0'; 
			load <= '1'; 
			done <= '0';       
		WHEN 3 => 
			IF end_of_computation = '0' THEN shift <= '1';          
			ELSE shift <= '0'; 
			END IF; 
				load <= '0'; 
				done <= '0';     
	END CASE;   
END PROCESS; 
  
	control_unit_next_state: PROCESS(clk, reset)   
	BEGIN     
		IF reset = '1' THEN current_state <= 0;     
		ELSIF clk'event AND clk = '1' THEN       
			CASE current_state IS         
				WHEN 0 => 	
					IF start = '0' THEN current_state <= 1; 
					END IF;         
				WHEN 1 => IF start = '1' THEN current_state <= 2; 
					END IF;         
				WHEN 2 => current_state <= 3;         
				WHEN 3 => IF end_of_computation = '1' THEN                    
				current_state <= 0; 	
				END IF;       
			END CASE;     
		END IF;   
	END PROCESS; 
END architecture_nbmm;