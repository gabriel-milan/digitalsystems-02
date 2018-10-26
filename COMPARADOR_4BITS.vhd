----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:41:56 09/28/2018 
-- Design Name: 
-- Module Name:    COMPARADOR_4BITS - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity COMPARADOR_4BITS is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Gout : out  STD_LOGIC;
           Eout : out  STD_LOGIC;
           Sout : out  STD_LOGIC);
end COMPARADOR_4BITS;

architecture Behavioral of COMPARADOR_4BITS is

-- Incluindo comparador 1 bit
component COMPARADOR_1BIT
	port (Gin, Ein, Sin, A, B: in STD_LOGIC;
			Gout, Eout, Sout: out STD_LOGIC);
end component;

-- Sinais dos comparadores intermediarios
signal outC1, outC2, outC3 : STD_LOGIC_VECTOR (2 downto 0);

begin

	-- Comparando o LSB
	U1: COMPARADOR_1BIT port map ('0', '1', '0', A(0), B(0), outC1(0), outC1(1), outC1(2));
	U2: COMPARADOR_1BIT port map (outC1(0), outC1(1), outC1(2), A(1), B(1), outC2(0), outC2(1), outC2(2));
	U3: COMPARADOR_1BIT port map (outC2(0), outC2(1), outC2(2), A(2), B(2), outC3(0), outC3(1), outC3(2));
	U4: COMPARADOR_1BIT port map (outC3(0), outC3(1), outC3(2), A(3), B(3), Gout, Eout, Sout);

end Behavioral;
