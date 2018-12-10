-- Contador

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entidade
entity contador_lcd_strobe is
	Port (
		load : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		data : in  INTEGER RANGE 100000 DOWNTO 0;
		output : out  INTEGER RANGE 100000 DOWNTO 0
	);
	-- 20us = 1000 clocks
end contador_lcd_strobe;

-- Comportamental
architecture Behavioral of contador_lcd_strobe is

begin

	count: process (clk, rst)
	variable counting : INTEGER RANGE 100000 DOWNTO 0;
	begin
		if (rst = '1') then
			counting := 0;
		elsif (clk'event and clk = '1') then
			if (load = '1') then
				counting := data;
			else
				if (counting >= 100000) then
					counting := 0;
				else
					counting := counting + 1;
				end if;
			end if;
		end if;
		output <= counting;
	end process;
end Behavioral;

