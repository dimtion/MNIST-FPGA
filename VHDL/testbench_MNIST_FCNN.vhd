library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.utils_pkg.ALL;

use STD.TEXTIO.ALL;
use ieee.std_logic_textio.all;


entity testbench_MNIST_FCNN is
end testbench_MNIST_FCNN;

architecture Behavioral of testbench_MNIST_FCNN is

   --------------------------------------------------
	--			UNIT UNDER TEST  PARAMETERS            --
	--------------------------------------------------
   
   -- /!\ TO BE MODIFIED OR COMPLETED /!\ 
   constant C_NBITS_WEIGHTS 	 : NATURAL := 16;   -- Number of bit for the weight coefficients? TBC...
   
   -- To be completed...

   --------------------------------------------------
	--			     SIMULATION PARAMETERS             --
	--------------------------------------------------
	
  -- /!\ TO BE MODIFIED /!\ 
	constant C_NUM_CLASSIF_SIMUL  : NATURAL := 100;                                  -- number of image classification to test. /!\ simulation time /!\ .
   constant C_PROCESSING_SPEED   : NATURAL := 2;
	constant C_IMAGE_FILEPATH     : STRING  := "../VHDL/testbench_files/PixelData/PixelData";  -- File path where the pixel data are stored.
	constant C_TARGET_FILEPATH    : STRING  := "../VHDL/testbench_files/Targets.tb";           -- File path where the class target for each image are stored.
   
   --------------------------------------------------
	--	      HARD CONSTANT /!\ DO NOT TOUCH /!\     --
	--------------------------------------------------
	
   constant C_CLOCK_PERIOD    	 : TIME     := 10  ns;                 -- Time sampling.
   constant C_NBITS_PIXELS 	    : NATURAL  := 8;                      -- Number of bit for the pixel data.
   constant C_NUMBER_CLASSES      : NATURAL  := 10;                     -- Number of classes.
   constant C_NBITS_CLASSIF_OUT 	 : NATURAL  := log2(C_NUMBER_CLASSES); -- Number of bit for the classif output.
	constant C_NUM_PIXEL_PER_IMAGE : NATURAL  := 784;                    -- Number of pixel per image.
	
   --------------------------------------------------
	--				  SIGNAL DECLARATION                --
	--------------------------------------------------
   
   -- Debug counter, to count the number of cycle and help beginning.
   signal S_DEBUG_COUNTER  	    : INTEGER := 0;
	signal S_NUMBER_CLASSIF_ERRORS : INTEGER := 0; -- Signal to be monitored to validate the network.

	-- signal which store all the input pixel values.
	signal S_pixel_array    : T_INTEGER_ARRAY(0 to C_NUM_PIXEL_PER_IMAGE-1);
	
	-- signal which stored all the target values.
	constant S_targets_array  : T_INTEGER_ARRAY(0 to C_NUM_CLASSIF_SIMUL-1) 
									  := read_data( C_TARGET_FILEPATH,  C_NUM_CLASSIF_SIMUL );
	
	-- Signals for simulation purpose.
	signal S_enable_simul   : STD_LOGIC;
	signal S_clk            : STD_LOGIC;
	signal S_LastPixelFlag  : STD_LOGIC;

	
	-- Signals mapped to the Unit Under Test (uut)
	signal S_resetN_uut       : STD_LOGIC;
	signal S_pixel_uut        : STD_LOGIC_VECTOR(C_NBITS_PIXELS-1 downto 0);
	signal S_ackPixel_uut     : STD_LOGIC;
	signal S_classif_uut      : STD_LOGIC_VECTOR(C_NBITS_CLASSIF_OUT-1 downto 0);
   signal S_requestPixel_uut : STD_LOGIC;
	signal S_classifValid_uut : STD_LOGIC;
   signal S_readyClassif_uut : STD_LOGIC;
   
   
begin
  
  	--------------------------------------------------
	--				  SIMULATION CONTROL                --
	--------------------------------------------------	
	
	-- Generation of the clock signal and the debug counter.
    clk_p:process	
	begin
		S_clk <= '0';
		wait for C_CLOCK_PERIOD/2;
		S_clk <= '1';
		wait for C_CLOCK_PERIOD/2;
      S_DEBUG_COUNTER <= S_DEBUG_COUNTER + 1;
	end process;
    
   -- Simulation control process.
  	init_p:process
   begin

      -- Initial state.
      S_enable_simul <= '0';
      wait for 10*C_CLOCK_PERIOD;
		wait until S_clk = '0'; 
		S_enable_simul  <= '1';
		
      FOR I IN 0 TO C_NUM_CLASSIF_SIMUL-1 LOOP

         -- Load all the pixel in an array. 
         S_pixel_array <= read_data(C_IMAGE_FILEPATH & integer'image(I) & ".tb"  , C_NUM_PIXEL_PER_IMAGE);
			
         wait until S_clk = '1';  			 -- Synchronize the simulation process with the clock.
         wait until S_LastPixelFlag = '1';
			
      
      END LOOP;
		
		S_enable_simul  <= '0';
	  
      wait;
      
	end process;
    
	--------------------------------------------------
	--				  UUT INSTANCIATION                 --
	--------------------------------------------------	

   -- TX waveform under test.
   unit_under_test_inst : entity work.FCNN_top_unit
	generic map(
      G_NBITS_PIXEL 	  => C_NBITS_PIXELS,
      G_NBITS_WEIGHTS  => C_NBITS_WEIGHTS,
      G_NUMBER_CLASSES => C_NUMBER_CLASSES
	 )
    port map( I_clk           => S_clk,
			     I_aync_rst      => S_resetN_uut,
				  I_pixel         => S_pixel_uut,
              I_ackPixel      => S_ackPixel_uut,
              O_classif       => S_classif_uut,
              O_requestPixel  => S_requestPixel_uut,
				  O_classifValid  => S_classifValid_uut,
              O_readyClassif  => S_readyClassif_uut
	);  
 

   S_ackPixel_uut <= S_requestPixel_uut when (S_enable_simul = '1' and S_LastPixelFlag = '0') else '0';
 
   -- Process which control the input pixel data generation (loaded from files) 
   -- and generate the uut input control signal.
	process(S_clk)
			variable V_pixelIndex : NATURAL := 0;
			
		begin
			if( rising_edge(S_clk) )then 
			
				if(S_enable_simul = '0') then
					S_pixel_uut        <= std_logic_vector( to_unsigned( S_pixel_array(0) , C_NBITS_PIXELS) );
					V_pixelIndex := 0;
					S_LastPixelFlag    <= '0';
					S_resetN_uut 		 <= '0';
				else	
             
					S_resetN_uut <= '1';
               
               if(V_pixelIndex = C_NUM_PIXEL_PER_IMAGE) then
               	V_pixelIndex       := 0;
						S_LastPixelFlag    <= '1';
               else
                  S_LastPixelFlag    <= '0';
                  if(S_requestPixel_uut = '1' and V_pixelIndex < C_NUM_PIXEL_PER_IMAGE) then
                     S_pixel_uut <= std_logic_vector( to_unsigned( S_pixel_array(V_pixelIndex) , C_NBITS_PIXELS) );
                     V_pixelIndex := V_pixelIndex + 1; 
                  end if;
               end if;
               
				end if;
				
			end if;
	end process;
   
   
   -- Process which count the number of classif/ errors.
	process(S_clk)
			variable V_target_index : INTEGER := 0;
		begin
			if( rising_edge(S_clk) ) then 
			
				-- New classif result available.
				if( S_classifValid_uut = '1') then 
					
					if( S_targets_array(V_target_index) /= to_integer(unsigned(S_classif_uut)) ) then
						S_NUMBER_CLASSIF_ERRORS <= S_NUMBER_CLASSIF_ERRORS + 1;
					end if;
					
					V_target_index := V_target_index + 1;
					
				end if;
				
			end if;
	end process;
   
   
   

end Behavioral;
