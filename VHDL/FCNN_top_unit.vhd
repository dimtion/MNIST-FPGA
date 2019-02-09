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
	--					CONSTANT DECLARATION		         --
	--------------------------------------------------
	
   -- Constant are defined here.
	
 	--------------------------------------------------
	--				  TYPE DECLARATION                  --
	--------------------------------------------------
	
   -- Types are defined here.
   
   --------------------------------------------------
	--				  SIGNAL DECLARATION                --
	--------------------------------------------------

	-- Signals are defined here..
	
begin


	
end Behavioral;

