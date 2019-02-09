library ieee;   
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.utils_pkg.ALL;
 
entity DualPort_RAM is
   generic (
         G_DEPTH      : NATURAL  := 8; --Length of memory
         G_WordLength : NATURAL  := 3; --Word Length
         G_STYLE      : STRING   := "distributed"
   );
   port (
       
       I_clk   : in  STD_LOGIC; -- Common clock.
       
       -- Port A inferface
       I_write           : in  STD_LOGIC;
       I_addr_write      : in  UNSIGNED(log2(G_DEPTH)-1 downto 0);
       I_dataWrite       : in  STD_LOGIC_VECTOR(G_WordLength-1 downto 0);
        
       -- Port B inferface
       I_addr_read       : in  UNSIGNED(log2(G_DEPTH)-1 downto 0);
       O_dataRead        : out STD_LOGIC_VECTOR(G_WordLength-1 downto 0)
   );
end DualPort_RAM;
 
architecture rtl of DualPort_RAM is
    -- Shared memory
   type mem_type is array ( G_DEPTH-1 downto 0 ) of STD_LOGIC_VECTOR(G_WordLength-1 downto 0);
   signal mem : mem_type;
    
   attribute ram_style: STRING;
   attribute ram_style of mem : signal is G_STYLE; 
    
begin
 
-- Port A
process(I_clk)
begin
    if(I_clk'event and I_clk='1') then
        if(I_write = '1') then
            mem(to_integer(I_addr_write)) <= I_dataWrite;
        end if;
        O_dataRead <= mem(to_integer(I_addr_read));
    end if;
end process;
 
end rtl;
