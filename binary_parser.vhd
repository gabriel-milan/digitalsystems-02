-- Binary code parser to ASCII
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity
entity binary_parser is
	Port (
		binary_code : in  STD_LOGIC_VECTOR(3 downto 0);
		ascii_out : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end binary_parser;

-- Architecture
architecture Behavioral of binary_parser is

-- Behavioral
begin

   with binary_code select
      ascii_out <=
         X"30" when "0000",  -- 0
         X"31" when "0001",  -- 1
         X"32" when "0010",  -- 2
         X"33" when "0011",  -- 3
         X"34" when "0100",  -- 4
         X"35" when "0101",  -- 5
         X"36" when "0110",  -- 6
         X"37" when "0111",  -- 7
         X"38" when "1000",  -- 8
         X"39" when "1001",  -- 9
         X"00" when others;  -- NULL

end Behavioral;