library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utils_pkg.ALL;

use STD.TEXTIO.ALL;
use ieee.std_logic_textio.all;

entity generic_LUT_unit is
	Generic(
		G_FILEPATH     : STRING;                    -- File path where the value to store are located.
      G_DEPTH_LUT    : NATURAL;                   -- Depth of the LUT.
		G_NBIT_LUT     : NATURAL;                   -- Wordsize of the LUT.
      G_STYLE        : STRING := "distributed";   -- Synthesis option: "distributed" uses slices, "block" uses BRAM.
		G_PIPELINE_REG : BOOLEAN := FALSE           -- Option to add a pipeline register (2 cycles to read!)
	);
	Port( 
   
		I_clk        : in STD_LOGIC;                                         -- Typical system clock.
		I_sel_sample : in STD_LOGIC_VECTOR( log2(G_DEPTH_LUT) - 1 downto 0); -- Address of the LUT.
		O_LUT_value  : out STD_LOGIC_VECTOR( G_NBIT_LUT-1 downto 0 )         -- Output data of the LUT.
	);
end generic_LUT_unit;

architecture Behavioral of generic_LUT_unit is

   type T_LUT_array is array (0 to G_DEPTH_LUT-1) of STD_LOGIC_VECTOR(G_NBIT_LUT-1 downto 0);
	 
	 
   impure function init_LUT_with_file_contents return T_LUT_array is
        file FILE_DATA: text open READ_MODE is G_FILEPATH;
        variable V_LUT_samples  : T_LUT_array;
        variable V_line_idx     : line;
        variable V_sample_value : integer;
		  variable V_sample_std   : STD_LOGIC_VECTOR( G_NBIT_LUT-1 downto 0 );
	begin		
    
      FOR I IN 0 TO G_DEPTH_LUT-1 LOOP
      
         readline(FILE_DATA, V_line_idx);
			
			-- Read real sample.
         read(V_line_idx, V_sample_value);
         V_sample_std := std_logic_vector(to_signed(V_sample_value, G_NBIT_LUT));
			V_LUT_samples(I) := V_sample_std;
		
			  
        END LOOP;
        
        return V_LUT_samples;
        
    end function;
	
	signal C_LUT_SAMPLES :  T_LUT_array := init_LUT_with_file_contents;
   
	signal R_LUT_cpx  : STD_LOGIC_VECTOR( G_NBIT_LUT - 1 downto 0);
   signal R_pipeline : STD_LOGIC_VECTOR( G_NBIT_LUT - 1 downto 0);

  attribute rom_style: STRING;
  attribute rom_style of C_LUT_SAMPLES : signal is G_STYLE; 
   
begin

	pipeline_case_gen:if ( G_PIPELINE_REG ) generate
		O_LUT_value <= R_pipeline;
	end generate;

	no_pipeline_case_gen:if ( not(G_PIPELINE_REG) ) generate
		O_LUT_value <= R_LUT_cpx;
	end generate;
	
	process(I_clk)
	begin
		
        if( I_clk'event and I_clk ='1' )then 
			
			R_LUT_cpx  <= C_LUT_SAMPLES(to_integer(unsigned(I_sel_sample)));
				
			IF( G_PIPELINE_REG ) THEN
				R_pipeline <= R_LUT_cpx;
			END IF;
				
		
		end if;
		
	end process;
                
end Behavioral;

