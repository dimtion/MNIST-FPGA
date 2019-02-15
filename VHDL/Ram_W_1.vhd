library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.all;
use work.utils_pkg.all;

entity Ram_W_1 is 
    generic (
        size_w      : natural;
        addr_size   : natural
        );
    port(
        I_clk : in std_logic;
        I_rst : in std_logic;
        addr_r : in std_logic_vector(addr_size -1 downto 0);
        data_r : out std_logic_vector(size_w-1 downto 0)
    );
end Ram_W_1;

architecture Behavioral of Ram_W_1 is 

    component generic_LUT_unit 
        generic(
            G_FILEPATH      : string;
            G_DEPTH_LUT     : natural;
            G_NBIT_LUT      : natural;
            G_STYLE         : string;
            G_PIPELINE_REG  : boolean
        );
        Port(
            I_clk           : in std_logic;
            I_sel_sample    : in std_logic_vector( log2(G_DEPTH_LUT) - 1 downto 0);
            O_LUT_value     : out std_logic_vector( G_NBIT_LUT-1 downto 0)
        );
    end component;

type O_L_all is array(0 to 27) of std_logic_vector(4 downto 0);
signal O_L_1 : O_L_all;

begin 

    L1 : FOR index in 0 to 27 GENERATE 
        lut:generic_LUT_unit 
            generic map(
                G_FILEPATH      => "../PythonCode/weights/models/40_20_10_quant-97.23.torch/l1_" & integer'image(index) & ".lut",
                G_DEPTH_LUT     => 40*28,
                G_NBIT_LUT      => 5,
                G_STYLE         => "distributed",
                G_PIPELINE_REG  => false
            )
            port map(
                I_clk           => I_clk,
                I_sel_sample    => addr_r,
                O_LUT_value     => O_L_1(index)
            );

    end GENERATE L1;

process(addr_r)
begin 
		word_loop : for indexW in 0 to 27 loop 
        	data_r((size_w-1-indexW*5) downto (size_w-5-indexW*5)) <= O_L_1(indexW);
    	end loop word_loop;
end  process;
end Behavioral;
