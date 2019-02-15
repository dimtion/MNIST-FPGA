library IEEE;

--Standard library
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.ALL;

--Not standard library
USE IEEE.STD_LOGIC_MISC.all; --not standard, but helpfull for AND_REDUCE.

--For testbench function
use STD.TEXTIO.ALL;
use ieee.std_logic_textio.all;

package utils_pkg  is

    ------------------------------
    --           TYPE           --
    ------------------------------
    
	-- Unconstrained array declaration for each usefull type.
	type T_NATURAL_ARRAY 		    is array(natural range <>) of NATURAL;
	type T_INTEGER_ARRAY 		    is array(natural range <>) of INTEGER;
	type T_REAL_ARRAY 			    is array(natural range <>) of REAL;
   type T_CHARACTER_ARRAY         is array(natural range <>) of CHARACTER;
	
	-- Constrained array declaration for each usefull type.
	type T_STD_LOGIC_VECTOR64_ARRAY is array(natural range <>) of STD_LOGIC_VECTOR(63 downto 0);
	type T_STD_LOGIC_VECTOR32_ARRAY is array(natural range <>) of STD_LOGIC_VECTOR(31 downto 0);
	type T_STD_LOGIC_VECTOR24_ARRAY is array(natural range <>) of STD_LOGIC_VECTOR(23 downto 0);
	type T_STD_LOGIC_VECTOR16_ARRAY is array(natural range <>) of STD_LOGIC_VECTOR(15 downto 0);
	type T_STD_LOGIC_VECTOR12_ARRAY is array(natural range <>) of STD_LOGIC_VECTOR(11 downto 0);
	type T_STD_LOGIC_VECTOR8_ARRAY  is array(natural range <>) of STD_LOGIC_VECTOR(7 downto 0);
	type T_STD_LOGIC_VECTOR3_ARRAY  is array(natural range <>) of STD_LOGIC_VECTOR(2 downto 0);
   type T_STD_LOGIC_VECTOR2_ARRAY  is array(natural range <>) of STD_LOGIC_VECTOR(1 downto 0);
	
	-- Constrained array declaration for each usefull type.
	type T_UNSIGNED64_ARRAY         is array(natural range <>) of UNSIGNED		   (63 downto 0);
	type T_UNSIGNED32_ARRAY         is array(natural range <>) of UNSIGNED		   (31 downto 0);
	type T_UNSIGNED24_ARRAY         is array(natural range <>) of UNSIGNED		   (23 downto 0);
	type T_UNSIGNED16_ARRAY         is array(natural range <>) of UNSIGNED		   (15 downto 0);
	type T_UNSIGNED12_ARRAY         is array(natural range <>) of UNSIGNED		   (11 downto 0);
	type T_UNSIGNED8_ARRAY          is array(natural range <>) of UNSIGNED		   (7 downto 0);
   type T_UNSIGNED2_ARRAY          is array(natural range <>) of UNSIGNED        (1 downto 0);
	
	-- Constrained array declaration for each usefull type.
	type T_SIGNED64_ARRAY           is array(natural range <>) of SIGNED		      (63 downto 0);
	type T_SIGNED32_ARRAY           is array(natural range <>) of SIGNED		      (31 downto 0);
	type T_SIGNED24_ARRAY           is array(natural range <>) of SIGNED		      (23 downto 0);
	type T_SIGNED16_ARRAY           is array(natural range <>) of SIGNED		      (15 downto 0);
	type T_SIGNED12_ARRAY           is array(natural range <>) of SIGNED		      (11 downto 0);
	type T_SIGNED8_ARRAY            is array(natural range <>) of SIGNED		      (7 downto 0);
   
    ------------------------------
    --    FUNCTION DECLARATION  --
    ------------------------------

    --Result = ceil(log2(I)), where I is a natural number.
	function log2( i : natural) return natural; 
    
    
   function findMaxInArray(inputArray : T_NATURAL_ARRAY) return natural;


    --Function which read data from file (for testbench only)
    --path : the path of the file to read.
    --data_part : "real" and "imaginary". Real part must be located at the beginning of the file.
    --FL : File Length. If you don't know the length of the file, then use find_file_length function.
    impure function read_data( path : string ; FL : natural ) return T_INTEGER_ARRAY;
    
    --Find the length of the file (number of line). 
    --Use this function only if there is no means to know the length of the file.
    --path : the part of the file to read.
    impure function find_file_length( path : string ) return natural;
    
end utils_pkg;


package body utils_pkg is

    ------------------------------
    --   FUNCTION DEFINITION    --
    ------------------------------

 function log2( i : natural) return natural is
    variable temp    : integer := i-1;
    variable ret_val : integer := 0; 
	begin				
	
		if(i = 1) then
			return ret_val;
		end if;
		
		while temp > 1 loop
			ret_val := ret_val + 1;
			temp    := temp / 2;     
		end loop;
		

		return ret_val+1;
  end function;

 function findMaxInArray(inputArray : T_NATURAL_ARRAY) return natural is
    variable arrayLength : natural := inputArray'length;
    variable maxValue    : natural := 0;
	begin				
	
		for I in 0 to arrayLength loop
         if( maxValue < inputArray(I) ) then
            maxValue := inputArray(I);
         end if;
      end loop;

		return maxValue;
  end function;
  

   impure function find_file_length( path : string ) return natural is
        file FILE_DATA: text open READ_MODE is path;
        variable L : line;
        variable I : natural;
	begin		
        I:=0;
        WHILE (not endfile(FILE_DATA)) LOOP
            readline(FILE_DATA, L);
            I:=I+1;
        END LOOP;
        return I;
        
    end function;
    
   impure function read_data( path : string ; FL : natural  ) return T_INTEGER_ARRAY is
        file FILE_DATA: text open READ_MODE is path;
        variable data_a : T_INTEGER_ARRAY(0 to FL-1);
        variable L : line;
        variable A : integer;
	begin		
    
      FOR I IN 0 TO FL-1 LOOP
      
         if(not endfile(FILE_DATA)) then
            readline(FILE_DATA, L);
            read(L, A);
            data_a(I):=A;
         else
            data_a(I):=0;
         end if;
         
      END LOOP;
        
      return data_a;
        
    end function;
    
end utils_pkg;


