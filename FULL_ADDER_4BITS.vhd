----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:40:30 09/28/2018 
-- Design Name: 
-- Module Name:    FULL_ADDER_4BITS - Behavioral 
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

entity FULL_ADDER_4BITS is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Cin : in  STD_LOGIC;
           S : out  STD_LOGIC_VECTOR (3 downto 0);
           Cout : out  STD_LOGIC);
end FULL_ADDER_4BITS;

architecture Behavioral of FULL_ADDER_4BITS is

-- 1-bit adder component
component ADDER_1BIT
	port (I0, I1, Cin : in STD_LOGIC;
			S, Cout: out STD_LOGIC);
end component;

-- Signals
signal Cout0, Cout1, Cout2 : STD_LOGIC;

begin

	U0: ADDER_1BIT port map (A(0), B(0), Cin, S(0), Cout0);
	U1: ADDER_1BIT port map (A(1), B(1), Cout0, S(1), Cout1);
	U2: ADDER_1BIT port map (A(2), B(2), Cout1, S(2), Cout2);
	U3: ADDER_1BIT port map (A(3), B(3), Cout2, S(3), Cout);

end Behavioral;