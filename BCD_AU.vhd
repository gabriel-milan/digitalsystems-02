library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_AU is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
			  OP : in STD_LOGIC;
			  S : out  STD_LOGIC_VECTOR (31 downto 0));
end BCD_AU;

architecture Behavioral of BCD_AU is

-- Componente do somador
component BCD_4DIGIT_ADDER
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           Cin : in  STD_LOGIC_VECTOR (3 downto 0);
           S : out  STD_LOGIC_VECTOR (31 downto 0));
end component;

-- Componente do multiplicador
--
-- TODO
--

-- Sinais
signal resultADD, resultMUL : STD_LOGIC_VECTOR (31 downto 0);

begin

	U1: BCD_4DIGIT_ADDER port map (A, B, "0000", resultADD);

	process (OP, resultADD, resultMUL)
	begin
		if (OP = '1') then
			S <= resultADD;
		else
			S <= resultMUL;
		end if;
	end process;

end Behavioral;

