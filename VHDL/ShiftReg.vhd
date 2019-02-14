library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity ShiftReg_0 is 
    generic (
        nb_reg : natural;
        size_w : natural
    );
    port (
        I_clk : in std_logic;
        I_rst : in std_logic;
        I_en : in std_logic;
        I_data : in std_logic_vector(size_w -1 downto 0);
        O_data : out std_logic_vector(nb_reg*size_w-1 downto 0)
    );
end ShiftReg_0;

architecture Behavioral of ShiftReg_0 is 

    component RegWEn 
        generic (
            size : natural
        );
        port (
            I_clk   : in std_logic;
            I_rst   : in std_logic;
            I_en    : in std_logic;
            I_data  : in std_logic_vector(size-1 downto 0);
            O_value  : out std_logic_vector(size-1 downto 0)
        );
    end component;

type Reg_S is array(0 to nb_reg-1) of std_logic_vector(size_w-1 downto 0);
signal Reg_I : Reg_S;
signal Reg_O : Reg_S;

type En_S is array(0 to nb_reg -1) of std_logic;
signal En_signal : En_S;

begin 

    R1 : FOR index in 0 to nb_reg-1 GENERATE 
        reg_shifted:RegWEn
            generic map(
                size => 8
            )
            port map( 
                I_clk => I_clk,
                I_rst => I_rst,
                I_en  => I_en,
                I_data => Reg_I(index),
                O_value => Reg_O(index)
            );
    end GENERATE R1;
    
process(I_en,I_data,I_clk)

begin 
    ShiftLoop : for indexShiftLoop in 0 to nb_reg-2 loop
   --     En_signal(indexShiftLoop) <= '1';
        Reg_I(indexShiftLoop) <= Reg_O(indexShiftLoop+1);
    end loop ShiftLoop;
        
    --En_signal(0)    <= I_en;
    Reg_I(nb_reg-1)        <= I_data;

    Out_loop : for index_o_loop in 0 to nb_reg-1 loop
        O_data((nb_reg*size_w-1 -index_o_loop*size_w) downto ((nb_reg-1)*size_w-index_o_loop*size_w)) <= Reg_O(index_o_loop);
    end loop Out_loop;

end process;

end Behavioral;
