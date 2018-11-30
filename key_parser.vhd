-- Key code parser
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity
entity key_parser is
	Port (
		key_code : in  STD_LOGIC_VECTOR(7 downto 0);
		binary_out : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end key_parser;

-- Architecture
architecture Behavioral of key_parser is

-- Behavioral
begin

   with key_code select
      binary_out <=
         "0000" when "01000101",  -- 0
         "0001" when "00010110",  -- 1
         "0010" when "00011110",  -- 2
         "0011" when "00100110",  -- 3
         "0100" when "00100101",  -- 4
         "0101" when "00101110",  -- 5
         "0110" when "00110110",  -- 6
         "0111" when "00111101",  -- 7
         "1000" when "00111110",  -- 8
         "1001" when "01000110",  -- 9
         "1111" when others;      -- -1

end Behavioral;