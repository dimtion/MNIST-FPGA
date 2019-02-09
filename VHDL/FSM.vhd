library IEEE
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM is 
	port (
		I_clk	: in std_logic;
		I_rst	: in std_logic;
		I_ack 	: in std_logic;
		I_W_0	: in std_logic_vector(5 downto 0); 
		I_P_0	: in std_logic_vector(5 downto 0);
		I_N_1 : in std_logic_vector(6 downto 0);
		I_W_1 : in std_logic_vector(5 downto 0);
		I_N_2	: in std_logic_vector(5 downto 0);
		I_W_2 : in std_logic_vector(1 downto 0);
		I_N_3 : in std_logic_vector(4 downto 0);
		O_request 		: out std_logic;
		O_en_load 		: out std_logic;
		O_en_C_W		: out std_logic;
		O_en_C_P		: out std_logic;
		O_W_1_en		: out std_logic;
		O_N_1_en 		: out std_logic;
		O_W_2_en 		: out std_logic;
		O_N_2_en 		: out std_logic;
		O_N_3_en		: out std_logic;
		O_classifValid 	: out std_logic
		);
end FSM;

architecture Behavioral of FSM is 

	type T_State is (ST_Reset, ST_Wait, ST_Load, ST_L1, ST_L2, ST_L3, ST_Class, ST_Out);
	signal SC_Futur 	: T_State;
	signal SR_Present 	: T_State;
begin

	process(I_clk, I_rst)
	begin 
		if (I_rst = '1') then
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
				if I_ack = '1' then
					SC_Futur 	<= ST_Load;
					O_en_C_W	<= '1';
					O_en_C_P 	<= '1';
					O_request 	<= '0';
				else 
					SC_Futur 	<= ST_Wait;
					O_en_C_W 	<= '0';
					O_en_C_P 	<= '0';
					O_request	<= '1';
				end if;

			when ST_Load =>
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';	
				if ( 	to_integer(to_unsigned(I_W_0,7) = 27) and 
						to_integer(to_unsigned(I_P_0,7) = 27) ) then 
					SC_Futur 	<= ST_L1;
					O_request 	<= '0';
					O_W_1_en	<= '1';
					O_N_1_en	<= '1';

				else 
					SC_Futur 	<= ST_Wait;
					O_request 	<= '1';
					O_W_1_en	<= '0';
					O_N_1_en	<= '0';
				end if;


			when ST_L1 =>
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				if ( to_integer(to_unsigned(I_W_1,7) = 27) and 
						to_integer(to_unsigned(I_N_1,7) = 27) ) then 
					O_W_1_en <= '0';
					O_N_1_en <= '0';
					SC_Futur <= ST_L2;
					O_W_2_en <= '1';
					O_N_2_en <= '1';
				else 
					SC_Futur <= ST_L1;
					O_W_1_en <= '1';
					O_N_1_en <= '1';
					O_W_2_en <= '0';
					O_N_2_en <= '0';
				end if;

			when ST_L2 =>
				O_request 		<= '0';
				O_en_load 		<= '0';
				O_en_C_W		<= '0';
				O_en_C_P		<= '0';
				O_W_1_en		<= '0';
				O_N_1_en		<= '0';
				O_W_2_en 		<= '0';
				O_N_2_en 		<= '0';
				O_N_3_en		<= '0';
				O_classifValid 	<= '0';
				if ( to_integer(to_unsigned(I_W_2,1) = 1) and 
						to_integer(to_unsigned(I_N_2,6) = 19) ) then 
				
					SC_Futur 	<= ST_L3;
					O_W_2_en 	<= '0';
					O_N_2_en 	<= '0';
					O_N_3_en	<= '1';

				else 
					SC_Futur 	<= ST_L2;
					O_W_2_en 	<= '1';
					O_N_2_en 	<= '1';
					O_N_3_en	<= '0';

				end if;

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
				if (to_integer(to_unsigned(I_N_3, 5)=9) ) then
					SC_Futur <= ST_Class;
					O_N_3_en <= '1';
				else 
					SC_Futur <= ST_L3;
					O_N_3_en <= '0';
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
				SC_Futur <= ST_Out;

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
				O_classifValid 	<= '1';
				SC_Futur <= ST_Wait;

			when others => SC_Futur <= ST_Reset;
	end case;
end process;

end Behavioral;
