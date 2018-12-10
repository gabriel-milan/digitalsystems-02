-- Contador

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entidade
entity contador is
	Port (
		load : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		data : in  INTEGER RANGE 10000000 DOWNTO 0;
		output : out  INTEGER RANGE 10000000 DOWNTO 0
	);
	-- 20us = 1000 clocks
end contador;

-- Comportamental
architecture Behavioral of contador is

begin

	count: process (clk, rst)
	variable counting : INTEGER RANGE 10000000 DOWNTO 0;
	begin
		if (rst = '1') then
			counting := 0;
		elsif (clk'event and clk = '1') then
			if (load = '1') then
				counting := data;
			else
				if (counting >= 10000000) then
					counting := 0;
				else
					counting := counting + 1;
				end if;
			end if;
		end if;
		output <= counting;
	end process;
end Behavioral;

