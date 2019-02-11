library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_L3 is 
	port (
		I_clk		: in std_logic;
		I_rst		: in std_logic;
		I_N_3_en 	: in std_logic;
        O_N_3       : out std_logic_vector(3 downto 0)
    );
end Counter_L3;

architecture Behavioral of Counter_L3 is 

	component Counter is 
		Generic (
			val_max : natural;
			nb_bits : natural
		);
		port (
			I_clk	: in std_logic;
			I_en	: in std_logic;
			I_rst 	: in std_logic;
			O_value : out std_logic_vector(nb_bits-1 downto 0)
		);
	end component;

signal value_counter_10 : unsigned(3 downto 0);
signal l_value_counter_10 : std_logic_vector(3 downto 0);

begin 
	Counter_10 : Counter 
		generic map (
			val_max => 1,
			nb_bits => 3
		)
		port map (
			I_clk => I_clk,
			I_rst => I_rst,
			I_en => I_N_3_en,
			O_value => l_value_counter_10
		);

O_N_3 <= std_logic_vector(value_counter_10);
l_value_counter_10 <= std_logic_vector(value_counter_10);

end Behavioral;
