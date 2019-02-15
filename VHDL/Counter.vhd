library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;


entity Counter is 
	Generic(
			val_max : NATURAL := 10;
			nb_bits : NATURAL := 4
			);
	Port(
		I_clk : in STD_LOGIC;
		I_en 	: in STD_LOGIC;
		I_rst : in STD_LOGIC;
		O_value : out STD_LOGIC_VECTOR(nb_bits - 1 downto 0 )
		);
end Counter;

architecture Behavioral of Counter is

signal temp_value : unsigned(nb_bits-1 downto 0);

begin 

process(I_clk,I_rst)

begin
	if I_rst = '0' then	
		temp_value <= (others => '0'); 
	else 
		if (rising_edge(I_clk)) then 
			if I_en = '1' then
				if temp_value >= val_max then
					temp_value <= (others => '0');
				else 
					temp_value <= temp_value + 1;		
			    end if;
            end if;
		end if;
	end if;
end process;

O_value <= std_logic_vector(temp_value); 


end Behavioral; 
