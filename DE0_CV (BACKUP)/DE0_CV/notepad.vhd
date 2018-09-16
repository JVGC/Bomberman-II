library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY notepad IS

	PORT(
		clkvideo, clk, reset  : IN	STD_LOGIC;		
		videoflag	: out std_LOGIC;
		vga_pos		: out STD_LOGIC_VECTOR(15 downto 0);
		vga_char		: out STD_LOGIC_VECTOR(15 downto 0);
		
		key			: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0)	-- teclado
		
		);

END  notepad ;

ARCHITECTURE a OF notepad IS

	-- Escreve na tela
	SIGNAL VIDEOE      : STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Contador de tempo

	-- MAN
	SIGNAL MANPOS   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL MANPOSA  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL MANCHAR  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL MANCOR   : STD_LOGIC_VECTOR(3 DOWNTO 0);

	-- fantasma 1
	SIGNAL F1POS     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL F1POSA    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL F1CHAR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL F1COR     : STD_LOGIC_VECTOR(3 DOWNTO 0);

	-- FANTASMA 2
	SIGNAL F2POS     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL F2POSA    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL F2CHAR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL F2COR     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	-- BOMBA
	SIGNAL BOMBAPOS     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BOMBAPOSA    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BOMBACHAR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL BOMBACOR     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL PLANTOU      : STD_LOGIC;
	
	-- PAREDE
	SIGNAL PPOS     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL PCHAR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL PCOR     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
	--Delay do MAN
	SIGNAL DELAY1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--Delay do fantasma 1
	SIGNAL DELAY2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--Delay do fantasma 2
	SIGNAL DELAY3      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- Delay da bomba
	SIGNAL DELAY4      : STD_LOGIC_VECTOR(31 DOWNTO 0);	
	
	SIGNAL MANESTADO    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	--Estados do fantasma 1
	SIGNAL F1_ESTADO    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	--Estados do fantasma 2
	SIGNAL F2_ESTADO    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Estados da bomba
	SIGNAL BOMBA_ESTADO    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
BEGIN

-- MAN
PROCESS (clk, reset)
	
	BEGIN
		
	IF RESET = '1' THEN
		MANCHAR <= "00000001";
		MANCOR <= "1100"; -- 1100 azul
		MANPOS <= x"0064";
		DELAY1 <= x"00000000";
		MANESTADO <= x"00";
		
	ELSIF ((clk'event) and (clk = '1')) THEN

		CASE MANESTADO IS
			WHEN x"00" => -- Estado movimenta o cara segundo Teclado
			
				CASE key IS
					WHEN x"73" => -- (S) BAIXO
						IF (MANPOS < 1159) THEN   -- nao esta' na ultima linha
							MANPOS <= MANPOS + x"28";  -- MANPOS + 40
						END IF;
					WHEN x"77" => -- (W) CIMA
						IF (MANPOS > 39) THEN   -- nao esta' na primeira linha
							MANPOS <= MANPOS - x"28";  --MANPOS - 40
						END IF;
					WHEN x"61" => -- (A) ESQUERDA
						IF (NOT((conv_integer(MANPOS) MOD 40) = 0)) THEN   -- nao esta' na extrema esquerda
							MANPOS <= MANPOS - x"01";  -- MANPOS - 1
						END IF;
					WHEN x"64" => -- (D) DIREITA
						IF (NOT((conv_integer(MANPOS) MOD 40) = 39)) THEN   -- nao esta' na extrema direita
							MANPOS <= MANPOS + x"01";  -- MANPOS + 1
						END IF;
					WHEN OTHERS =>
				END CASE;
				MANESTADO <= x"01";

			
			WHEN x"01" => -- Delay para movimentar o cara
			 
				IF DELAY1 >= x"00000FFF" THEN
					DELAY1 <= x"00000000";
					MANESTADO <= x"00";
				ELSE
					DELAY1 <= DELAY1 + x"01";
				END IF;
				
			WHEN OTHERS =>
		END CASE;
	END IF;

END PROCESS;

-- Fantasma 1
PROCESS (clk, reset)

BEGIN
		
	IF RESET = '1' THEN
		F1CHAR <= "00000010";
		F1COR <= "1101"; -- 1001 Vermelho
		F1POS <= x"005E";	
		DELAY2 <= x"00000000";
		F1_ESTADO <= x"00";
		
	ELSIF ((clk'event) and (clk = '1')) THEN

				CASE F1_ESTADO IS
					WHEN x"00" =>
						IF(F1POS < 1199) THEN
							F1POS <= F1POS + x"28"; -- descendo
							F1_ESTADO <= x"F1"; -- delay
						ELSE
							F1_ESTADO <= x"01";
						end if;
						
					WHEN x"01" => 
						IF(NOT(conv_integer(F1POS) mod 40 = 0)) THEN
							F1POS <= F1POS - x"01"; -- indo para a esquerda
							F1_ESTADO <= x"F2";
						ELSE
							F1_ESTADO <= x"02";
						end if;

					WHEN x"02" => 
						IF(F1POS > 39) THEN
							F1POS <= F1POS - x"28"; -- subindo
							F1_ESTADO <= x"F3";
						ELSE 
							F1_ESTADO <= x"03";
						end if;
	
					WHEN x"03" => 
						IF(NOT(conv_integer(F1POS) mod 40 = 39)) THEN
							F1POS <= F1POS + x"01"; -- indo para a direita
							F1_ESTADO <= x"F4";
						ELSE 
							F1_ESTADO <= x"00";
						end if;
							
					WHEN x"F1" =>  -- Delay do fantasma 1 quando esta descendo
			
						IF DELAY2 >= x"00000FFF" THEN 
							DELAY2 <= x"00000000";
							F1_ESTADO <= x"00";
						ELSE
							DELAY2 <= DELAY2 + x"01";
						END IF;
					
					WHEN x"F2" =>  -- Delay do fantasma 1 quando esta indo para a esquerda
			
						IF DELAY2 >= x"00000FFF" THEN 
							DELAY2 <= x"00000000";
							F1_ESTADO <= x"01";
						ELSE
							DELAY2 <= DELAY2 + x"01";
						END IF;
					
					WHEN x"F3" =>  -- Delay do fantasma 1 quando esta subindo
			
						IF DELAY2 >= x"00000FFF" THEN 
							DELAY2 <= x"00000000";
							F1_ESTADO <= x"02";
						ELSE
							DELAY2 <= DELAY2 + x"01";
						END IF;
					
					WHEN x"F4" =>  -- Delay do fantasma 1 quando esta indo para a direita
			
						IF DELAY2 >= x"00000FFF" THEN 
							DELAY2 <= x"00000000";
							F1_ESTADO <= x"03";
						ELSE
							DELAY2 <= DELAY2 + x"01";
						END IF;
					
						WHEN OTHERS =>
						F1_ESTADO <= x"00";
					
				END CASE;
				

	END IF;
	
END PROCESS;

-- Fantasma 2
PROCESS (clk, reset)

BEGIN
		
	IF RESET = '1' THEN
		F2CHAR <= "00000010";
		F2COR <= "1101"; -- 1001 Vermelho
		F2POS <= x"005E";	
		DELAY3 <= x"00000000";
		F2_ESTADO <= x"00";
		
	ELSIF ((clk'event) and (clk = '1')) THEN

				CASE F2_ESTADO IS
					WHEN x"00" => 
						IF(F2POS > 79) THEN
							F2POS <= F2POS - x"28"; -- Subindo
							F2_ESTADO <= x"F1"; -- Delay
						ELSE 
							F2_ESTADO <= x"01";
						END IF;
					
					WHEN x"01" => 
						IF(NOT(conv_integer(F2POS) mod 40 = 1)) THEN
							F2POS <= F2POS - x"01"; -- indo para a esquerda
							F2_ESTADO <= x"F2";
						ELSE
							F2_ESTADO <= x"02";
						end if;
						
					WHEN x"02" =>
						IF(F2POS < 1120) THEN
							F2POS <= F2POS + x"28"; -- Descendo
							F2_ESTADO <= x"F3"; 
						ELSE
							F2_ESTADO <= x"03";
						end if;
	
					WHEN x"03" => 
						IF(NOT(conv_integer(F2POS) mod 40 = 38)) THEN
							F2POS <= F2POS + x"01"; -- indo para a direita
							F2_ESTADO <= x"F4";
						ELSE 
							F2_ESTADO <= x"00";
						end if;
							
					WHEN x"F1" =>  -- Delay do fantasma 1 quando esta subindo
			
						IF DELAY3 >= x"00000FFF" THEN 
							DELAY3 <= x"00000000";
							F2_ESTADO <= x"00";
						ELSE
							DELAY3 <= DELAY3 + x"01";
						END IF;
					
					WHEN x"F2" =>  -- Delay do fantasma 1 quando esta indo para a esquerda
			
						IF DELAY3 >= x"00000FFF" THEN 
							DELAY3 <= x"00000000";
							F2_ESTADO <= x"01";
						ELSE
							DELAY3 <= DELAY3 + x"01";
						END IF;
					
					WHEN x"F3" =>  -- Delay do fantasma 1 quando esta descendo
			
						IF DELAY3 >= x"00000FFF" THEN 
							DELAY3 <= x"00000000";
							F2_ESTADO <= x"02";
						ELSE
							DELAY3 <= DELAY3 + x"01";
						END IF;
					
					WHEN x"F4" =>  -- Delay do fantasma 1 quando esta indo para a direita
			
						IF DELAY3 >= x"00000FFF" THEN 
							DELAY3 <= x"00000000";
							F2_ESTADO <= x"03";
						ELSE
							DELAY3 <= DELAY3 + x"01";
						END IF;
					
					WHEN OTHERS =>
						F2_ESTADO <= x"00";
					
				END CASE;
				

	END IF;
	
END PROCESS;

-- BOMBA
PROCESS (clk, reset)

BEGIN
		
	IF RESET = '1' THEN
		BOMBACHAR <= "00000100";
		BOMBACOR <= "1000"; -- 1000 CINZA ESCURO
		BOMBAPOS <= MANPOS;	
		DELAY4 <= x"00000000";
		BOMBA_ESTADO <= x"00";
		PLANTOU <= '0';
		
	ELSIF ((clk'event) and (clk = '1')) THEN
				
				CASE BOMBA_ESTADO IS
					WHEN x"00" =>
						
						CASE key IS
							WHEN x"78" => -- Plantou a bomba (X)
								BOMBAPOS <= MANPOS + x"01";
								PLANTOU <= '1';
								
							WHEN OTHERS =>
						END CASE;
						BOMBA_ESTADO <= x"01";
					
					WHEN x"01" =>
						IF DELAY4 >= x"0002FFFF" THEN 
							DELAY4 <= x"00000000";
							PLANTOU <= '0';
							BOMBA_ESTADO <= x"00";
							
						ELSE
							DELAY4 <= DELAY4 + x"01";
						END IF;
					
					WHEN OTHERS =>
				END CASE;
				

	END IF;
	
END PROCESS;

-- PAREDE
PROCESS (clk, reset)

BEGIN
		
	IF RESET = '1' THEN
		PCHAR <= "00000101";
		PCOR <= "0111"; -- 0111 Cinza
		PPOS <= x"026C";	
		
	ELSIF ((clk'event) and (clk = '1')) THEN
		
	END IF;
	
END PROCESS;

-- Escreve na Tela
PROCESS (clkvideo, reset)

BEGIN
	IF RESET = '1' THEN
		VIDEOE <= x"00";
		videoflag <= '0';
		MANPOSA <= x"0000";
		BOMBAPOSA <= x"0000";
		F1POSA <= x"0000";
		F2POSA <= x"0000";
		
	ELSIF ((clkvideo'event) and (clkvideo = '1')) THEN
		CASE VIDEOE IS
			
			WHEN x"00" => -- Parede
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= PCOR;
				vga_char(7 downto 0) <= PCHAR;
				
				vga_pos(15 downto 0)	<= PPOS;
				
				videoflag <= '1';
				VIDEOE <= x"01";
			
			WHEN x"01" =>
				videoflag <= '0';
				VIDEOE <= x"02";
			
			WHEN x"02" => -- Fantasma 1
				if(F1POS = F1POSA) then
					VIDEOE <= x"06"; -- Vai desenhar o fantasma 2
				else
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					
					vga_pos(15 downto 0)	<= F1POSA;
					
					videoflag <= '1';
					VIDEOE <= x"03";
				end if;
				
			WHEN x"03" =>
				videoflag <= '0';
				VIDEOE <= x"04";
			
			WHEN x"04" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= F1COR;
				vga_char(7 downto 0) <= F1CHAR;
				
				vga_pos(15 downto 0)	<= F1POS;
				
				F1POSA <= F1POS;
				videoflag <= '1';
				VIDEOE <= x"05";	
			
			WHEN x"05" =>
				videoflag <= '0';
				VIDEOE <= x"06";
			
			WHEN x"06" => -- Fantasma 2
				if(F2POS = F2POSA) then
					VIDEOE <= x"0A"; -- Vai desenhar o man
				else
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					
					vga_pos(15 downto 0)	<= F2POSA;
					
					videoflag <= '1';
					VIDEOE <= x"07";
				end if;
				
			WHEN x"07" =>
				videoflag <= '0';
				VIDEOE <= x"08";
		
			WHEN x"08" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= F2COR;
				vga_char(7 downto 0) <= F2CHAR;
				
				vga_pos(15 downto 0)	<= F2POS;
				
				F2POSA <= F2POS;
				videoflag <= '1';
				VIDEOE <= x"09";	
			
			WHEN x"09" =>
				videoflag <= '0';
				VIDEOE <= x"0A";
				
			WHEN x"0A" => -- Man
				if(MANPOSA = MANPOS) then
					VIDEOE <= x"0E"; -- Vai desenhar a bomba 
				else
									
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					
					vga_pos(15 downto 0)	<= MANPOSA;
					
					videoflag <= '1';
					VIDEOE <= x"0B";
				end if;
			
			WHEN x"0B" =>
				videoflag <= '0';
				VIDEOE <= x"0C";
			
			WHEN x"0C" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= MANCOR;
				vga_char(7 downto 0) <= MANCHAR;
				
				vga_pos(15 downto 0)	<= MANPOS;
				
				MANPOSA <= MANPOS;
				videoflag <= '1';
				VIDEOE <= x"0D";
			
			WHEN x"0D" =>
				videoflag <= '0';
				VIDEOE <= x"0E";
			
			WHEN x"0E" => -- Bomba
				-- Se PLANTOU = 1, desenha a bomba na tela
				IF (PLANTOU = '1') THEN
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= BOMBACOR;
					vga_char(7 downto 0) <= BOMBACHAR;
					
					vga_pos(15 downto 0)	<= BOMBAPOS;
					videoflag <= '1';
					VIDEOE <= x"0F";
				-- Se nao, volta para o primeiro estado
				ELSE
					VIDEOE <= x"10";
				END IF;
			
			WHEN x"0F" =>
				videoflag <= '0';
				VIDEOE <= x"10";
		
			WHEN x"10" => -- Apaga a bomba da tela
				IF (PLANTOU = '1') THEN
					VIDEOE <= x"02";
				ELSE
				
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					
					vga_pos(15 downto 0)	<= BOMBAPOS;
					videoflag <= '1';
					VIDEOE <= x"11";
				END IF;
			
			WHEN x"11" =>
				videoflag <= '0';
				VIDEOE <= x"12";	
			WHEN x"12" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= "0000";
				vga_char(7 downto 0) <= "00000000";
					
				vga_pos(15 downto 0)	<= BOMBAPOS + x"01";
				videoflag <= '1';
				
				VIDEOE <= x"13";
			WHEN x"13" =>
				videoflag <= '0';
				VIDEOE <= x"14";
				
			WHEN x"14" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= "0000";
				vga_char(7 downto 0) <= "00000000";
					
				vga_pos(15 downto 0)	<= BOMBAPOS - x"01";
				videoflag <= '1';
				
				VIDEOE <= x"15";
			WHEN x"15" =>
				videoflag <= '0';
				VIDEOE <= x"16";
			WHEN x"16" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= "0000";
				vga_char(7 downto 0) <= "00000000";
					
				vga_pos(15 downto 0)	<= BOMBAPOS + x"28";
				videoflag <= '1';
				
				VIDEOE <= x"17";
			WHEN x"17" =>
				videoflag <= '0';
				VIDEOE <= x"18";	
			WHEN x"18" =>
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= "0000";
				vga_char(7 downto 0) <= "00000000";
					
				vga_pos(15 downto 0)	<= BOMBAPOS - x"28";
				videoflag <= '1';
				
				VIDEOE <= x"19";
			WHEN x"19" =>
				videoflag <= '0';
				VIDEOE <= x"02";	
				
			WHEN OTHERS =>
				videoflag <= '0';
				VIDEOE <= x"02";	
		END CASE;
	END IF;
END PROCESS;
END a;
