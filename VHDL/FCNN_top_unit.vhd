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
		I_W_0	: in std_logic_vector(5 downto 0); 
		I_P_0	: in std_logic_vector(5 downto 0);
		I_N_1 	: in std_logic_vector(6 downto 0);
		I_W_1 	: in std_logic_vector(5 downto 0);
		I_N_2	: in std_logic_vector(5 downto 0);
		I_W_2 	: in std_logic_vector(1 downto 0);
		I_N_3 	: in std_logic_vector(4 downto 0);
		I_arg	: in std_logic;
		O_request 		: out std_logic;
		O_en_load 		: out std_logic;
		O_en_C_W		: out std_logic;
		O_en_C_P		: out std_logic;
		O_W_1_en		: out std_logic;
		O_N_1_en 		: out std_logic;
		O_W_2_en 		: out std_logic;
		O_N_2_en 		: out std_logic;
		O_N_3_en		: out std_logic;
		O_classifValid 	: out std_logic;
		O_arg 			: out std_logic
		);
    end component;

    Component CreateWord is
        generic (
		    address_size : natural 
	    );
	    port (
            I_clk       : in std_logic;
            I_rst       : in std_logic;
	    	I_pixel 	: in std_logic_vector(7 downto 0);
		    I_en_load 	: in std_logic;
		    I_en_C_P	: in std_logic;
		    I_en_C_W 	: in std_logic;
		    O_addr_I_0	: out std_logic_vector(address_size -1 downto 0);
		    O_I_0		: out std_logic_vector(223 downto 0);
		    O_en_I_0 	: out std_logic
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
		    address_W_size : NATURAL := 10;
		    address_I_size : NATURAL := 10;
		    N_size : NATURAL := 5;
		    W_size : NATURAL := 5
	    );
	    port (
		    I_clk 		: in std_logic;
		    I_rst 		: in std_logic;
		    I_N_1_en 	: in std_logic;
		    I_W_1_en 	: in std_logic;
		    O_addr_W_1 	: out std_logic_vector(address_W_size -1 downto 0);
		    O_addr_I_1	: out std_logic_vector(address_I_size -1 downto 0);
		    O_N_1 		: out std_logic_vector(N_size -1 downto 0); 
		    O_W_1		: out std_logic_vector(W_size -1 downto 0)
	    );
    end component;

    Component SubNeurone_l1 is 
        port (
		    I_clk	: in std_logic;
		    I_rst 	: in std_logic;
		    I_data  : in std_logic_vector(28*8-1 downto 0);
		    I_W 	: in std_logic_vector(28*5 -1 downto 0);
		    I_C 	: in std_logic_vector(6 downto 0);
		    I_biais	: in std_logic_vector(4 downto 0);
            O_d     : out std_logic_vector(7 downto 0)
        );
    end component;

    Component Counter_L2 is
        generic (
		    address_W_size : NATURAL := 10;
		    address_I_size : NATURAL := 10;
		    N_size : NATURAL := 5;
		    W_size : NATURAL := 5
	    );
	    port (
		    I_clk 		: in std_logic;
		    I_rst 		: in std_logic;
		    I_N_2_en 	: in std_logic;
		    I_W_2_en 	: in std_logic;
		    O_addr_W_2 	: out std_logic_vector(address_W_size -1 downto 0);
		    O_N_2 		: out std_logic_vector(N_size -1 downto 0); 
		    O_W_2		: out std_logic_vector(W_size -1 downto 0)
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
	    generic (
		    address_W_size : NATURAL := 10
	    );
	    port (
		    I_clk		: in std_logic;
		    I_rst		: in std_logic;
		    I_N_3_en 	: in std_logic;
		    O_addr_W_3 	: out std_logic_vector(address_W_size-1 downto 0);
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
		    I_C 	: in std_logic_vector(6 downto 0);
		    I_biais	: in std_logic_vector(4 downto 0);
            O_d     : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component SubNeurone_l3 is 
	    port (
		    I_clk	: in std_logic;
		    I_rst 	: in std_logic;
		    I_data  : in std_logic_vector(28*8-1 downto 0);
		    I_W 	: in std_logic_vector(28*5 -1 downto 0);
		    I_C 	: in std_logic_vector(6 downto 0);
		    I_biais	: in std_logic_vector(4 downto 0);
	        O_d     : out std_logic_vector(7 downto 0)
        );
    end component;


	--------------------------------------------------
	--					CONSTANT DECLARATION	    --
	--------------------------------------------------
	
   -- Constant are defined here.
	
 	--------------------------------------------------
	--				  TYPE DECLARATION              --
	--------------------------------------------------
	
   -- Types are defined here.
   
    --------------------------------------------------
	--				  SIGNAL DECLARATION            --
	--------------------------------------------------

	-- Signals are defined here..
	
begin


	
end Behavioral;

