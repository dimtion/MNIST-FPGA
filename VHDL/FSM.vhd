library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is 
	port (
		i_clk	: in std_logic;
		i_rst	: in std_logic;
		i_ack 	: in std_logic;
		i_w_0	: in std_logic_vector(4 downto 0); 
		i_p_0	: in std_logic_vector(4 downto 0);
		i_n_1 	: in std_logic_vector(5 downto 0);
		i_w_1 	: in std_logic_vector(4 downto 0);
		i_n_2	: in std_logic_vector(4 downto 0);
		i_w_2 	: in std_logic_vector(1 downto 0);
		i_n_3 	: in std_logic_vector(3 downto 0);
		i_arg	: in std_logic;
		o_request 		: out std_logic;
		o_en_load 		: out std_logic;
		o_en_c_w		: out std_logic;
		o_en_c_p		: out std_logic;
		o_clean_P		: out std_logic;
		o_w_1_en		: out std_logic;
		o_n_1_en 		: out std_logic;
		o_clean_n_1		: out std_logic;
		o_clean_w_1		: out std_logic;
		o_w_2_en 		: out std_logic;
		o_n_2_en 		: out std_logic;
		o_clean_n_2		: out std_logic;
		o_clean_w_2		: out std_logic;
		o_n_3_en		: out std_logic;
		o_clean_n_3		: out std_logic;
		o_classifvalid 	: out std_logic;
		o_arg 			: out std_logic
		);
end fsm;

architecture Behavioral of FSM is 

	type T_State is (ST_Reset, ST_Wait, ST_Load, ST_WriteRam, ST_L1, ST_temp_1, ST_L2,ST_temp_2,ST_L3, ST_Class, ST_Out);
	signal SC_Futur 	: T_State;
	signal SR_Present 	: T_State;
begin

	process(I_clk, I_rst)
	begin 
		if (I_rst = '0') then
			SR_Present <= ST_Reset;
		elsif (rising_edge(I_clk)) then
			SR_Present <= SC_Futur;
		end if;
	end process;

	process(I_ack,
			I_W_0,
			I_P_0,
			I_N_1,
			I_W_1,
			I_N_2,
			I_W_2,
			I_N_3,
			I_arg,
			SR_Present)
	
	begin 
		case SR_Present is 
			when ST_Reset =>
				O_request  		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				O_arg 			<= '0';
				O_clean_P <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				SC_Futur <= ST_Wait;

			when ST_Wait =>
				O_request 		<= '1';
				O_en_load 		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				O_arg 			<= '0';
				O_en_C_W 	<= '0';
				O_en_C_P 	<= '0';
				O_clean_P <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				if I_ack = '1' then
					SC_Futur 	<= ST_Load;
				else 
					SC_Futur 	<= ST_Wait;
				end if;

			when ST_Load =>
				O_en_load 		<= '1';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 		<= '0';	
				O_arg 			<= '0';
				O_en_C_W 		<= '1';
				O_en_C_P 		<= '1';
				O_request 	<= '0';
				O_W_1_en	<= '0';
				O_N_1_en	<= '0';
				O_clean_P <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				if (to_integer(Unsigned(I_W_0)) = 27 ) then 
					SC_Futur 	<= ST_WriteRam;
				else 
					SC_Futur 	<= ST_Wait;
				end if;
		
		when ST_WriteRam =>
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';	
				O_arg 			<= '0';
				O_en_C_W 		<= '1';
				O_en_C_P 		<= '1';
				O_request 	<= '0';
				O_W_1_en	<= '0';
				O_N_1_en	<= '0';
				O_clean_P 	<= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				if (to_integer(Unsigned(I_P_0))) = 27 then 
					SC_Futur 	<= ST_L1;
				else 
					SC_Futur 	<= ST_Wait;
				end if;

			when ST_L1 =>
			O_request 	<= '0';
			O_W_1_en	<= '1';
			O_N_1_en	<= '1';
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				O_arg 			<= '0';
				O_clean_P <= '0';
				O_W_2_en <= '0';
				O_N_2_en <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				if ( 	to_integer(Unsigned(I_W_1)) = 28 and 
						to_integer(Unsigned(I_N_1)) = 39) then 
					SC_Futur <= ST_temp_1;
				else 
					SC_Futur <= ST_L1;
				end if;
		when ST_temp_1 =>
			O_request 	<= '0';
			O_W_1_en	<= '0';
			O_N_1_en	<= '0';
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				O_arg 			<= '0';
				O_clean_P <= '0';
				O_W_2_en <= '0';
				O_N_2_en <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				SC_FUTUR <= ST_L2;

			when ST_L2 =>
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				O_arg 			<= '0';
				O_clean_P <= '0';
				O_W_1_en <= '0';
				O_N_1_en <= '0';
				O_W_2_en <= '1';
				O_N_2_en <= '1';
				O_clean_n_1 <= '1';
				O_clean_w_1 <= '1';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				if ( 	to_integer(Unsigned(I_W_2)) = 2 and 
						to_integer(Unsigned(I_N_2)) = 19)  then 
					SC_Futur 	<= ST_temp_2;
				else 
					SC_Futur 	<= ST_L2;
				end if;
		
		when ST_temp_2 =>
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_classifValid 	<= '0';
				SC_Futur <= ST_Wait;
				O_clean_P <= '0';
				O_N_3_en 	<= '0';
				O_arg <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				SC_futur <= ST_L3;

			when ST_L3 =>
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_classifValid 	<= '0';
				SC_Futur <= ST_Wait;
				O_clean_P <= '1';
				O_N_3_en 	<= '1';
				O_arg <= '0';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '1';
				O_clean_n_2 <= '1';
				o_clean_n_3 <= '0';
				if (to_integer(unsigned(I_N_3))=10) then
					SC_Futur <= ST_Class;
				else 
					SC_Futur <= ST_L3;
				end if;

			when ST_Class =>
				O_request		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				O_clean_P <= '0';
				O_arg <= '1';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '1';
				if (I_arg = '0') then
					SC_Futur <= ST_Class;
				else 
					SC_Futur <= ST_Out;
				end if;

			when ST_Out =>
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_arg 			<= '0';
				O_classifValid 	<= '1';
				O_clean_n_1 <= '0';
				O_clean_w_1 <= '0';
				O_clean_w_2 <= '0';
				O_clean_n_2 <= '0';
				o_clean_n_3 <= '0';
				SC_Futur <= ST_Wait;
				O_clean_P <= '0';

			when others => SC_Futur <= ST_Reset;
	end case;
end process;

end Behavioral;
