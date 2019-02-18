library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity Argmax is 
	Port(
		I_clk 	: in std_logic;
		I_rst 	: in std_logic;
		I_P1 	: in std_logic_vector(7 downto 0);
		I_P2 	: in std_logic_vector(7 downto 0);
		I_P3 	: in std_logic_vector(7 downto 0);
		I_P4 	: in std_logic_vector(7 downto 0);
		I_P5 	: in std_logic_vector(7 downto 0);
		I_P6 	: in std_logic_vector(7 downto 0);
		I_P7 	: in std_logic_vector(7 downto 0);
		I_P8 	: in std_logic_vector(7 downto 0);
		I_P9 	: in std_logic_vector(7 downto 0);
		I_P10 	: in std_logic_vector(7 downto 0);
		I_en 	: in std_logic;
		O_I 	: out std_logic_vector(3 downto 0);
		O_done : out std_logic
		);
end Argmax;

architecture Behavioral of Argmax is 

	component Arg_el
		port(
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
    end component;

signal P_1_1 : std_logic_vector(7 downto 0);
signal P_1_2 : std_logic_vector(7 downto 0);
signal P_1_3 : std_logic_vector(7 downto 0);
signal P_1_4 : std_logic_vector(7 downto 0);
signal P_1_5 : std_logic_vector(7 downto 0);



signal I_1_1 : std_logic_vector(3 downto 0);
signal I_1_2 : std_logic_vector(3 downto 0);
signal I_1_3 : std_logic_vector(3 downto 0);
signal I_1_4 : std_logic_vector(3 downto 0);
signal I_1_5 : std_logic_vector(3 downto 0);

signal d_1_1 : std_logic;
signal d_1_2 : std_logic;
signal d_1_3 : std_logic;
signal d_1_4 : std_logic;
signal d_1_5 : std_logic;

signal P_2_1 : std_logic_vector(7 downto 0);
signal P_2_2 : std_logic_vector(7 downto 0);

signal I_2_1 : std_logic_vector(3 downto 0);
signal I_2_2 : std_logic_vector(3 downto 0);

signal d_2_1 : std_logic;
signal d_2_2 : std_logic;

signal en_2_1 : std_logic;
signal en_2_2 : std_logic;
signal en_3_1 : std_logic;
signal en_4_1 : std_logic;

signal P_3_1 : std_logic_vector(7 downto 0);
signal I_3_1 : std_logic_vector(3 downto 0);
signal d_3_1 : std_logic;

signal P_4_1 : std_logic_vector(7 downto 0);

begin 

-- first stage 
	Arg_el_1_1 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> I_en,
			I_P1 	=> I_P1,
			I_P2	=> I_P2,
			I_I1 	=> "0000",
			I_I2	=> "0001",
			O_I		=> I_1_1,
			O_P		=> P_1_1,
			O_done 	=> d_1_1
		);

	Arg_el_1_2 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> I_en,
			I_P1 	=> I_P3,
			I_P2	=> I_P4,
			I_I1 	=> "0010",
			I_I2	=> "0011",
			O_I		=> I_1_2, 
			O_P		=> P_1_2,
			O_done 	=> d_1_2
		);

	Arg_el_1_3 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> I_en,
			I_P1 	=> I_P5,
			I_P2	=> I_P6,
			I_I1 	=> "0100",
			I_I2	=> "0101",
			O_I		=> I_1_3, 
			O_P		=> P_1_3,
			O_done 	=> d_1_3
		);
	
	Arg_el_1_4 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> I_en,
			I_P1 	=> I_P7,
			I_P2	=> I_P8,
			I_I1 	=> "0110",
			I_I2	=> "0111",
			O_I		=> I_1_4, 
			O_P		=> P_1_4,
			O_done 	=> d_1_4
		);

	Arg_el_1_5 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> I_en,
			I_P1 	=> I_P9,
			I_P2	=> I_P10,
			I_I1 	=> "1000",
			I_I2	=> "1001",
			O_I		=> I_1_5, 
			O_P		=> P_1_5,
			O_done 	=> d_1_5
		);

-- second stage
	Arg_el_2_1 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> en_2_1,
			I_P1 	=> P_1_1,
			I_P2	=> P_1_2,
			I_I1 	=> I_1_1,
			I_I2	=> I_1_2,
			O_I		=> I_2_1, 
			O_P		=> P_2_1,
			O_done 	=> d_2_1
		);

	Arg_el_2_2 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> en_2_2,
			I_P1 	=> P_1_3,
			I_P2	=> P_1_4,
			I_I1 	=> I_1_3,
			I_I2	=> I_1_4,
			O_I		=> I_2_2, 
			O_P		=> P_2_2,
			O_done 	=> d_2_2
		);

-- third stage 
	Arg_el_3_1 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> en_3_1,
			I_P1 	=> P_1_5,
			I_P2	=> P_2_2,
			I_I1 	=> I_1_5,
			I_I2	=> I_2_2,
			O_I		=> I_3_1, 
			O_P		=> P_3_1,
			O_done 	=> d_3_1
		);

-- fourth stage
	Arg_el_4_1 : Arg_el 
		port map(
			I_clk 	=> I_clk, 
			I_rst 	=> I_rst,
			I_en 	=> en_4_1,
			I_P1 	=> P_2_1,
			I_P2	=> P_3_1,
			I_I1 	=> I_2_1,
			I_I2	=> I_3_1,
			O_I 	=> O_I,
			O_P		=> P_4_1,
			O_done 	=> O_done
		);


process(I_clk, d_2_1, d_3_1, d_2_2, d_1_4, d_1_2, d_1_1, d_1_5, d_1_3)
    begin 
        if (d_2_1 = '1' and d_3_1 = '1') then 
                en_4_1 <= '1';
        else
                en_4_1 <= '0';
        end if;

        if (d_1_5 ='1' and d_2_2 = '1') then 
            en_3_1 <= '1';
        else 
            en_3_1 <= '0';
        end if;
       
        if (d_1_3 = '1' and d_1_4 = '1') then 
            en_2_2 <= '1';
        else 
            en_2_2 <= '0';
        end if;
        
        if (d_1_1 = '1' and d_1_2 = '1') then
            en_2_1 <= '1';
        else 
            en_2_2 <= '0';
        end if;
end process;

end Behavioral;
