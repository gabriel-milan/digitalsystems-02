----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:35:56 09/28/2018 
-- Design Name: 
-- Module Name:    COMPARADOR_1BIT - Behavioral 
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

entity COMPARADOR_1BIT is
    Port ( Gin : in  STD_LOGIC;
           Ein : in  STD_LOGIC;
           Sin : in  STD_LOGIC;
           A : in  STD_LOGIC;
           B : in  STD_LOGIC;
           Gout : out  STD_LOGIC;
           Eout : out  STD_LOGIC;
           Sout : out  STD_LOGIC);
end COMPARADOR_1BIT;

architecture Behavioral of COMPARADOR_1BIT is

signal equal : STD_LOGIC;

begin

	equal <= A xnor B;

	process (equal, Gin, Ein, Sin, A, B)
	begin
		if (equal = '1') then
				Gout <= Gin;
				Eout <= Ein;
				Sout <= Sin;
		else
			Gout <= A and (Not B);
			Eout <= '0';
			Sout <= B and (Not A);
		end if;
	end process;

end Behavioral;
