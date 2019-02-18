library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SubNeurone_l2 is 
	port (
		I_clk	: in std_logic;
		I_rst 	: in std_logic;
		I_data  : in std_logic_vector(20*8-1 downto 0);
		I_W 	: in std_logic_vector(20*5 -1 downto 0);
		I_C 	: in std_logic_vector(1 downto 0);
		I_biais	: in std_logic_vector(4 downto 0);
        O_d     : out std_logic_vector(7 downto 0)
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
		    O_d 	: out std_logic_vector(size-1 downto 0)
        );
    end component;

signal out_acc 	: signed(16 downto 0);

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
signal add_b : signed(16 downto 0);
signal add_r : signed(16 downto 0);
signal en_Acc : std_logic;
signal l_add_5 : std_logic_vector(16 downto 0);
signal l_out_acc : std_logic_vector(16 downto 0);

begin 

	Acc_1 : Acc 
		generic map (
			size => 17
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_load 	=> en_Acc, 
			I_d		=> l_add_5,
			O_d 	=> l_out_acc
		);

-- multiplicateur
process(I_data,I_W)

begin
    mult_loop : for Index_m in 0 to 19 loop
	    mult(Index_m) <= signed('0' & I_data(159 - Index_m*8 downto 152 - Index_m*8)) * signed(I_W(99 - Index_m*5 downto 95-Index_m*5));
    end loop mult_loop;
end process;

process(mult)
begin
-- additionneurs premier etage
    add_1_loop : for Index_a1 in 0 to 9 loop
	    add_1(Index_a1) <= resize(mult(Index_a1*2),15) + resize(mult(Index_a1*2+1),15);
    end loop add_1_loop;
end process;

process(add_1)
begin
-- additionneur 2eme etage
    add_2_loop : for Index_a2 in 0 to 4 loop
	    add_2(Index_a2) <= resize(add_1(Index_a2*2),16) + resize(add_1(Index_a2*2+1),16);
    end loop add_2_loop;
end process;

process(add_2)
begin
--additionneur 3eme etage
    add_3(0) <= resize(add_2(0),17) + resize(add_2(1),17);
    add_3(1) <= resize(add_2(2),17) + resize(add_2(3),17);
    add_3(2) <= resize(add_2(4),17);
end process;

process(add_3)
begin
-- addtionneur 4eme etage 
    add_4(0) <= resize(add_3(0),17) + resize(add_3(1),17);
    add_4(1) <= resize(add_3(2),17);
end process;

process(add_4)
begin
--additionneur 5eme etage 
    add_5 <= add_4(0) + add_4(1);
end process;
process(add_5)
begin
	l_add_5 <= std_logic_vector(add_5);

end process;

-- biais
process(out_acc, I_biais)
begin
	add_b <= out_acc + SHIFT_LEFT(resize(signed(I_biais),17),8);
end process;

-- resize 
process(add_b) 
begin
	if (add_b(16)='0') then 
		add_r <= add_b;
	else 
		add_r <= (others => '0'); 
	end if;
end process;

process(l_out_acc)
begin
	out_acc <= signed(l_out_acc);
end process;
-- Out with Relu
process (add_r)
begin
	O_d <=  std_logic_vector(add_r(11 downto 4));
end process;

en_Acc <= '1' when(to_integer(Unsigned(I_C)) = 0) else '0';

end Behavioral;
