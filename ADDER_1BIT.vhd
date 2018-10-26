----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:34:20 09/28/2018 
-- Design Name: 
-- Module Name:    ADDER_1BIT - Behavioral 
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

entity ADDER_1BIT is
    Port ( I0 : in  STD_LOGIC;
           I1 : in  STD_LOGIC;
           Cin : in  STD_LOGIC;
           S : out  STD_LOGIC;
           Cout : out  STD_LOGIC);
end ADDER_1BIT;

architecture Behavioral of ADDER_1BIT is

begin

	S <= (I0 xor I1) xor Cin;
	Cout <= ((I0 and I1) or (I0 and Cin)) or (I1 and Cin);

end Behavioral;
