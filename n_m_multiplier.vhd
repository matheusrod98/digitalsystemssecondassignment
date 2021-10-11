library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
 
entity n_m_multiplier is
		
    generic (n, m: integer := 4);
	
    port (
        x:     in  std_logic_vector(4*n-1 downto 0);
		y:     in  std_logic_vector(4*m-1 downto 0);
	    start: in  std_logic; 
		clk:   in  std_logic;
		reset: in  std_logic;
		done:  out std_logic;
		z:     inout std_logic_vector(4*(n+m)-1 downto 0)
    );

end n_m_multiplier;

architecture architecture_nbmm of n_m_multiplier is 

	type states is range 0 to 3; 
    signal current_state: states; 
	
    constant initial_zeroes:                std_logic_vector (4 * m - 5 downto 0) := (others => '0');
	signal int_y:                           std_logic_vector (4 * n + 3 downto 0);
	signal x_by_yi:                         std_logic_vector (4 * n + 3 downto 0);
	signal next_z:                          std_logic_vector (4 * (n + m) - 1 downto 0);
	signal z_by_10, long_x_by_yi:           std_logic_vector (4 * (n + m) -1 downto 0);
	signal load, shift, end_of_computation: std_logic;

    component four_one_multiplier is  
	
        generic (n: integer := 4);
	
        port (
                x: in std_logic_vector (4 * n - 1 downto 0);
			    y: in std_logic_vector (3 downto 0);
			    z: out std_logic_vector (4 * n + 3 downto 0)
            );

    end component;

    component n_digit_adder is
        
        generic (n: integer := 4);
	
        port (
             x:         in std_logic_vector (4 * n - 1 downto 0);
			 y:         in std_logic_vector (4 * n - 1 downto 0);  
			 z:         out std_logic_vector (4 * n - 1 downto 0); 
			 carry_out: out std_logic
        );

    end component; 
	
begin   
    
    multiplier: four_one_multiplier      
	
    generic map (n => n)
	
    port map (
                 x => x,     
				 y => int_y (4 * m + 3 downto 4 * m),     
				 z => x_by_yi
    );
				 
    long_x_by_yi <= initial_zeroes & x_by_yi;  

	adder: n_digit_adder
		  
    generic map (n => n + m)
	
    port map (
                 x => long_x_by_yi,       
				 y => z_by_10,                                 
			     z => next_z
    ); 

    z_by_10 <= z (4 * (n + m) - 5 downto 0) & "0000"; 
    register_y: process (clk)   
	
    begin     
	
        if clk 'event and clk = '1' then       
		
            if load = '1' then 
                
                int_y <= y & "1111";
            
            elsif shift = '1' then 
                int_y <= int_y (4 * m - 1 downto 0) & "0000";
            end if;

        end if;
    end process;   

    register_z: process(clk)   
	
    begin     
	
        if clk 'event and clk = '1' then
            if load = '1' then
                z <= (others => '0');       
		    elsif shift = '1' then
                z <= next_z;       
		    end if;
        end if;   

    end process;

    end_of_computation <= int_y (4 * m + 3) and int_y (4 * m + 2);
    control_unit_output: process (current_state, end_of_computation)   

    begin     
	
        case current_state is       
		
            when 0 to 1 => 
			    
                shift <= '0'; 
			    load  <= '0'; 
			    done  <= '1';       
		
            when 2 => 
			    
                shift <= '0'; 
			    load  <= '1'; 
			    done  <= '0';       
		    
            when 3 => 
			    
                if end_of_computation = '0' then 
                    shift <= '1';          
			    else 
                    shift <= '0'; 
			    end if;

                load <= '0'; 
				done <= '0';
        end case;

    end process;

    control_unit_next_state: process (clk, reset)

    begin

        if reset = '1' then 
            current_state <= 0;     
		elsif clk 'event and clk = '1' then

            case current_state is         
				
                when 0 =>

					if start = '0' then
                        current_state <= 1; 
                    end if; 

				when 1 => 
                    
                    if start = '1' then
                        current_state <= 2; 
					end if;

				when 2 =>
                    
                    current_state <= 3;         
				
                when 3 =>

                    if end_of_computation = '1' then                    
				        current_state <= 0; 	
				    end if;
            end case;
        end if;
    end process; 
end architecture_nbmm;
