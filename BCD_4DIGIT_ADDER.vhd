library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_4DIGIT_ADDER is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           Cin : in  STD_LOGIC_VECTOR (3 downto 0);
           S : out  STD_LOGIC_VECTOR (31 downto 0));
end BCD_4DIGIT_ADDER;

architecture Behavioral of BCD_4DIGIT_ADDER is

-- BCD Full Adder component
component BCD_FULLADDER_4BITS
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin : in  STD_LOGIC_VECTOR (3 downto 0);
           S : out  STD_LOGIC_VECTOR (3 downto 0);
           Cout : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

-- Sinais
signal Cout1, Cout2, Cout3 : STD_LOGIC_VECTOR (3 downto 0);

begin

	-- Criando somas parciais
	U1: BCD_FULLADDER_4BITS port map (A(3 downto 0), B (3 downto 0), Cin, S(3 downto 0), Cout1);
	U2: BCD_FULLADDER_4BITS port map (A(7 downto 4), B (7 downto 4), Cin, S(7 downto 4), Cout2);
	U3: BCD_FULLADDER_4BITS port map (A(11 downto 8), B (11 downto 8), Cin, S(11 downto 8), Cout3);
	U4: BCD_FULLADDER_4BITS port map (A(15 downto 12), B (15 downto 12), Cin, S(15 downto 12), S(19 downto 16));

end Behavioral;

