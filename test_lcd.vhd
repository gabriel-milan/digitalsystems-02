-- Código para teste do LCD
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entidade
entity BCD_OPERATOR is
   Port (
		clk, rst, ps2d, ps2c: in std_logic;
		LCD_DB: out std_logic_vector (7 downto 0);
		OP : in std_logic;
		RS, RW, OE: out std_logic
		--leds: out std_logic_vector (7 downto 0)
	);
end BCD_OPERATOR;

-- Arquitetura
architecture Behavioral of BCD_OPERATOR is

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

-- Componente da unidade aritmética
component BCD_AU
    port (
		A : in  STD_LOGIC_VECTOR (15 downto 0);
		B : in  STD_LOGIC_VECTOR (15 downto 0);
		OP : in STD_LOGIC;
		S : out  STD_LOGIC_VECTOR (31 downto 0)
	);
end component;

-- Declarações de tipos
type stateT is (reset, idle, delayState, writeLCD, computeState);
type showStateT is (idle, delayState, writeLCD, endState);
type numberT is array(3 downto 0) of std_logic_vector(3 downto 0);
type resultT is array(7 downto 0) of std_logic_vector(3 downto 0);

-- Signals
signal w_LCD : STD_LOGIC;
signal writeDelayStart : STD_LOGIC;
signal rx_done : STD_LOGIC;
signal key_out, ascii_out, inChar : STD_LOGIC_VECTOR(7 downto 0);
signal binary_out, aux_vector : STD_LOGIC_VECTOR (3 downto 0);
signal state, lastState : stateT;
signal stateShow : showStateT;
signal data, outCounter : INTEGER RANGE 10000000 DOWNTO 0;
signal dataStrobe, outCounterStrobe : INTEGER RANGE 100000 DOWNTO 0;
signal doneInput : STD_LOGIC;
signal result : resultT;
signal ascii_result : STD_LOGIC_VECTOR (7 downto 0);
signal A, B : STD_LOGIC_VECTOR (15 downto 0);
signal S : STD_LOGIC_VECTOR (31 downto 0);

-- Comportamental
begin

	-- Port mapping
	U0: ps2_rx port map (clk, rst, ps2d, ps2c, '1', rx_done, key_out);
	U1: key_parser port map (key_out, binary_out);
	U2: binary_parser port map (binary_out, ascii_out);
	U3: lcd port map (clk, rst, inChar, w_LCD, LCD_DB, RS, RW, OE);
	U4: contador port map (writeDelayStart, clk, rst, data, outCounter);
	U5: contador_lcd_strobe port map (writeDelayStart, clk, rst, dataStrobe, outCounterStrobe);
	U6: binary_parser port map (aux_vector, ascii_result);
	U7: BCD_AU port map (A, B, OP, S);
	
	process (clk, rst, rx_done, ascii_out, binary_out)
	variable inputCharCount : INTEGER RANGE 0 to 4 := 0;
	variable inputCount : INTEGER RANGE 0 to 2 := 0;
	variable remainingPrint : INTEGER RANGE 8 downto 0 := 8;
	variable firstNumber: numberT := ( 0 => "0000", 1 => "0000", 2 => "0000", 3 => "0000" );
	variable secondNumber: numberT := ( 0 => "0000", 1 => "0000", 2 => "0000", 3 => "0000" );
	begin
	
		if rst = '1' then
			state <= reset;
			stateShow <= idle;
		elsif (clk'event and clk = '1') then
		
			-- MAQUINA DE ESTADOS PARA TRIGGAR A ESCRITA NO LCD DO TECLADO
			case state is
				when reset =>
					inChar <= X"00";
					doneInput <= '0';
					inputCharCount := 0;
					inputCount := 0;
					remainingPrint := 8;
					state <= idle;
					lastState <= reset;
					aux_vector <= "0000";
				when idle =>
					w_LCD <= '0';
					writeDelayStart <= '1';
					if (rx_done = '1') and (inputCharCount < 4) then
						if not ascii_out = X"00" then
							state <= delayState;
						elsif (ascii_out = X"0D") then
							inputCount := inputCount + 1;
						end if;
					end if;
					if (inputCount >= 2) then
						state <= computeState;
					end if;
					lastState <= idle;
				when delayState =>
					writeDelayStart <= '0';
					if (lastState = idle) then
						inputCharCount := inputCharCount + 1;
						inChar <= ascii_out;
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
					-- Store number in an array, based on the inputCount
					if (inputCount = 0) then
						firstNumber(inputCharCount - 1) := binary_out;
					elsif (inputCount = 1) then
						secondNumber(inputCharCount - 1) := binary_out;
					end if;
					state <= delayState;
					lastState <= writeLCD;
				when computeState =>
					doneInput <= '1';
					A <= firstNumber(3) & firstNumber(2) & firstNumber(1) & firstNumber(0);
					B <= secondNumber(3) & secondNumber(2) & secondNumber(1) & secondNumber(0);
					S <= result(7) & result(6) & result (5) & result(4) & result(3) & result(2) & result(1) & result(0);
					state <= computeState;
			end case;
			
			case stateShow is
				when idle =>
					if (doneInput = '1') then
						writeDelayStart <= '1';
						w_LCD <= '0';
						-- Verificar quantos caracteres faltam escrever
						-- Se faltar ainda, escreve o próximo índice
						if (remainingPrint > 0) then
							aux_vector <= result(remainingPrint - 1);
							inChar <= ascii_result;
							stateShow <= writeLCD;
						-- Se não faltar nada pra escrever, ir para o final
						else
							stateShow <= endState;
						end if;
					end if;
				when delayState =>
					writeDelayStart <= '0';
					if (outCounterStrobe = 0) then
						state <= idle;
					end if;
				when writeLCD =>
					w_LCD <= '1';
					state <= delayState;
				when endState =>
					stateShow <= endState;
			end case;
			
		end if;
	
	end process;
	
end Behavioral;

