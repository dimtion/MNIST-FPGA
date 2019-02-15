library ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
entity testbench_fsm is
end testbench_fsm;

architecture tb_fsm of testbench_fsm is
    component FSM
    port (
        i_clk	: in std_logic;
        i_rst	: in std_logic;
        i_ack 	: in std_logic;
        i_w_0	: in std_logic_vector(5 downto 0); 
        i_p_0	: in std_logic_vector(5 downto 0);
        i_n_1 	: in std_logic_vector(6 downto 0);
        i_w_1 	: in std_logic_vector(5 downto 0);
        i_n_2	: in std_logic_vector(5 downto 0);
        i_w_2 	: in std_logic_vector(1 downto 0);
        i_n_3 	: in std_logic_vector(4 downto 0);
        i_arg	: in std_logic;
        o_request 		: out std_logic;
        o_en_load 		: out std_logic;
        o_en_c_w		: out std_logic;
        o_en_c_p		: out std_logic;
        o_w_1_en		: out std_logic;
        o_n_1_en 		: out std_logic;
        o_w_2_en 		: out std_logic;
        o_n_2_en 		: out std_logic;
        o_n_3_en		: out std_logic;
        o_classifvalid 	: out std_logic;
        o_arg 			: out std_logic
    );
    end component;
    signal SR_clock     : std_logic := '0';
    signal SR_reset     : std_logic;
    signal SR_enable    : std_logic;
    signal SR_ack       : std_logic;
    signal SR_w_0       : std_logic_vector(5 downto 0);
    signal SC_I         : std_logic_vector(3 downto 0);
    signal SR_p_0	    : std_logic_vector(5 downto 0);
    signal SR_n_1 	    : std_logic_vector(6 downto 0);
    signal SR_w_1 	    : std_logic_vector(5 downto 0);
    signal SR_n_2	    : std_logic_vector(5 downto 0);
    signal SR_w_2 	    : std_logic_vector(1 downto 0);
    signal SR_n_3 	    : std_logic_vector(4 downto 0);
    signal SR_arg       : std_logic;

    signal SC_request 		: std_logic;
    signal SC_en_load 		: std_logic;
    signal SC_en_c_w		: std_logic;
    signal SC_en_c_p		: std_logic;
    signal SC_w_1_en		: std_logic;
    signal SC_n_1_en 		: std_logic;
    signal SC_w_2_en 		: std_logic;
    signal SC_n_2_en 		: std_logic;
    signal SC_n_3_en		: std_logic;
    signal SC_classifvalid 	: std_logic;
    signal SC_arg 			: std_logic;

    begin
    SR_clock <= not SR_clock after 7 ns;
    SR_reset <= '0' , '1' after 19 ns;
        fsm_instance : FSM
        port map (
            I_clk => SR_clock,
            I_rst => SR_reset,
            i_ack => SR_ack,
            i_w_0 => SR_w_0,
            i_p_0 => SR_p_0,
            i_n_1 => SR_n_1,
            i_w_1 => SR_w_1,
            i_n_2 => SR_n_2,
            i_w_2 => SR_w_2,
            i_n_3 => SR_n_3,
            i_arg => SR_arg,
            o_request => SC_request,
            o_en_load => SC_en_load,
            o_en_c_w => SC_en_c_w,
            o_en_c_p => SC_en_c_p,
            o_w_1_en => SC_w_1_en,
            o_n_1_en => SC_n_1_en,
            o_w_2_en => SC_w_2_en,
            o_n_2_en => SC_n_2_en,
            o_n_3_en => SC_n_3_en,
            o_classifvalid => SC_classifvalid,
            o_arg => SC_arg
    );  

    SR_ack <= '0', '1' after 25 ns, '0' after 45 ns, '1' after 65 ns;
            
end tb_fsm;



