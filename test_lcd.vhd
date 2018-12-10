-- Código para teste do LCD
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entidade
entity test_lcd is
   Port (
		clk, rst, ps2d, ps2c: in std_logic;
		LCD_DB: out std_logic_vector (7 downto 0);
		RS, RW, OE: out std_logic
		--leds: out std_logic_vector (7 downto 0)
	);
end test_lcd;

-- Arquitetura
architecture Behavioral of test_lcd is

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

-- Componente para comunicação com LCD
component lcd
	port (
	   clk:in std_logic;				--GCLK2
	   rst:in std_logic;				--BTN
		in_Char: in std_logic_vector (7 downto 0);
		in_strobe: in std_logic;
		LCD_DB: out std_logic_vector(7 downto 0);		--DB( 7 through 0)
      RS:out std_logic;  			--WE
      RW:out std_logic;				--ADR(0)
	   OE:out std_logic				--OE
	);
end component;

-- Componente do parser ASCII
component binary_parser
	port (
		binary_code : in  STD_LOGIC_VECTOR(3 downto 0);
		ascii_out : out  STD_LOGIC_VECTOR (7 downto 0)
	);
end component;

-- Componente do contador
component contador
	port (
		load : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		data : in  INTEGER RANGE 10000000 DOWNTO 0;
		output : out  INTEGER RANGE 10000000 DOWNTO 0
	);
	-- 20us = 1000 clocks
end component;

-- Componente do contador
component contador_lcd_strobe
	port (
		load : in  STD_LOGIC;
		clk : in  STD_LOGIC;
		rst : in  STD_LOGIC;
		data : in  INTEGER RANGE 100000 DOWNTO 0;
		output : out  INTEGER RANGE 100000 DOWNTO 0
	);
	-- 20us = 1000 clocks
end component;

-- Tipos de estados
type stateT is (reset, idle, delayState, writeLCD);

-- Signals
signal w_LCD : STD_LOGIC;
signal writeDelayStart : STD_LOGIC;
signal rx_done : STD_LOGIC;
signal key_out, ascii_out : STD_LOGIC_VECTOR(7 downto 0);
signal binary_out : STD_LOGIC_VECTOR (3 downto 0);
signal state, lastState : stateT;
signal data, outCounter : INTEGER RANGE 10000000 DOWNTO 0;
signal dataStrobe, outCounterStrobe : INTEGER RANGE 100000 DOWNTO 0;

-- Comportamental
begin

	-- Port mapping
	U0: ps2_rx port map (clk, rst, ps2d, ps2c, '1', rx_done, key_out);
	U1: key_parser port map (key_out, binary_out);
	U2: binary_parser port map (binary_out, ascii_out);
	U3: lcd port map (clk, rst, ascii_out, w_LCD, LCD_DB, RS, RW, OE);
	U4: contador port map (writeDelayStart, clk, rst, data, outCounter);
	U5: contador_lcd_strobe port map (writeDelayStart, clk, rst, dataStrobe, outCounterStrobe);
	
	-- TODO: MAQUINA DE ESTADOS PARA TRIGGAR A ESCRITA NO LCD
	process (clk, rst, rx_done)
	begin
	
		if rst = '1' then
			state <= reset;
		elsif (clk'event and clk = '1') then
			case state is
			
				when reset =>
					state <= idle;
					lastState <= reset;
				
				when idle =>
					w_LCD <= '0';
					writeDelayStart <= '1';
					if rx_done = '1' then
						state <= delayState;
					end if;
					lastState <= idle;

				when delayState =>
					writeDelayStart <= '0';
					if (lastState = idle) then
						if (outCounter = 0) then
							state <= writeLCD;
						end if;
					elsif (lastState = writeLCD) then
						if (outCounterStrobe = 0) then
							state <= idle;
						end if;
					end if;

				when writeLCD =>
					w_LCD <= '1';
					state <= delayState;
					lastState <= writeLCD;
			
			end case;
		end if;
	
	end process;
	
	-- TODO: VERIFICAR SE VAI RETIRAR FLAG DE ESCRITA COMPLETA NO COMPONENTE LCD

end Behavioral;

