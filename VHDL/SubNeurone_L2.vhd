library IEEE
use IEEE.ST_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SubNeurone_l2 is 
	port (
		I_clk	: in std_logic;
		I_rst 	: in std_logic;
		I_data  : in std_logic_vector(20*8-1 downto 0);
		I_W 	: in std_logic_vector(20*5 -1 downto 0);
		I_C 	: in std_logic_vector(6 downto 0);
		I_biais	: in std_logic_vector(4 downto 0);
	);
end SubNeurone_l2;


architecture Behavioral of SubNeurone_l2 is 

component Acc is
	generic (
		size : natural
		);
	port (
		I_clk 	: in std_logic;
		I_rst	: in std_logic;
		I_load	: in std_logic;
		I_d		: in std_logic_vector(size-1 downto 0);
		O_d 	: out std_logic_vector(size-1 downto 0);

end component;

signal out_acc 	: unsigned(12 downto 0);

type MULT is array(0 to 19) of unsigned(12 downto 0);
signal mult : MULT;

type ADD_1 is array(0 to 9) of unsigned(12 downto 0);
type ADD_2 is array(0 to 4) of unsigned(12 downto 0);
type ADD_3 is array(0 to 2) of unsigned(12 downto 0);
type ADD_4 is array(0 to 1) of unsigned(12 downto 0);


signal add_1 : ADD_1;
signal add_2 : ADD_2;
signal add_3 : ADD_3;
signal add_4 : ADD_4;
signal add_5 : unsigned(12 downto 0);
signal add_b : unsigned(12 downto 0);
signal add_r : unsigned(12 downto 0);

begin 

	Acc : Acc 
		generic map (
			size => 13
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_load 	=> '1' when (to_integer(Unsigned(I_C)) = 0) else '0',
			I_d		=> add_5,
			O_d 	=> out_acc,
		);

-- multiplicateur
for Index_m in 0 to 19 loop
	mult(Index_m) <= unsigned(I_data(159 - Index_m*8 downto 151 - Index_m*8)) * unsigned(I_W(99 - Index_m*5 downto 95-Index_m*5));
end loop;

-- additionneurs premier etage
for Index_a1 in 0 to 9 loop
	add_1(Index_a1) <= mutl(Index_a1*2) * mult(Index_a1*2+1);
end loop;

-- additionneur 2eme etage
for Index_a2 in 0 to 4 loop

	add_2(Index_a2) <= add_1(Index_a2*2) * add_2(Index_a2*2+1);
end loop;

--additionneur 3eme etage
add_3(0) <= add_2(0) * add_2(1);
add_3(1) <= add_2(2) * add_2(3);
add_3(2) <= add_2(4);

-- addtionneur 4eme etage 
add_4(0) <= add_3(0) * add_3(1);
add_4(1) <= add_3(2);

--additionneur 5eme etage 
add_5 <= add_4(0) + add_4(1);

-- biais 
add_b <= out_acc + Unsigned(I_b);

-- resize 
add_r <= resize(add_b,8);

-- Out with Relu
O_d <= add_r when(add_r(7) = '0') else '1';

end Behavioral;
