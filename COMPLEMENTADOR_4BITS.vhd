----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:58:31 10/16/2018 
-- Design Name: 
-- Module Name:    COMPLEMENTADOR_4BITS - Behavioral 
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

entity COMPLEMENTADOR_4BITS is
    Port ( I : in  STD_LOGIC_VECTOR (3 downto 0);
           K : in  STD_LOGIC;
           Z : out  STD_LOGIC_VECTOR (3 downto 0));
end COMPLEMENTADOR_4BITS;

architecture Behavioral of COMPLEMENTADOR_4BITS is

begin
	process (I, K)
	begin
		if (K = '1') then
			Z <= not I;
		else
			Z <= I;
		end if;
	end process;
end Behavioral;
