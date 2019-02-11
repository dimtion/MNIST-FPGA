library IEEE
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CreateWord is 
	generic (
		address_size : natural 
	);
	port (
		I_pixel 	: in std_logic_vector(7 downto 0);
		I_en_load 	: in std_logic;
		I_en_C_P	: in std_logic;
		I_en_C_W 	: in std_logic;
		O_addr_I_0	: out std_logic_vector(address_size -1 downto 0);
		O_I_0		: out std_logic_vector(223 downto 0);
		O_en_I_0 	: out std_logic
	);
end CreateWord;

architecture Behavioral of CreateWord is 

component RegWen is 
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

component Counter is 
	Generic(
		val_max : natural;
		nb_bits : natural
		);
	Port(
		I_clk 	: in std_logic;
		I_en 	: in std_logic;
		I_rst 	: in std_logic;
		O_value : out std_logic_vector(nb_bits-1 downto 0)
	);
		
-- signals 

signal temp_I_I		: unsigned(223 downto 0);
signal temp_O_I		: unsigned(223 downto 0);
signal value_W_28 	: unsigned(5 downto 0);
signal value_P_28 	: unsigned(5 downto 0);

begin 

	Counter_W_28 : Counter
		generic map (
			val_max => 28,
			nb_bits => 6
		);
		port map (
			I_clk 	=> I_clk,
			I_en 	=> I_en_C_W,
			I_rst 	=> I_rst,
			O_value => std_logic_vector(value_W_28)
	);

	Counter_C_P_28 : Counter 
		generic map (
			val_max => 28,
			nb_bits => 6
		);
		port map (
			I_clk 	=> I_clk,
			I_en 	=> I_en_C_P when(to_integer(value_W_8) = 27) else '0',
			I_rst	=> I_rst,
			O_value	=> std_logic_vector(value_P_28)
		);

	Reg_I : RegWEn 
		generic map (
			size => 224
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> I_en_load,
			I_data 	=> std_logic_vector(temp_I),
			O_value => std_logic_vector(temp_I)
		);

temp_I( 223 - (to_integer(value_W_8) * 8 ) downto to_integer 216 -(to_integer(value_W_8)*8)) <= I_pixel;
O_I_O <= O_value;
O_en_I_O <= '1' when (to_integer(value_W_8) = 27) else '0';
O_addr_I_O <= std_logic_vector(to_unsigned(to_integer(value_P_28)*(28*8),address_size));

end Behavioral;

