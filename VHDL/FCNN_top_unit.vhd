library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utils_pkg.ALL;

-- Top level of the Fully Connected Neural Network (FCNN) unit.
entity FCNN_top_unit is
	 Generic(
			  G_NBITS_PIXEL     : NATURAL := 8;   -- Number of bits for the input pixels.
			  G_NUMBER_PIXELS   : NATURAL := 784; -- Number of input pixels in an image.
			  G_NUMBER_CLASSES  : NATURAL := 10;  -- Number of classes (= Depth of the output layer)
        G_NBITS_WEIGHTS   : NATURAL := 8;   -- Number of bits for the weights.
			  G_LUT_FOLDER      : STRING  := "../LUT_files"   -- Path of the folder containing the LUTs.
	 );
    Port ( 
    
         -------------------------- CLOCK AND RESET -------------------------
        I_clk        : in  STD_LOGIC;   -- System clock.
				I_aync_rst   : in  STD_LOGIC;   -- Asnchronous reset.
         --------------------------------------------------------------------
           
         -------------------------- CONTROL SIGNALS -------------------------   
         O_requestPixel : out STD_LOGIC; -- Request a new pixel.
         I_ackPixel     : in  STD_LOGIC; -- Acknowledge the request and send a valid "I_pixel" signal.
         O_classifValid : out STD_LOGIC; -- The "O_classif" output provides a valid result.
         O_readyClassif : out STD_LOGIC; -- Inform that the processor is ready to process a new classif.
         --------------------------------------------------------------------
         
         -------------------------- INPUT/OUPUT DATA ------------------------ 
         I_pixel      : in  STD_LOGIC_VECTOR (G_NBITS_PIXEL-1 downto 0); -- 
         O_classif    : out STD_LOGIC_VECTOR (log2(G_NUMBER_CLASSES)-1 downto 0)
         -------------------------- INPUT/OUPUT DATA ------------------------ 
         
         );
end FCNN_top_unit;

architecture Behavioral of FCNN_top_unit is

    --------------------------------------------------
	--					COMPONENT DECLARATION	    --
	--------------------------------------------------

    component FSM is 
        port (
		I_clk	: in std_logic;
		I_rst	: in std_logic;
		I_ack 	: in std_logic;
		I_W_0	: in std_logic_vector(4 downto 0); 
		I_P_0	: in std_logic_vector(4 downto 0);
		I_N_1 	: in std_logic_vector(5 downto 0);
		I_W_1 	: in std_logic_vector(4 downto 0);
		I_N_2	: in std_logic_vector(4 downto 0);
		I_W_2 	: in std_logic_vector(1 downto 0);
		I_N_3 	: in std_logic_vector(3 downto 0);
		I_arg	: in std_logic;
		O_request 		: out std_logic;
		O_en_load 		: out std_logic;
		O_en_C_W		: out std_logic;
		O_en_C_P		: out std_logic;
		O_W_1_en		: out std_logic;
		O_N_1_en 		: out std_logic;
		O_clean_N_1		: out std_logic;
		O_clean_W_1		: out std_logic;
		O_W_2_en 		: out std_logic;
		O_N_2_en 		: out std_logic;
		O_clean_W_2		: out std_logic;
		O_clean_N_2		: out std_logic;
		O_N_3_en		: out std_logic;
		O_clean_N_3		: out std_logic;
		O_classifValid 	: out std_logic;
		O_clean_P 		: out std_logic;
		O_arg 			: out std_logic
		);
    end component;

    Component CreateWord is
	    port (
        I_clk       : in std_logic;
        I_rst       : in std_logic;
	    	I_pixel 	: in std_logic_vector(7 downto 0);
		    I_en_load 	: in std_logic;
		    I_en_C_P	: in std_logic;
		    I_en_C_W 	: in std_logic;
		    I_clean_P 	: in std_logic;
			O_I_0		: out std_logic_vector(223 downto 0);
		    O_en_I_0 	: out std_logic;
            O_pixelCount : out std_logic_vector(4 downto 0);
	    	O_W_0 		: out std_logic_vector(4 downto 0)
		);
    end component;

    Component Ram_W_1 is 
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
    end component;

    component Counter_L1 is 
        generic (
		    N_size : NATURAL;
		    W_size : NATURAL 
	    );
	    port (
		    I_clk 		: in std_logic;
		    I_rst 		: in std_logic;
		    I_N_1_en 	: in std_logic;
		    I_W_1_en 	: in std_logic;
			I_W_Clean 	: in std_logic;
			I_N_Clean 	: in std_logic;
		    O_N_1 		: out std_logic_vector(N_size -1 downto 0); 
		    O_W_1		: out std_logic_vector(W_size -1 downto 0);
	    	O_W_N		: out std_logic_vector(10 downto 0)
		);
    end component;

    Component SubNeurone_l1 is 
        port (
		    I_clk	: in std_logic;
		    I_rst 	: in std_logic;
		    I_data  : in std_logic_vector(28*8-1 downto 0);
		    I_W 	: in std_logic_vector(28*5 -1 downto 0);
		    I_C 	: in std_logic_vector(4 downto 0);
		    I_biais	: in std_logic_vector(4 downto 0);
        O_d     : out std_logic_vector(7 downto 0)
        );
    end component;

    Component Counter_L2 is
        generic (
		    N_size : NATURAL := 5;
		    W_size : NATURAL := 5
	    );
	    port (
		    I_clk 		: in std_logic;
		    I_rst 		: in std_logic;
		    I_N_2_en 	: in std_logic;
		    I_W_2_en 	: in std_logic;
			I_clean_N	: in std_logic;
			I_clean_W	: in std_logic;
		    O_N_2 		: out std_logic_vector(N_size -1 downto 0); 
		    O_W_2		: out std_logic_vector(W_size -1 downto 0);
		    O_W_N 		: out std_logic_vector(5 downto 0)
	);
    end component;

    component Ram_b_1 is 
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
    end component;


    component Ram_W_2 is 
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
    end component;

    component Ram_W_3 is 
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
    end component;

    component Ram_b_2 is 
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
    end component;

    component Ram_b_3 is 
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
    end component;

    component Counter_L3 is 
	    port (
		    I_clk		: in std_logic;
		    I_rst		: in std_logic;
		    I_N_3_en 	: in std_logic;
			I_clean_N 	: in std_logic;
            O_N_3       : out std_logic_vector(3 downto 0)
        );
    end Component;

    component Argmax is 
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
    end component;

    component SubNeurone_l2 is 
	    port (
		    I_clk	: in std_logic;
		    I_rst 	: in std_logic;
		    I_data  : in std_logic_vector(20*8-1 downto 0);
		    I_W 	: in std_logic_vector(20*5 -1 downto 0);
		    I_C 	: in std_logic_vector(1 downto 0);
		    I_biais	: in std_logic_vector(4 downto 0);
            O_d     : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component SubNeurone_l3 is 
	    port (
		    I_clk	: in std_logic;
		    I_rst 	: in std_logic;
		    I_data  	: in std_logic_vector(20*8-1 downto 0);
		    I_W 	: in std_logic_vector(20*5 -1 downto 0);
		    I_biais	: in std_logic_vector(4 downto 0);
	        O_d     : out std_logic_vector(7 downto 0)
        );
    end component;

    component DualPort_RAM is
        generic (
            G_DEPTH      : NATURAL;
            G_WordLength : NATURAL;
            G_STYLE      : STRING
        );
        port (
       
            I_clk   : in  STD_LOGIC;
            I_write           : in  STD_LOGIC;
            I_addr_write      : in  UNSIGNED(log2(G_DEPTH)-1 downto 0);
            I_dataWrite       : in  STD_LOGIC_VECTOR(G_WordLength-1 downto 0);
            I_addr_read       : in  UNSIGNED(log2(G_DEPTH)-1 downto 0);
            O_dataRead        : out STD_LOGIC_VECTOR(G_WordLength-1 downto 0)
        );
    end component;

    component NeuronCombinator is
	generic (
		nb_neurons 	: natural;
		size_w 		: natural;
		is_not_divided 	: natural
	);
	port (
		I_clk 		: in std_logic;
		I_rst 		: in std_logic;
		I_en 		: in std_logic;
		I_data 		: in std_logic_vector(size_w-1 downto 0);
		I_ouputswitch 	: in std_logic;
		O_data 		: out std_logic_vector((nb_neurons*size_w)/(2-is_not_divided)-1 downto 0)
  	);
	end component;

	--------------------------------------------------
	--					CONSTANT DECLARATION	    --
	--------------------------------------------------
	
   -- Constant are defined here5.
	
 	--------------------------------------------------
	--				  TYPE DECLARATION              --
	--------------------------------------------------
	
   -- Types are defined here.
   
    --------------------------------------------------
	--				  SIGNAL DECLARATION            --
	--------------------------------------------------

	-- Signals are defined here..


signal I_W_0 : std_logic_vector(4 downto 0);
signal I_arg : std_logic;

signal en_load : std_logic;
signal en_C_P : std_logic;
signal en_C_W : std_logic;
signal W_1_en : std_logic;
signal N_1_en : std_logic;
signal W_2_en : std_logic;
signal N_2_en : std_logic;
signal N_3_en : std_logic;
signal O_arg : std_logic;

signal I_O : std_logic_vector(223 downto 0);
signal en_I_O : std_logic;

signal pixel_count : std_logic_vector(4 downto 0);

-- RAM input
signal I_ram_read_W_l1 : std_logic_vector(4 downto 0);

-- RAM outputs
signal img_l1 : std_logic_vector(224-1 downto 0);
signal O_W_1 : std_logic_vector(4 downto 0);
signal W_1 : std_logic_vector(140-1 downto 0);
signal B_1 : std_logic_vector(5-1 downto 0);
signal W_2 : std_logic_vector(99 downto 0);
signal B_2 : std_logic_vector(4 downto 0);
signal W_3 : std_logic_vector(99 downto 0);
signal B_3 : std_logic_vector(4 downto 0);

signal O_N_1 : std_logic_vector(5 downto 0);
signal O_W_N_1 : std_logic_vector(10 downto 0);
signal O_W_N_2 : std_logic_vector(5 downto 0);
signal I_read_W_l1 : std_logic_vector(10 downto 0); 
signal I_read_W_l2 : std_logic_vector(5 downto 0);
signal O_W_2 : std_logic_vector(1 downto 0);
signal O_N_2 : std_logic_vector(4 downto 0);

signal O_N_3 : std_logic_vector(3 downto 0);
signal I_read_W_l3 : std_logic_vector(3 downto 0);
signal I_read_B_3 : std_logic_vector(3 downto 0);

-- SubNeuron1 outputs
signal O_Subneurone_1 : std_logic_vector(7 downto 0);
signal O_Subneurone_2 : std_logic_vector(7 downto 0);
signal O_Subneurone_3 : std_logic_vector(7 downto 0);
signal O_l1 : std_logic_vector(8*40/2-1 downto 0);
signal O_l2 : std_logic_vector(8*20-1 downto 0);
signal O_l3 : std_logic_vector(8*10-1 downto 0);
signal load_subneuron_val_1 : std_logic;
signal load_subneuron_val_2 : std_logic;

signal Class_1 	: std_logic_vector(7 downto 0);
signal Class_2 	: std_logic_vector(7 downto 0);
signal Class_3 	: std_logic_vector(7 downto 0);
signal Class_4 	: std_logic_vector(7 downto 0);
signal Class_5 	: std_logic_vector(7 downto 0);
signal Class_6 	: std_logic_vector(7 downto 0);
signal Class_7 	: std_logic_vector(7 downto 0);
signal Class_8	: std_logic_vector(7 downto 0);
signal Class_9 	: std_logic_vector(7 downto 0);
signal Class_10 : std_logic_vector(7 downto 0);

signal clean_p : std_logic;
signal clean_W_1 : std_logic;
signal clean_N_1 : std_logic;
signal clean_W_2 : std_logic;
signal clean_N_2 : std_logic;
signal clean_N_3 : std_logic;

signal classifValid : std_logic;
-- layer 2 outputs
signal input_first_part : std_logic;

begin

load_subneuron_val_1 <= '1' when (to_integer(unsigned(O_W_1)) = 28)  else '0';
load_subneuron_val_2 <= '1' when to_integer(unsigned(O_W_2)) = 2 else '0';

Class_1	 <= O_l3(8*10-1 downto 8*9);
Class_2	 <= O_l3(8*9-1 downto 8*8);
Class_3	 <= O_l3(8*8-1 downto 8*7);
Class_4	 <= O_l3(8*7-1 downto 8*6);
Class_5	 <= O_l3(8*6-1 downto 8*5);
Class_6	 <= O_l3(8*5-1 downto 8*4);
Class_7	 <= O_l3(8*4-1 downto 8*3);
Class_8	 <= O_l3(8*3-1 downto 8*2);
Class_9	 <= O_l3(8*2-1 downto 8*1);
Class_10 <= O_l3(8*1-1 downto 0);

O_readyClassif <= classifvalid;
O_classifvalid <= classifvalid;

--I_ram_read_W_l1 <= O_W_1 when (to_integer(unsigned(O_W_1)) /= 28) else (others => '0');

    Fsm_top : FSM
        port map(    
		i_clk   => I_clk,
		I_rst   => I_aync_rst,
		i_ack   => I_ackPixel,
		i_w_0   => I_W_0,
		i_p_0   => pixel_count,
		i_n_1   => O_N_1,
		i_w_1   => O_W_1,
		i_n_2   => O_N_2,
		i_w_2   => O_W_2,
		i_n_3   => O_N_3,
		i_arg   => I_arg,
		o_request => O_requestPixel,		
		o_en_load => en_load,		
		o_en_c_w => en_C_W,		
		o_en_c_p => en_C_P,
		o_w_1_en => W_1_en,		
		o_n_1_en => N_1_en,
		o_clean_n_1	=> clean_n_1,
		o_clean_w_1	=> clean_w_1,
		o_w_2_en => W_2_en,
		o_n_2_en => N_2_en,
		o_clean_N_2	=> clean_N_2,
		o_clean_W_2	=> clean_W_2,
		o_n_3_en => N_3_en,
		O_clean_N_3 => clean_N_3,
		o_clean_p	=> clean_P,
		o_classifvalid => classifValid,
		o_arg => O_arg
		);
    
    CreateWord_1 : CreateWord 
	port map(
		I_clk       => I_clk,
		I_rst       => I_aync_rst,
		I_pixel     => I_pixel,	
		I_en_load   => en_load,
		I_en_C_P	=> en_C_P,
		I_en_C_W 	=> en_C_W,
		I_clean_P 	=> clean_P,
		O_I_0		=> I_O,
		O_en_I_0 	=> en_I_O,
        O_pixelCount => pixel_count,
    	O_W_0 		=> I_W_0
	);

	Ram_W_1_1 : Ram_W_1
	    generic map (
			size_w  => 140,
			addr_size => 11
		)
	    port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			addr_r => I_read_W_l1,
			data_r => W_1	
		);

	Ram_B_1_1 : Ram_B_1
	    generic map (
			size_w  => 5,
			addr_size => 6
		)
	    port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			addr_r => O_N_1,
			data_r => B_1	
		);

	Counter_L1_1 : Counter_L1
	    generic map(
		N_size => 6, 	-- 40 neurones
		W_size => 5 	-- 28 mots
	    )		
	    port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_N_1_en => N_1_en, 	-- en neurone
			I_W_1_en => W_1_en, 	-- en mots
			O_N_1 => O_N_1, 	-- compteur neurone
			O_W_1 => O_W_1, 	-- compteur mots
			I_W_Clean => clean_W_1,
			I_N_Clean => clean_N_1,
			O_W_N => O_W_N_1 	-- mult mots+(neurone*nb_mot) pour Ram_W_1
	    );

	SubNeurone_L1_1 : SubNeurone_l1
		port map (
		    I_clk => I_clk,
		    I_rst => I_aync_rst,
		    I_data => img_l1,
		    I_W => W_1,
		    I_C => O_W_1,
		   I_biais => (others => '0'), --B_1,
		    O_d => O_Subneurone_1
	    );
	NeuronCombinator_1 : NeuronCombinator
		generic map (
			nb_neurons => 40,
			size_w => 8,
			is_not_divided => 0
		)
		port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_en => load_subneuron_val_1,
			I_data => O_Subneurone_1,
			I_ouputswitch => input_first_part,
			O_data => O_l1
		);
    Ram_I : DualPort_RAM 
        generic map(
            G_DEPTH         => 28,
            G_WordLength    => 224,
            G_STYLE         => "distributed"
        )
        port map(
            I_clk => I_clk,
            I_write => en_I_O,
            I_addr_write =>  unsigned(pixel_count), -- pixel counter 
            I_dataWrite => I_O,
            I_addr_read => unsigned(I_ram_read_W_l1),  -- pixel counter
            O_dataRead => img_l1
	    );

	Counter_L2_1 : Counter_L2
		generic map(
			N_size => 5,
			W_size => 2	
		)
		port map(
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_N_2_en => N_2_en,
			I_W_2_en => W_2_en,
			I_clean_N => clean_N_2,
			I_clean_W => clean_W_2,
			O_N_2 => O_N_2, 	-- 20 neurones
			O_W_2 => O_W_2,		-- 2 mots
			O_W_N => O_W_N_2	
		);
	SubNeurone_L2_1 : SubNeurone_l2
		port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_data => O_l1, 
			I_W => W_2,
			I_C => O_W_2,
			I_biais => (others => '0'), -- b_2,
			O_d => O_Subneurone_2
		);	

	Ram_W_2_1 : Ram_W_2
	    generic map (
			size_w  => 100,
			addr_size => 6 
		)
	    port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			addr_r => I_read_W_l2,
			data_r => W_2
		);
		
	Ram_B_2_1 : Ram_B_2
	    generic map (
			size_w  => 5,
			addr_size => 5
		)
	    port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			addr_r => O_N_2,
			data_r => B_2	
		);
	
	NeuronCombinator_2 : NeuronCombinator
		generic map (
			nb_neurons => 20,
			size_w => 8,
			is_not_divided => 1
		)
		port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_en => load_subneuron_val_2,
			I_data => O_Subneurone_2,
			I_ouputswitch => '0', 
			O_data => O_l2
		);
	
	Counter_L3_1 : Counter_L3
		port map(
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_N_3_en => N_3_en,
			I_clean_N => clean_N_3,
			O_N_3 => O_N_3 	-- 10 neurones
		);
	SubNeurone_L3_1 : SubNeurone_l3
		port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_data => O_l2, 
			I_W => W_3,
			I_biais => (others => '0'), --b_3,
			O_d => O_Subneurone_3
		);	

	Ram_W_3_1 : Ram_W_3
	    generic map (
			size_w  => 100,
			addr_size => 4
		)
	    port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			addr_r => I_read_W_l3, 
			data_r => W_3
		);
	Ram_b_3_1 : Ram_b_3
		generic map(
			size_w => 5,
			addr_size => 4
		)
		port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			addr_r => I_read_B_3,
			data_r => B_3
		);

	Argmax_1 : Argmax  
	    Port map(
		    I_clk 	=> I_clk,	
	    	I_rst 	=> I_aync_rst,
		    I_P1 	=> Class_1,
		    I_P2 	=> Class_2,
		    I_P3 	=> Class_3,
		    I_P4 	=> Class_4,
		    I_P5 	=> Class_5,
		    I_P6 	=> Class_6,
		    I_P7 	=> Class_7,
		    I_P8 	=> Class_8,
		    I_P9 	=> Class_9,
		    I_P10 	=> Class_10,
		    I_en  	=> O_arg,	
		    O_I 	=> O_Classif,
		    O_done	=> I_arg 
		    );

	NeuronCombinator_3 : NeuronCombinator
		generic map (
			nb_neurons => 10,
			size_w => 8,
			is_not_divided => 1
		)
		port map (
			I_clk => I_clk,
			I_rst => I_aync_rst,
			I_en => N_3_en,
			I_data => O_Subneurone_3,
			I_ouputswitch => '0', 
			O_data => O_l3
		);

--input_first_part <= O_W_2(0);

process(O_W_2, W_2_en) 
begin
	if (W_2_en = '1') then
		input_first_part <= (not O_W_2(0)) and ( not O_W_2(1));
	else 
		input_first_part <= O_W_2(0);
	end if;
end process;

process(O_W_N_1, W_1_en)
begin 
	if to_integer(unsigned(O_W_N_1) )<1119 then
		if (W_1_en ='1') then	
			I_read_W_l1 <= std_logic_vector(to_unsigned(to_integer(unsigned(O_W_N_1))+1,11));
		else 
			I_read_W_l1 <= O_W_N_1;
		end if;
	else 
		I_read_W_l1 <= (others => '0');
	end if;
end process;

process(O_W_1,w_1_en)
begin 
	if to_integer(unsigned(O_W_1)) < 27 then 
		if (w_1_en = '1') then 
			I_ram_read_W_l1 <= std_logic_vector(to_unsigned(to_integer(unsigned(O_W_1))+1,5));
		else 
			I_ram_read_W_l1 <= O_W_1;
		end if ;

	else 
		I_ram_read_W_l1 <= (others => '0');
	end if; 
end process;

process(O_W_N_2,W_2_en)
begin	
	if to_integer(unsigned(O_W_N_2)) < 39 then
		if(w_2_en = '1') then
			I_read_W_l2 <= std_logic_vector(to_unsigned(to_integer(unsigned(O_W_N_2))+1,6));
		else 
			I_read_W_l2 <= O_W_N_2;
		end if;
	else 
		I_read_W_l2 <= (others => '0');
	end if;
end process;

process(O_N_3, N_3_en)
begin	
	if to_integer(unsigned(O_N_3)) < 9 then
		if(n_3_en = '1') then
			I_read_W_l3 <= std_logic_vector(to_unsigned(to_integer(unsigned(O_N_3))+1,4));
			I_read_B_3 <= std_logic_vector(to_unsigned(to_integer(unsigned(O_N_3))+1,4));
		else 
			I_read_W_l3 <= O_N_3;
			I_read_B_3 <= O_N_3;
		end if;
	else 
		I_read_B_3	<= (others => '0');
		I_read_W_l3 <= (others => '0');
	end if;
end process;

--I_ram_read_W_l1 <= O_W_1 when (to_integer(unsigned(O_W_1)) /= 28) else (others => '0');
end Behavioral;

