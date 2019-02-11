library IEEE
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegWEn is 
	generic (
		size : natural 
	);
	port (
		I_clk 	: in std_logic; 
		I_rst 	: in std_logic;
		I_en 	: in std_logic;
		I_data 	: in std_logic_vector(size-1 downto 0);
		O_value : out std_logic_vector(size-1 downto 0)
	);

architecture Behavioral of RegWen is 

begin 

process(I_clk,I_rst) 
	if I_rst = '1' then 
		O_value <= (others => '0');
	else 
		if rising_edge(clk) then
			if I_en = '1' then 
				O_value <= I_data;
			end if;
		end if;
	end if;
end process;

end Behavioral;
