library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SubNeurone_l1 is 
	port (
		I_clk	: in std_logic;
		I_rst 	: in std_logic;
		I_data  : in std_logic_vector(28*8-1 downto 0);
		I_W 	: in std_logic_vector(28*5 -1 downto 0);
		I_C 	: in std_logic_vector(4 downto 0);
		I_biais	: in std_logic_vector(4 downto 0);
        O_d     : out std_logic_vector(7 downto 0)
    );
end SubNeurone_l1;


architecture Behavioral of SubNeurone_l1 is 

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

type MULT_X is array(0 to 27) of unsigned(12 downto 0);
signal mult_d : MULT_X;

type ADDS_1 is array(0 to 13) of unsigned(12 downto 0);
type ADDS_2 is array(0 to 6) of unsigned(12 downto 0);
type ADDS_3 is array(0 to 3) of unsigned(12 downto 0);
type ADDS_4 is array(0 to 1) of unsigned(12 downto 0);

signal add_1 : ADDS_1;
signal add_2 : ADDS_2;
signal add_3 : ADDS_3;
signal add_4 : ADDS_4;
signal add_5 : unsigned(12 downto 0);
signal l_add_5 : std_logic_vector(12 downto 0);
signal l_out_acc : std_logic_vector(12 downto 0);

signal add_b : unsigned(12 downto 0);
signal add_r : unsigned(7 downto 0);

signal en_Acc : std_logic;

begin 

	Acc_1 : Acc 
		generic map (
			size => 13
		)
		port map (
			I_clk 	=> I_clk,
			I_rst 	=> I_rst,
			I_load 	=> en_Acc,
			I_d		=> l_add_5,
			O_d 	=> l_out_acc
		);

-- multiplicateur
process(I_data)

begin

    mult_loop : for Index_m in 0 to 27 loop
	    mult_d(Index_m) <= unsigned(I_data((223-Index_m*8) downto (216-Index_m*8))) * unsigned(I_W((139-Index_m*5) downto (135-Index_m*5)));
    end loop mult_loop;

-- additionneurs premier etage
    add_1_loop : for Index_a1 in 0 to 13 loop
	    add_1(Index_a1) <= mult_d(Index_a1*2) + mult_d(Index_a1*2+1);
    end loop add_1_loop;

-- additionneur 2eme etage
    add_2_loop : for Index_a2 in 0 to 6 loop
	    add_2(Index_a2) <= add_1(Index_a2*2) + add_1(Index_a2*2+1);
    end loop add_2_loop;


--additionneur 3eme etage
    add_3_loop : for index_a3 in 0 to 2 loop
	    add_3(index_a3) <= add_2(Index_a3*2) + add_2(Index_a3*2+1);
    end loop add_3_loop;
    add_3(3) <= add_2(6);

-- additionneur 4eme etage
    add_4(0) <= add_3(0) + add_3(1);
    add_4(1) <= add_3(2) + add_3(3);

-- addtionneur 5eme etage 
    add_5 <= add_4(0) + add_4(1);

end process;
-- biais 
add_b <= out_acc + Unsigned(I_biais);

-- resize 
add_r <= resize(add_b,8);

en_Acc <= '1' when(Unsigned(I_C) = 0) else '0';

O_d <= std_logic_vector(add_r) when(add_r(7)='0') else (others => '0');

l_add_5     <= std_logic_vector(add_5);
l_out_acc   <= std_logic_vector(out_acc);

end Behavioral;
