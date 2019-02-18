library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_L2 is
	generic (
		N_size : NATURAL := 5;
		W_size : NATURAL := 5
	);
	port (
		I_clk 		: in std_logic;
		I_rst 		: in std_logic;
		I_N_2_en 	: in std_logic;
		I_W_2_en 	: in std_logic;
		I_clean_W	: in std_logic;
		I_clean_N	: in std_logic;
		O_N_2 		: out std_logic_vector(N_size -1 downto 0); 
		O_W_2		: out std_logic_vector(W_size -1 downto 0);
		O_W_N 		: out std_logic_vector(5 downto 0)
	);
end Counter_L2;

architecture Behavioral of Counter_L2 is 

	component Counter_Clean is
		Generic(
			val_max : natural;
			nb_bits : natural
		);
		port(
			I_clk 	: in std_logic;
			I_en 	: in std_logic;
			I_rst 	: in std_logic;
			I_clean	: in std_logic;
			O_value : out std_logic_vector(nb_bits -1 downto 0)
		);
	end component;

signal value_counter_20 : unsigned(4 downto 0);
signal value_counter_2 : unsigned(1 downto 0);

signal l_value_counter_20 : std_logic_vector(4 downto 0);
signal l_value_counter_2 : std_logic_vector(1 downto 0);

signal I_en_20 : std_logic;

begin

	Counter_20 : Counter_Clean 
		generic map (
			val_max => 19,
			nb_bits => 5
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> I_en_20,
			I_clean => I_clean_N, 
			O_value => l_value_counter_20
		);

	Counter_2 : Counter_Clean
		generic map (
			val_max => 2,
			nb_bits => 2
		)
		port map (
			I_clk	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> I_W_2_en,
			I_clean => I_clean_W,
			O_value => l_value_counter_2
		);

O_N_2 <= std_logic_vector(l_value_counter_20);
O_W_2 <= std_logic_vector(l_value_counter_2);
O_W_N <= std_logic_vector(resize(to_unsigned(to_integer(value_counter_20)*2+(to_integer(value_counter_2)),6 ),6)); 

value_counter_20 <= unsigned(l_value_counter_20);
value_counter_2 <= unsigned(l_value_counter_2);
I_en_20 <= I_N_2_en when(to_integer(value_counter_2) = 2) else '0';

end Behavioral;
