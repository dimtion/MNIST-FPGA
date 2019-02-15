library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity testbench_createword is
end testbench_createword;

architecture Testbench_createword of testbench_createword is
  component CreateWord
    port (
      I_clk       : in std_logic;
      I_rst       : in std_logic;
      I_pixel 	: in std_logic_vector(7 downto 0);
      I_en_load 	: in std_logic;
      I_en_C_P	: in std_logic;
      I_en_C_W 	: in std_logic;
      O_I_0		: out std_logic_vector(223 downto 0);
      O_en_I_0 	: out std_logic
    );
  end component;
  signal SR_clock : std_logic := '0';
  signal SR_reset : std_logic;
  signal SR_pixel : std_logic_vector(7 downto 0);
  signal SR_en_load : std_logic;
  signal SR_en_C_P : std_logic;
  signal SR_en_C_W :std_logic;
  signal SC_I_0 :  std_logic_vector(223 downto 0);
  signal SC_en_I_0 : std_logic;
  begin
    createword_instance : CreateWord
    port map (
      I_clk => SR_clock,
      I_rst => SR_reset,
      I_pixel => SR_pixel,
      I_en_load => SR_en_load,
      I_en_C_P => SR_en_C_P,
      I_en_C_W => SR_en_C_W,
      O_I_0 => SC_I_0,
      O_en_I_0 => SC_en_I_0
      );
      
    SR_clock <= not SR_clock after 10 ns;
    SR_reset <= '1' , '0' after 29 ns;
    SR_pixel <= "01000000", "00000001" after 41 ns, "00001000" after 52 ns;
    SR_en_load <= '0', '1' after 45 ns;
    SR_en_C_P <= '0', '1' after 45 ns;
    SR_en_C_W <= '0', '1' after 45 ns;
end Testbench_createword;
