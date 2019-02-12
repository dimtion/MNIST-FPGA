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
		O_en_I_0 	: out std_logic;
        	O_pixelCount : out std_logic_vector(4 downto 0)
    );
end CreateWord;

architecture Behavioral of CreateWord is 

    component ShiftReg_0 is 
	    generic (
	        nb_reg : natural;
            size_w : natural
        );
	    port (
		    I_clk 	: in std_logic;
		    I_rst 	: in std_logic;
		    I_en 	: in std_logic;
		    I_data 	: in std_logic_vector(size_w-1 downto 0);
		    O_data  : out std_logic_vector(nb_reg*size_w-1 downto 0)
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

signal value_W_28 	: unsigned(4 downto 0);
signal value_P_28 	: unsigned(4 downto 0);
signal l_value_W_28 : std_logic_vector(4 downto 0);
signal l_value_P_28 : std_logic_vector(4 downto 0);
signal I_P_28       : std_logic;

begin

	Counter_W_28 : Counter
		generic map (
			val_max => 29,
			nb_bits => 5
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
			nb_bits => 5
		)
		port map (
			I_clk 	=> I_clk,
			I_en 	=> I_P_28,
			I_rst	=> I_rst,
			O_value	=> l_value_P_28
		);

	Reg_I : ShiftReg_0
		generic map (
			nb_reg => 28,
            		size_w => 8
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_en 	=> I_en_load,
			I_data 	=> I_pixel,
			O_data => O_I_0
		);

value_W_28 <= Unsigned(l_value_W_28);
value_P_28 <= Unsigned(l_value_P_28);
O_pixelCount <= std_logic_vector(value_P_28);

process(value_W_28, value_P_28) 

begin 

    if ( to_integer(value_W_28) = 28) then
        O_en_I_0 <= '1';
    else 
        O_en_I_0 <= '0';
    end if;

    if (to_integer(value_W_28) = 29) then
        I_P_28 <= '1';    
    else 
        I_P_28 <= '0';
    end if;
end process;

end Behavioral;

