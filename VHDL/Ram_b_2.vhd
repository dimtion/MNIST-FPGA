library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.utils_pkg.all;

entity Ram_b_2 is 
    generic(
        size_w : natural;
        addr_size : natural
    );
    port(
        I_clk : in std_logic;
        I_rst : in std_logic;
        addr_r : in std_logic_vector(addr_size -1 downto 0);
        data_r : out std_logic_vector(size_w-1 downto 0)
    );
end Ram_b_2;


architecture Behavioral of Ram_b_2 is 
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

type O_L_all is array(0 to 19) of std_logic_vector(4 downto 0);
signal O_b : O_L_all;

begin 
    
       Lut_b_1 : generic_LUT_unit  
            generic map(
                G_FILEPATH      => "../PythonCode/weights/models/40_20_10_quant-97.23.torch/l2_bias.lut",
                G_DEPTH_LUT     => 20,
                G_NBIT_LUT      => 5,
                G_STYLE         => "distributed",
                G_PIPELINE_REG  => false
            )
            port map(
                I_clk           => I_clk,
                I_sel_sample    => addr_r,
                O_LUT_value     => data_r
            );

end Behavioral;
