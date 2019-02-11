library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CreateWord is 
	port (
        I_clk       : in std_logic;
        I_rst       : in std_logic;
		I_pixel 	: in std_logic_vector(7 downto 0);
		I_en_load 	: in std_logic;
		I_en_C_P	: in std_logic;
		I_en_C_W 	: in std_logic;
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
    end component;

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
    end component;
		
-- signals 

signal temp_I		: std_logic_vector(223 downto 0);
signal value_W_28 	: unsigned(5 downto 0);
signal value_P_28 	: unsigned(5 downto 0);
signal l_value_W_28 : std_logic_vector(5 downto 0);
signal l_value_P_28 : std_logic_vector(5 downto 0);
signal I_P_28       : std_logic;

begin

	Counter_W_28 : Counter
		generic map (
			val_max => 28,
			nb_bits => 6
		)
		port map (
			I_clk 	=> I_clk,
			I_en 	=> I_en_C_W,
			I_rst 	=> I_rst,
			O_value => l_value_W_28
	    );

	Counter_C_P_28 : Counter 
		generic map (
			val_max => 28,
			nb_bits => 6
		)
		port map (
			I_clk 	=> I_clk,
			I_en 	=> I_P_28,
			I_rst	=> I_rst,
			O_value	=> l_value_P_28
		);

	Reg_I : RegWEn 
		generic map (
			size => 224
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> I_en_load,
			I_data 	=> temp_I,
			O_value => temp_I
		);
process(I_clk,I_pixel) 
    begin
        temp_I(223 - (to_integer(value_W_28) * 8 ) downto 216 - (to_integer(value_W_28)*8)) <= I_pixel;
end process;

O_I_0 <= temp_I;

O_en_I_0 <= '1' when (to_integer(value_W_28) = 27) else '0';
l_value_W_28 <= std_logic_vector(value_W_28);
l_value_P_28 <= std_logic_vector(value_P_28);


process(I_clk,value_W_28) 

begin 

    if (to_integer(value_W_28) = 27) then
        I_P_28 <= '1';    
    else 
        I_P_28 <= '0';
    end if;
end process;

end Behavioral;

