library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
entity testbench_argmax is
end testbench_argmax;

architecture Testbench_argmax of testbench_argmax is
  component Argmax
	port(
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
		I_P10 : in std_logic_vector(7 downto 0);
		I_en 	: in std_logic;
		O_I 	 : out std_logic_vector(3 downto 0);
		O_done : out std_logic
		);
	end component;
	 signal SR_clock : std_logic := '0';
	 signal SR_reset : std_logic;
	 signal SR_enable : std_logic;
	 signal SC_I : std_logic_vector(3 downto 0);
	 signal SC_done : std_logic;
	 
	 signal SR_P1 : std_logic_vector(7 downto 0);
   signal SR_P2 : std_logic_vector(7 downto 0);
   signal SR_P3 : std_logic_vector(7 downto 0);
   signal SR_P4 : std_logic_vector(7 downto 0);
   signal SR_P5 : std_logic_vector(7 downto 0);
   signal SR_P6 	: std_logic_vector(7 downto 0);
   signal SR_P7 	: std_logic_vector(7 downto 0);
   signal SR_P8 	: std_logic_vector(7 downto 0);
   signal SR_P9 	: std_logic_vector(7 downto 0);
   signal SR_P10 : std_logic_vector(7 downto 0);
	 
	begin
	  SR_clock <= not SR_clock after 7 ns;
	  SR_reset <= '0' , '1' after 39 ns;
	  SR_enable <= '0',  '1' after 50 ns;
	  
	  argmax_instance : Argmax
	     port map (
	       I_clk => SR_clock,
	       I_rst => SR_reset,
	       I_P1 => SR_P1,
	       I_P2 => SR_P2,
	       I_P3 => SR_P3,
	       I_P4 => SR_P4,
	       I_P5 => SR_P5,
	       I_P6 => SR_P6,
	       I_P7 => SR_P7,
	       I_P8 => SR_P8,
	       I_P9 => SR_P9,
	       I_P10 => SR_P10,
	       I_en => SR_enable,
	       O_I => SC_I,
	       O_done => SC_done
	      );
	      
	 SR_P1 <= std_logic_vector(to_unsigned(2, 8));
	 SR_P2 <= std_logic_vector(to_unsigned(2, 8));
	 SR_P3 <= std_logic_vector(to_unsigned(5, 8));
	 SR_P4 <= std_logic_vector(to_unsigned(2, 8));
	 SR_P5 <= std_logic_vector(to_unsigned(1, 8));
	 SR_P6 <= std_logic_vector(to_unsigned(7, 8));
	 SR_P7 <= std_logic_vector(to_unsigned(2, 8));
	 SR_P8 <= std_logic_vector(to_unsigned(2, 8));
	 SR_P9 <= std_logic_vector(to_unsigned(2, 8));
	 SR_P10 <= std_logic_vector(to_unsigned(6, 8));
end Testbench_argmax;