library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity Acc is 
	generic (
		size : Natural
	);
	port (
		I_clk 	: in std_logic;
		I_rst 	: in std_logic;
		I_load 	: in std_logic;
		I_d : in std_logic_vector(size-1 downto 0);
		O_d	: out std_logic_vector(size-1 downto 0)
		);
end Acc;

architecture Behavioral of Acc is 
`

signal tmp_value : unsigned(size-1 downto 0);

begin 

process(I_clk,I_rst) 

begin 
	If I_rst = '1' then
		tmp_value <= (others => '0');
	else 
		if I_load = '0' then 
			tmp_value <= tmp_value + unsigned(I_d);
		else 
			tmp_value <= unsigned(I_d);
		end if;
	end if;

end process;

O_d <= std_logic_vector(tmp_value);

end Behavioral;
