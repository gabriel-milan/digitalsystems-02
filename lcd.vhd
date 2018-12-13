-- LCD
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entidade
entity lcd is
    Port ( 
	   clk:in std_logic;				--GCLK2
	   rst:in std_logic;				--BTN
		in_Char: in std_logic_vector (7 downto 0);
		in_strobe: in std_logic;
		LCD_DB: out std_logic_vector(7 downto 0);		--DB( 7 through 0)
      RS:out std_logic;  			--WE
      RW:out std_logic;				--ADR(0)
	   OE:out std_logic				--OE
	);
end lcd;

-- Arquitetura
architecture Behavioral of lcd is
			    
	-- Máquina de estados para controlar o LCD
	type mstate is (					  
		stFunctionSet,		 			-- Estados de inicialização
		stDisplayCtrlSet,
		stDisplayClear,
		stPowerOn_Delay,  			-- Estados de delay
		stFunctionSet_Delay,
		stDisplayCtrlSet_Delay, 	
		stDisplayClear_Delay,
		stInitDne,						-- Estado de inicialização completa
		stActWr,							-- Estado para iniciar a escrita de um caracter
		stCharDelay						-- Delay de escrita
	);

	--Máquina de estados para controlar a escrita
	type wstate is (
		stRW,							-- Seta seletor de registrador (dados ou comandos) e RW (escrita ou leitura)
		stEnable,					-- Seta o enable
		stIdle						-- Escreve os dados presentes no DB (Data Bus)
	);
	

------------------------------------------------------------------
--  Signal Declarations and Constants
------------------------------------------------------------------
	--These constants are used to initialize the LCD pannel.

	--FunctionSet: 3C = 00111100
		--Bit 0 and 1 are arbitrary
		--Bit 2:  Displays font type(0=5x8, 1=5x11)
		--Bit 3:  Numbers of display lines (0=1, 1=2)
		--Bit 4:  Data length (0=4 bit, 1=8 bit)
		--Bit 5-7 are set
	--DisplayCtrlSet:
		--Bit 0:  Blinking cursor control (0=off, 1=on)
		--Bit 1:  Cursor (0=off, 1=on)
		--Bit 2:  Display (0=off, 1=on)
		--Bit 3-7 are set
	--DisplayClear:
		--Bit 1-7 are set	
	signal clkCount:std_logic_vector(5 downto 0);
	signal activateW:std_logic:= '0';		    			--Activate Write sequence
	signal count:std_logic_vector (16 downto 0):= "00000000000000000";	--15 bit count variable for timing delays
	signal delayOK:std_logic:= '0';						--High when count has reached the right delay time
	signal OneUSClk:std_logic;						--Signal is treated as a 1 MHz clock	
	signal stCur:mstate:= stPowerOn_Delay;					--LCD control state machine
	signal stNext:mstate;			  	
	signal stCurW:wstate:= stIdle; 						--Write control state machine
	signal stNextW:wstate;
	signal writeDone:std_logic:= '0';					--Command set finish

	type LCD_CMDS_T is array(integer range <>) of std_logic_vector(9 downto 0);
	constant LCD_CMDS : LCD_CMDS_T := ( 0 => "00"&X"3C",			--Function Set (Tipo da fonte 5x8, 2 linhas do LCD, dados de 8 bits)
					    1 => "00"&X"0C",										--Display ON, Cursor OFF, Piscar OFF
					    2 => "00"&X"01",										--Limpa Display
					    3 => "00"&X"02"); 									--Retorna o cursor à primeira casa

	-- Ponteiro para percorrer o array de comandos de inicialização												
	signal lcd_cmd_ptr : integer range 0 to LCD_CMDS'HIGH + 1 := 0;
begin
 	
	--  Divide o período do clock para que oneUSClk tenha período de 1 microssegundo
	process (clk, oneUSClk)
    		begin
			if (clk = '1' and clk'event) then
				clkCount <= clkCount + 1;
			end if;
		end process;
	oneUSClk <= clkCount(5);
	
	--  Esse processo faz o incremento da variável "count" até que o delayOK seja '1'
	process (oneUSClk, delayOK)
		begin
			if (oneUSClk = '1' and oneUSClk'event) then
				if delayOK = '1' then
					count <= "00000000000000000";
				else
					count <= count + 1;
				end if;
			end if;
		end process;

	-- writeDone vai para '1' quando o ponteiro percorre todo o array de comandos de inicialização
	writeDone <= '1' when (lcd_cmd_ptr = LCD_CMDS'HIGH) 
		else '0';

	-- Esse processo incrementa, reseta ou mantém o valor do ponteiro dependendo do próximo estado e do estado atual
	process (lcd_cmd_ptr, oneUSClk)
   		begin
			if (oneUSClk = '1' and oneUSClk'event) then
				-- Se próx. estado é o índice 1 ou 2 e a inicialização ainda não foi terminada, incrementa
				if ((stNext = stDisplayCtrlSet or stNext = stDisplayClear) and writeDone = '0') then 
					lcd_cmd_ptr <= lcd_cmd_ptr + 1;
				-- Se o estado atual é o primeiro ou o próximo é o primeiro, zera o ponteiro
				elsif stCur = stPowerOn_Delay or stNext = stPowerOn_Delay then
					lcd_cmd_ptr <= 0;
				-- Em qualquer outro caso, mantém o valor do ponteiro
				else
					lcd_cmd_ptr <= lcd_cmd_ptr;
				end if;
			end if;
		end process;
	
	--  Determina o valor de delay para cada estado
	delayOK <= '1' when ((stCur = stPowerOn_Delay and count = "00100111001010010") or	-- PowerOn: 20ms  
					(stCur = stFunctionSet_Delay and count = "00000000000110010") or			-- FunctionSet: 50us
					(stCur = stDisplayCtrlSet_Delay and count = "00000000000110010") or		-- DisplayCtrlSet: 50us
					(stCur = stDisplayClear_Delay and count = "00000011001000000") or			-- DisplayClear: 1,6ms
					(stCur = stCharDelay and count = "11111111111111111"))						-- DelayEscrita: 131,07ms
		else	'0';
  	
	--	Process para reset síncrono ou mudança de estado baseado em stCur
	process (oneUSClk, rst)
		begin
			if oneUSClk = '1' and oneUSClk'Event then
				if rst = '1' then
					stCur <= stPowerOn_Delay;
				else
					stCur <= stNext;
				end if;
			end if;
		end process;
	
	--  Process para fazer o sequenciamento da inicialização e manter o loop de escrita
	process (stCur, delayOK, writeDone, lcd_cmd_ptr)
		begin   
		
			case stCur is
			
				--  Para a máquina por 20ms para inicialização correta
				when stPowerOn_Delay =>
					if delayOK = '1' then
						stNext <= stFunctionSet;	-- Quando delay estiver ok, vai para FunctionSet
					else
						stNext <= stPowerOn_Delay;
					end if;
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';

				-- Faz a configuração do LCD conforme abaixo
				-- Dados de 8 bits, 2 linhas, Fonte 5x8.
				when stFunctionSet =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9); 					-- Aqui será sempre 0
					RW <= LCD_CMDS(lcd_cmd_ptr)(8); 					-- Aqui será sempre 0
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0); -- X"3C"
					activateW <= '1';										-- Ativa escrita
					stNext <= stFunctionSet_Delay;					-- Vai para o delay
				
				-- Realiza o delay de 50ms e vai para próximo estado
				when stFunctionSet_Delay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					if delayOK = '1' then
						stNext <= stDisplayCtrlSet;	-- Quando delay estiver ok, vai para DisplayCtrlSet
					else
						stNext <= stFunctionSet_Delay;
					end if;
				
				--	Faz o controle do display conforme abaixo
				-- Display ON,  Cursor OFF, Cursor piscante OFF.
				when stDisplayCtrlSet =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9); 					-- Aqui será sempre 0
					RW <= LCD_CMDS(lcd_cmd_ptr)(8); 					-- Aqui será sempre 0
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0); -- X"0C"
					activateW <= '1';										-- Ativa escrita
					stNext <= stDisplayCtrlSet_Delay;				-- Vai para o delay

				--	Realiza o delay de 50ms e vai para o próximo estado
				when stDisplayCtrlSet_Delay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					if delayOK = '1' then
						stNext <= stDisplayClear;	-- Quando o delay estiver ok, vai para o DisplayClear
					else
						stNext <= stDisplayCtrlSet_Delay;
					end if;
				
				--	Faz a limpeza do display
				when stDisplayClear	=>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9); 					-- Aqui será sempre 0
					RW <= LCD_CMDS(lcd_cmd_ptr)(8); 					-- Aqui será sempre 0
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0); -- X"01"
					activateW <= '1';										-- Ativa escrita
					stNext <= stDisplayClear_Delay;					-- Vai para o delay

				--	Realiza o delay de 1,6ms e entra no loop de escrita de caracteres
				when stDisplayClear_Delay =>
					RS <= LCD_CMDS(lcd_cmd_ptr)(9);
					RW <= LCD_CMDS(lcd_cmd_ptr)(8);
					LCD_DB <= LCD_CMDS(lcd_cmd_ptr)(7 downto 0);
					activateW <= '0';
					if delayOK = '1' then
						stNext <= stInitDne;	-- Quando o delay estiver ok, finaliza a inicialização
					else
						stNext <= stDisplayClear_Delay;
					end if;
				
				-- Estado de inicialização completa e também início do looping de escrita
				when stInitDne =>		
					RS <= '1';	-- Demonstra que usarei agora o registrador de dados
					RW <= '0';	-- Em modo de escrita
					LCD_DB <= in_Char;	-- Joga no barramento de dados o input desejado
					activateW <= '0';
					if in_strobe = '1' then	-- Quando o strobe estiver em 1
						stNext <= stActWr;	-- Inicializa processo de escrita
					else
						stNext <= stInitDne;
					end if;

				-- Estado para iniciar processo de escrita
				when stActWr =>		
					RS <= '1';
					RW <= '0';
					LCD_DB <= in_Char;
					activateW <= '1';	-- Ativa escrita
					stNext <= stCharDelay;	-- Vai para o delay
					
				--	Realiza o delay previamente definido para escrita e depois retorna ao estado InitDne
				when stCharDelay =>
					RS <= '1';
					RW <= '0';
					LCD_DB <= in_Char;
					activateW <= '0';					
					if delayOK = '1' then
						stNext <= stInitDne;	-- Quando o delay estiver ok, reteorna a InitDne
					else
						stNext <= stCharDelay;
					end if;
			end case;
		
		end process;					
								   
 	--	Processo para controlar a máquina de estados de escrita e reset síncrono
	process (oneUSClk, rst)
		begin
			if oneUSClk = '1' and oneUSClk'Event then
				if rst = '1' then
					stCurW <= stIdle;
				else
					stCurW <= stNextW;
				end if;
			end if;
		end process;

	--	Máquina de estados para escrita no LCD
	process (stCurW, activateW)
		begin   
		
			case stCurW is
				-- Habilita o LCD para escrita
				when stRw =>
					OE <= '0';
					stNextW <= stEnable;
				
				-- Mantém o enable alto por mais um período de clock para garantir a estabilidade dos dados
				when stEnable => 
					OE <= '0';
					stNextW <= stIdle;
				
				--	Aguarda comando de habilitação de escrita da outra máquina de estados
				when stIdle =>
					OE <= '1';
					if activateW = '1' then
						stNextW <= stRw;
					else
						stNextW <= stIdle;
					end if;
				end case;
		end process;
				
end Behavioral;