----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:21:30 10/26/2018 
-- Design Name: 
-- Module Name:    BCD_FULLADDER_4BITS - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_FULLADDER_4BITS is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin : in  STD_LOGIC_VECTOR (3 downto 0);
           S : out  STD_LOGIC_VECTOR (3 downto 0);
           Cout : out  STD_LOGIC_VECTOR (3 downto 0));
end BCD_FULLADDER_4BITS;

architecture Behavioral of BCD_FULLADDER_4BITS is

-- 4-bit adder component
component FULL_ADDER_4BITS
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (3 downto 0);
           Cout : out  STD_LOGIC);
end component;

-- 4-bit CMP component
component COMPARADOR_4BITS
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Gout : out  STD_LOGIC;
           Eout : out  STD_LOGIC;
           Sout : out  STD_LOGIC);
end component;

-- Sinais para as somas
signal bitSumCoutAB, bitSumCoutCin, bitSumCoutADD1, bitSumCoutADD2 : STD_LOGIC;
signal bitSumAB, bitSumCin, bitSumADD1, bitSumADD2, bitSumEND : STD_LOGIC_VECTOR (3 downto 0);

-- Sinais para os comparadores
signal CMP1, CMP2, CMP3, CMP4 : STD_LOGIC_VECTOR (2 downto 0);

-- Sinais para as correções
signal O1, O2, O3, O4 : STD_LOGIC_VECTOR (3 downto 0);

begin

	-- Criando todas as somas possíveis
	U1: FULL_ADDER_4BITS port map (A, B, '0', bitSumAB, bitSumCoutAB);
	U2: FULL_ADDER_4BITS port map (bitSumAB, Cin, '0', bitSumCin, bitSumCoutCin);
	U3: FULL_ADDER_4BITS port map (bitSumCin, "0110", '0', bitSumADD1, bitSumCoutADD1);
	U4: FULL_ADDER_4BITS port map (bitSumADD1, "0110", '0', bitSumADD2, bitSumCoutADD2);
	U5: FULL_ADDER_4BITS port map (bitSumADD2, "0110", '0', bitSumEND);
	
	-- Comparando todas as possíveis saídas para saber se a saída estará em BCD
	V1: COMPARADOR_4BITS port map (bitSumCin, "1001", CMP1(0), CMP1(1), CMP1(2));
	V2: COMPARADOR_4BITS port map (bitSumADD1, "1001", CMP2(0), CMP2(1), CMP2(2));
	V3: COMPARADOR_4BITS port map (bitSumADD2, "1001", CMP3(0), CMP3(1), CMP3(2));	
	V4: COMPARADOR_4BITS port map (bitSumEND, "1001", CMP4(0), CMP4(1), CMP4(2));
	
	-- Corrigindo todas as possíveis saídas para BCD
	W1: FULL_ADDER_4BITS port map (bitSumCin, "0110", '0', O1);
	W2: FULL_ADDER_4BITS port map (bitSumADD1, "0110", '0', O2);
	W3: FULL_ADDER_4BITS port map (bitSumADD1, "0110", '0', O3);
	W4: FULL_ADDER_4BITS port map (bitSumADD1, "0110", '0', O4);
	
	-- Fazendo o procedimento de escolha de saída
	process (A, B, Cin, bitSumAB, bitSumCoutAB, bitSumCin, bitSumCoutCin, bitSumADD1,
	bitSumCoutADD1, bitSumADD2, bitSumCoutADD2, bitSumEND, CMP1, CMP2, CMP3, CMP4,
	O1, O2, O3, O4)
	begin
		
		if (bitSumCoutCin = '0') then
			-- Saída = bitSumCin
			if (bitSumCoutAB = '1') then
				if (CMP1 (0) = '1') then
					-- Precisa corrigir (2x)
					S <= O2;
					Cout <= "0010";
				else
					-- Precisa corrigir (1x)
					S <= O1;
					Cout <= "0001";
				end if;
			elsif (CMP1 (0) = '1') then
				-- Precisa corrigir (1x)
					S <= O1;
					Cout <= "0001";
			else
				-- Não precisa corrigir
				S <= bitSumCin;
				Cout <= "0000";
			end if;
		else
			if (bitSumCoutADD1 = '0') then
				-- Saída = bitSumADD1
				if (CMP2 (0) = '1') then
					-- Precisa corrigir
					S <= O2;
					Cout <= "0010";
				else
					-- Não precisa corrigir
					S <= bitSumADD1;
					Cout <= "0001";
				end if;
			else
				if (bitSumCoutADD2 = '0') then
					-- Saída = bitSumADD2
					if (CMP3 (0) = '1') then
						-- Precisa corrigir
						S <= O3;
						Cout <= "0011";
					else
						S <= bitSumADD2;
						Cout <= "0010";
					end if;
				else
					-- Saída = bitSumEND
					if (CMP4 (0) = '1') then
						-- Precisa corrigir
						S <= O4;
						Cout <= "0100";
					else
						-- Não precisa corrigir
						S <= bitSumEND;
						Cout <= "0011";
					end if;
				end if;
			end if;
		end if;
		
	end process;

end Behavioral;

