library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_L1 is 
	generic (
		N_size : NATURAL := 5;
		W_size : NATURAL := 5
	);
	port (
		I_clk 		: in std_logic;
		I_rst 		: in std_logic;
		I_N_1_en 	: in std_logic;
		I_W_1_en 	: in std_logic;
		I_N_clean 	: in std_logic;
		I_W_clean 	: in std_logic;
		O_N_1 		: out std_logic_vector(N_size -1 downto 0); 
		O_W_1		: out std_logic_vector(W_size -1 downto 0);
        	O_W_N       : out std_logic_vector(10 downto 0)
    );
end Counter_L1;

architecture Behavioral of Counter_L1 is 

	component Counter_Clean is
		Generic(
			val_max : natural;
			nb_bits : natural
		);
		port(
			I_clk 	: in std_logic;
			I_en 	: in std_logic;
			I_rst 	: in std_logic;
			I_clean : in std_logic;
			O_value : out std_logic_vector(nb_bits -1 downto 0)
		);
	end component;

signal value_counter_40 : unsigned(5 downto 0);
signal value_counter_28 : unsigned(4 downto 0);
signal u_en : std_logic;
signal l_value_counter_40 : std_logic_vector(5 downto 0);
signal l_value_counter_28 : std_logic_vector(4 downto 0);

begin

	Counter_40 : Counter_Clean
		generic map (
			val_max => 39,
			nb_bits => 6
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> u_en,
			I_clean => I_N_clean,
			O_value => l_value_counter_40
		);

	Counter_28 : Counter_Clean
		generic map (
			val_max => 28,
			nb_bits => 5
		)
		port map (
			I_clk	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> I_W_1_en,
			I_clean => I_W_clean,
			O_value => l_value_counter_28
		);

O_N_1 <= std_logic_vector(value_counter_40);
O_W_1 <= std_logic_vector(value_counter_28);
O_W_N <= std_logic_vector(resize(to_unsigned(to_integer(value_counter_28)+(to_integer(value_counter_40)*28),11 ),11)); 

u_en <= I_N_1_en when(to_integer(value_counter_28) = 28) else '0';
value_counter_40 <= unsigned(l_value_counter_40);
value_counter_28 <= unsigned(l_value_counter_28);

end Behavioral;
