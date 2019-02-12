library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SubNeurone_l3 is 
	port (
		I_clk	: in std_logic;
		I_rst 	: in std_logic;
		I_data  : in std_logic_vector(20*8-1 downto 0);
		I_W 	: in std_logic_vector(20*5 -1 downto 0);
		I_biais	: in std_logic_vector(4 downto 0);
	    O_d     : out std_logic_vector(7 downto 0)
    );
end SubNeurone_l3;


architecture Behavioral of SubNeurone_l3 is 

component Acc is
	generic (
		size : natural
		);
	port (
		I_clk 	: in std_logic;
		I_rst	: in std_logic;
		I_load	: in std_logic;
		I_d		: in std_logic_vector(size-1 downto 0);
		O_d 	: out std_logic_vector(size-1 downto 0)
        );
end component;

signal out_acc 	: unsigned(12 downto 0);
signal l_out_acc : std_logic_vector(12 downto 0);
type MULT_X is array(0 to 19) of unsigned(12 downto 0);
signal mult : MULT_X;

type ADDS_1 is array(0 to 9) of unsigned(12 downto 0);
type ADDS_2 is array(0 to 4) of unsigned(12 downto 0);
type ADDS_3 is array(0 to 2) of unsigned(12 downto 0);
type ADDS_4 is array(0 to 1) of unsigned(12 downto 0);

signal add_1 : ADDS_1;
signal add_2 : ADDS_2;
signal add_3 : ADDS_3;
signal add_4 : ADDS_4;
signal add_5 : unsigned(12 downto 0);
signal l_add_5 : std_logic_vector(12 downto 0);

signal en_Acc : std_logic;

signal add_b : unsigned(12 downto 0);
signal add_r : unsigned(7 downto 0);

begin 

	Acc_1 : Acc 
		generic map (
			size => 13
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_load 	=> '0', 
			I_d	=> l_add_5,
			O_d 	=> l_out_acc
		);

process(I_data)
begin
-- multiplicateur
    mult_loop : for Index_m in 0 to 19 loop
	    mult(Index_m) <= unsigned(I_data(159 - Index_m*8 downto 152 - Index_m*8)) * unsigned(I_W(99 - Index_m*5 downto 95-Index_m*5));
    end loop mult_loop;

-- additionneurs premier etage
    add_1_loop : for Index_a1 in 0 to 9 loop
	    add_1(Index_a1) <= mult(Index_a1*2) + mult(Index_a1*2+1);
    end loop add_1_loop;

-- additionneur 2eme etage
    add_2_loop : for Index_a2 in 0 to 4 loop
	    add_2(Index_a2) <= add_1(Index_a2*2) + add_1(Index_a2*2+1);
    end loop add_2_loop;

--additionneur 3eme etage
    add_3(0) <= add_2(0) + add_2(1);
    add_3(1) <= add_2(2) + add_2(3);
    add_3(2) <= add_2(4);

-- addtionneur 4eme etage 
    add_4(0) <= add_3(0) + add_3(1);
    add_4(1) <= add_3(2);

    add_5 <= add_4(0) + add_4(1);

end process;
-- biais 
add_b <= out_acc + Unsigned(I_biais);

-- resize 
add_r <= resize(add_b,8);

out_acc <= unsigned(l_out_acc);

-- Out with Relu
O_d <= std_logic_vector(add_r) when (add_r(7)='0') else (others => '0');
end Behavioral;
