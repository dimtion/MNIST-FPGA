library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity NeuronCombinator is
	generic (
		nb_neurons : natural;
		size_w : natural
	);
	port (
		I_clk : in std_logic;
		I_rst : in std_logic;
		I_en : in std_logic;
		I_data : in std_logic_vector(size_w-1 downto 0);
		I_ouputswitch : in std_logic;  -- tel if we return first or second half of ouput
		O_data : out std_logic_vector((nb_neurons*size_w)/2-1 downto 0)
  );
end NeuronCombinator;

architecture Behavioral  of NeuronCombinator is
	signal SR_reg : std_logic_vector(nb_neurons*size_w-1 downto 0);
	begin
  process(I_clk, I_rst, I_en)
		begin
		if (I_rst = '1') then
			SR_reg <= (others => '0');
		elsif (rising_edge(I_clk)) then
			if (I_en = '1') then
				SR_reg <= I_data & SR_reg(nb_neurons*size_w - 1 downto size_w);
			end if;
			if (I_ouputswitch  = '0') then
				O_data <= SR_reg(nb_neurons*size_w-1 downto nb_neurons*size_w/2);
			else
				O_data <= SR_reg(nb_neurons*size_w/2-1 downto 0);
			end if;
		end if;
	end process;
end Behavioral;
	
