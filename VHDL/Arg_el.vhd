library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Arg_el is 
	port (
		I_clk 	: in std_logic;
		I_rst 	: in std_logic;
		I_en 	: in std_logic;
		I_P1 	: in std_logic_vector(7 downto 0);
		I_P2	: in std_logic_vector(7 downto 0);
		I_I1 	: in std_logic_vector(3 downto 0);
		I_I2	: in std_logic_vector(3 downto 0);
		O_I		: out std_logic_vector(3 downto 0);
		O_P		: out std_logic_vector(7 downto 0);
		O_done 	: out std_logic
	);
end Arg_el;

architecture Behavioral of Arg_el is 

	component RegWen is
		Generic(
			size : natural
		);
		Port(
			I_clk 	: in std_logic;
			I_rst 	: in std_logic;
			I_en 	: in std_logic;
			I_data 	: in std_logic_vector(size-1 downto 0);
			O_value : out std_logic_vector(size-1 downto 0)
		);
	end component;

signal max_P : unsigned(7 downto 0);
signal max_I : unsigned(3 downto 0);

begin

	Reg_P : RegWen 
		generic map(
			size => 8
		)
		port map(
			I_clk => I_clk,
			I_rst => I_rst,
			I_en => I_en,
			I_data => std_logic_vector(max_P),
			O_value => O_P
		);
	
	Reg_I : RegWen
		generic map(
			size => 4
		)
		port map(
			I_clk => I_clk,
			I_rst => I_rst,
			I_en => I_en,
			I_data => std_logic_vector(max_I),
			O_value => O_I
		);

process

begin
    if (Unsigned(I_P1) - Unsigned(I_P2) > 0) then
	    max_P <= Unsigned(I_P1);
	    max_I <= Unsigned(I_I1);
    else 
	    max_P <= Unsigned(I_P2);
	    max_I <= unsigned(I_I2);
    end if;
end process;

process(I_clk, I_rst) 

begin
	If (I_rst = '1') then
		O_done <= '0';
	else
		if (rising_edge(I_clk)) then
			if (I_en = '1') then
				O_done <= '1';
			end if;
		end if;		
	end if;

end process;

end Behavioral;
