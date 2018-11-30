-- Código para teste do teclado PS/2
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entidade
entity test_keyboard is
   Port (
      clk, reset: in  std_logic;
      ps2d, ps2c: in  std_logic;
		leds : out STD_LOGIC_VECTOR(7 downto 0)		-- LEDs para indicar tecla pressionada
	);
end test_keyboard;

-- Arquitetura
architecture Behavioral of test_keyboard is

-- Componente do PS/2 RX
component ps2_rx
	port (
      clk, reset: in  std_logic;
      ps2d, ps2c: in  std_logic;
      rx_en: in std_logic;
      rx_done_tick: out  std_logic;
      dout: out std_logic_vector(7 downto 0)
	);
end component;

-- Componente do parser de tecla
component key_parser
	port (
		key_code : in  STD_LOGIC_VECTOR(7 downto 0);
		binary_out : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end component;

-- Signals
signal rx_done : STD_LOGIC;
signal key_out : STD_LOGIC_VECTOR(7 downto 0);
signal binary_out : STD_LOGIC_VECTOR (3 downto 0);

-- Comportamental
begin

	-- Port mapping
	U0: ps2_rx port map (clk, reset, ps2d, ps2c, '1', rx_done, key_out);
	U1: key_parser port map (key_out, binary_out);
	
	-- Process
	process (clk, reset, rx_done)
	begin
	
		-- Clock event
		if (clk'event and clk = '1') then
		
			-- Se o RX tiver recebido o dado
			if (rx_done = '1') then
			
				leds <= "0000" & binary_out;
			
			end if;
		
		end if;
	
	end process;

end Behavioral;
