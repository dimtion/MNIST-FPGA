library ieee;   
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.utils_pkg.ALL;
 
--Single Port RAM 
entity SinglePort_RAM is 
	generic (
		G_DEPTH      : NATURAL  := 8;             -- Depth of the RAM.
		G_WordLength : NATURAL  := 32;            -- Word size of the RAM.
      G_STYLE      : STRING   := "distributed"  -- Synthesis option: "distributed" uses slices, "block" uses BRAM.
		);
	port (
		I_clk   : in  STD_LOGIC;                                  -- Typical system clock.
		I_wr    : in  STD_LOGIC;                                  -- Enable write signal.
		I_addr  : in  UNSIGNED(log2(G_DEPTH)-1 downto 0);         -- Address to read/write from/to.
		I_data  : in  STD_LOGIC_VECTOR(G_WordLength-1 downto 0);  -- Input RAM data to write.
		O_data  : out STD_LOGIC_VECTOR(G_WordLength-1 downto 0)   -- Output RAM data.
);   
		  
end SinglePort_RAM;   

architecture Behavioral of SinglePort_RAM is  

  type T_ram_type is array (G_DEPTH-1 downto 0) of STD_LOGIC_VECTOR(G_WordLength-1 downto 0);   
  signal SA_RAM : T_ram_type;
  
  attribute ram_style: STRING;
  attribute ram_style of SA_RAM : signal is G_STYLE; 
  
begin   

	process (I_clk)   
	begin   
		if (I_clk'event and I_clk = '1') then   
		
			if (I_wr = '1') then   
				SA_RAM(to_integer(I_addr)) <= I_data; 
			end if;    
			
            O_data <= SA_RAM(to_integer(I_addr));
			
		end if;   
	end process;   
end Behavioral; 

