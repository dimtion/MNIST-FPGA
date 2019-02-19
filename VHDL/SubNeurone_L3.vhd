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

	Component RegWEn is 
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

signal out_acc 	: signed(16 downto 0);
signal l_out_acc : std_logic_vector(16 downto 0);
type MULT_X is array(0 to 19) of signed(13 downto 0);
signal mult : MULT_X;

type ADDS_1 is array(0 to 9) of signed(14 downto 0);
type ADDS_2 is array(0 to 4) of signed(15 downto 0);
type ADDS_3 is array(0 to 2) of signed(16 downto 0);
type ADDS_4 is array(0 to 1) of signed(16 downto 0);

signal add_1 : ADDS_1;
signal add_2 : ADDS_2;
signal add_3 : ADDS_3;
signal add_4 : ADDS_4;
signal add_5 : signed(16 downto 0);
signal l_add_5 : std_logic_vector(16 downto 0);

signal en_Acc : std_logic;

signal add_b : signed(16 downto 0);

type MULT_X_V is array(0 to 19) of std_logic_vector(13 downto 0);
type ADDS_1_V is array(0 to 9) of std_logic_vector(14 downto 0);
type ADDS_2_V is array(0 to 4) of std_logic_vector(15 downto 0);
type ADDS_3_V is array(0 to 2) of std_logic_vector(16 downto 0);
type ADDS_4_V is array(0 to 1) of std_logic_vector(16 downto 0);

signal mult_d_r : MULT_X_V;
signal add_1_r : ADDS_1_V;
signal add_2_r : ADDS_2_V;
signal add_3_r : ADDS_3_V;
signal add_4_r : ADDS_4_V;

begin 

A4 : FOR index_A4 in 0 to 1 GENERATE
	reg_a4:RegWen
		generic map (
			size => 17
		)
		port map (
			I_clk => I_clk,	
			I_rst => I_rst,
			I_en  => '1',	
			I_data => std_logic_vector(add_4(index_A4)),	
			O_value => add_4_r(index_A4)
		);
end GENERATE A4;

A3 : FOR index_A3 in 0 to 2 GENERATE
	reg_a3:RegWen
		generic map (
			size => 17
		)
		port map (
			I_clk => I_clk,	
			I_rst => I_rst,
			I_en  => '1',	
			I_data => std_logic_vector(add_3(index_A3)),	
			O_value => add_3_r(index_A3)
		);
end GENERATE A3;

A2 : FOR index_A2 in 0 to 4 GENERATE
	reg_a2:RegWen
		generic map (
			size => 16
		)
		port map (
			I_clk => I_clk,	
			I_rst => I_rst,
			I_en  => '1',	
			I_data => std_logic_vector(add_2(index_A2)),	
			O_value => add_2_r(index_A2)
		);
end GENERATE A2;

A1 : FOR index_A1 in 0 to 9 GENERATE
	reg_a1:RegWen
		generic map (
			size => 15
		)
		port map (
			I_clk => I_clk,	
			I_rst => I_rst,
			I_en  => '1',	
			I_data => std_logic_vector(add_1(index_A1)),	
			O_value => add_1_r(index_A1)
		);
end GENERATE A1;

M1 : FOR index_M1 in 0 to 19 GENERATE 
	reg_m :RegWEn
		generic map(
			size => 14
		)
		port map(
			I_clk => I_clk,	
			I_rst => I_rst,
			I_en  => '1',	
			I_data => std_logic_vector(mult(index_M1)),	
			O_value => mult_d_r(index_M1)
		);
end GENERATE M1;

	Acc_1 : Acc 
		generic map (
			size => 17
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_load 	=> '1', 
			I_d	=> l_add_5,
			O_d 	=> l_out_acc
		);

process(I_W,I_data)
begin
-- multiplicateur
    mult_loop : for Index_m in 0 to 19 loop
	    mult(Index_m) <= signed('0' & I_data(159 - Index_m*8 downto 152 - Index_m*8)) * signed(I_W(99 - Index_m*5 downto 95-Index_m*5));
    end loop mult_loop;
end process;

process(mult)
begin
-- additionneurs premier etage
    add_1_loop : for Index_a1 in 0 to 9 loop
	    add_1(Index_a1) <= resize(signed(mult_d_r(Index_a1*2)),15) + resize(signed(mult_d_r(Index_a1*2+1)),15);
    end loop add_1_loop;
end process;

process(add_1)
begin
-- additionneur 2eme etage
    add_2_loop : for Index_a2 in 0 to 4 loop
	    add_2(Index_a2) <= resize(signed(add_1_r(Index_a2*2)),16) + resize(signed(add_1_r(Index_a2*2+1)),16);
    end loop add_2_loop;
end process;

process(add_2)
begin
--additionneur 3eme etage
    add_3(0) <= resize(signed(add_2_r(0)),17) + resize(signed(add_2_r(1)),17);
    add_3(1) <= resize(signed(add_2_r(2)),17) + resize(signed(add_2_r(3)),17);
    add_3(2) <= resize(signed(add_2_r(4)),17);
end process;

process(add_3)
begin
-- addtionneur 4eme etage 
    add_4(0) <= resize(signed(add_3_r(0)),17) + resize(signed(add_3_r(1)),17);
    add_4(1) <= resize(signed(add_3_r(2)),17);
end process;

process(add_4)
begin
    add_5 <= signed(add_4_r(0)) + signed(add_4_r(1));
end process;

-- biais 
process(I_biais,out_acc)
begin
	add_b <= out_acc + resize(signed(I_biais),17);
end process;
-- resize 

process (add_b)
begin
	O_d <= std_logic_vector(add_b(16) & add_b(13 downto 7));
end process;

process(l_out_acc)
begin
	out_acc <= signed(l_out_acc);
end process;


-- Out with Relu

process(add_5)
begin
	l_add_5     <= std_logic_vector(add_5);
end process;

end Behavioral;


