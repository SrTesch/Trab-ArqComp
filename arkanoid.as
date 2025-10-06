;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
WRITE	        EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR			EQU     FFFCh
CURSOR_INIT		EQU     FFFFh
FIM_TEXTO 		EQU 	'@'
CARAC_VAZIO		EQU		' '
LINHA_NAV		EQU		21d
CARAC_NAV		EQU		'-'
TAMANHO_NAV		EQU		13d
CARAC_BOLA		EQU		'o'
LINHA_TOPO		EQU		3d  ; Linha onde começam os blocos (limite superior da bola)
LARGURA_TELA	EQU		80d ; Largura da tela para controle de borda
TIMER_UNITS 	EQU 	FFF6H
ACTIVATE_TIMER  EQU		FFF7H
ON 				EQU		1d
OFF 			EQU		0d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

		ORIG	8000h
index 		WORD	0d
linha 		WORD 	0d
navpos		WORD	33d
colunaBola	WORD	39d
linhaBola	WORD	19d
Score		WORD	0
dirXBola	WORD	2d  ; 1 para direita, -1 (FFFFh) para esquerda
dirYBola	WORD	-1d ; -1 para cima, 1 para baixo
nome 		STR		'Eusoulindo', FIM_TEXTO
linha0 		STR 	'--------------------------------------------------------------------------------', FIM_TEXTO
linha1 		STR 	'   Score: XYZ                                                        Lifes: 3   ', FIM_TEXTO
linha2 		STR 	'--------------------------------------------------------------------------------', FIM_TEXTO
linha3 		STR 	'            BXBX                                           BXBX                 ', FIM_TEXTO
linha4 		STR 	'                                    ######                                      ', FIM_TEXTO
linha5 		STR 	'            BXBX                                           BXBX                 ', FIM_TEXTO
linha6 		STR 	'                                    BXBXBX                                      ', FIM_TEXTO
linha7 		STR 	'            BXBX                                           BXBX                 ', FIM_TEXTO
linha8 		STR 	'                                    BXBXBX                                      ', FIM_TEXTO
linha9 		STR 	'            BXBX                                           BXBX                 ', FIM_TEXTO
linha10 	STR 	'                                    BXBXBX                                      ', FIM_TEXTO
linha11 	STR 	'            BXBX                                           BXBX                 ', FIM_TEXTO
linha12 	STR 	'                                    BXBXBX                                      ', FIM_TEXTO
linha13 	STR 	'                                                                                ', FIM_TEXTO
linha14 	STR 	'                                                                                ', FIM_TEXTO
linha15 	STR 	'                                                                                ', FIM_TEXTO
linha16 	STR 	'                                                                                ', FIM_TEXTO
linha17 	STR 	'                                                                                ', FIM_TEXTO
linha18 	STR 	'                                                                                ', FIM_TEXTO
linha19 	STR 	'                                       o                                        ', FIM_TEXTO
linha20 	STR 	'                                                                                ', FIM_TEXTO
linha21 	STR 	'                                 -------------                                  ', FIM_TEXTO
linha22 	STR 	'                                                                                ', FIM_TEXTO
linha23		STR 	'--------------------------------------------------------------------------------', FIM_TEXTO
game_state 	WORD	1

;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
		ORIG	FE00h
INT0	WORD	MovLeft
INT1	WORD	MovRight
INT2    WORD    ResetBola
INT3    WORD    StartTimer
		ORIG 	FE0Fh
INT15   WORD    Timer


;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
;======================================
; TIMER: a CADA 0.5s CHAMA A FUNÇÃO DE MOVIMENTAÇÃO DA BOLA
;======================================
		ORIG    0000h
		JMP     Main

Timer:  PUSH R1

		CALL movBola

		CALL ConfigureTimer

		POP R1

		RTI


ResetBola:  PUSH    R1
        	PUSH    R2
        	PUSH    R3

        	MOV     R1, 19d
        	MOV     M[linhaBola], R1
        	MOV     R1, 39d
        	MOV     M[colunaBola], R1

        	MOV     R2, 19d
        	MOV     R3, 39d
        	MOV     R1, CARAC_BOLA
        	CALL    printchar  ; Desenha a bola na posição inicial

        	POP     R3
        	POP     R2
        	POP     R1
        	RTI

StartTimer: PUSH    R1
        	MOV     R1, ON
        	MOV     M[ACTIVATE_TIMER], R1  ; ON = 1 -> ativa o timer
        	POP     R1
        	RTI


;======================================
; movBola: Movimenta a bola, verificando colisões com paredes e raquete
; R1: CHAR A SER ESCRITO
; R2: LINHA DA BOLA
; R3: COLUNA DA BOLA
; R4: DIREÇÃO EM X
; R5: DIREÇÃO EM Y
;======================================
movBola: 	PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5

			; 1. Carrega posição e direção da bola
			MOV R2, M[linhaBola]   ; R2 = linha atual
			MOV R3, M[colunaBola]  ; R3 = coluna atual

			; 2. Apaga a bola da posição atual
			MOV R1, CARAC_VAZIO
			CALL printchar

			; 3. Carrega direções para os registradores
			MOV R4, M[dirXBola] ; R4 = direção X
			MOV R5, M[dirYBola] ; R5 = direção Y

			CMP R3, 1d
			JMP.z InverteX
			CMP R3, 79d
			JMP.z InverteX
			JMP ContinuaYCheck ; Se não colidiu, continua a verificação

InverteX:	NEG R4 ; Inverte a direção X (-1 vira 1, 1 vira -1)
			MOV M[dirXBola], R4

			; Colisão com parede de cima (logo abaixo do placar)
ContinuaYCheck: CMP R2, LINHA_TOPO
				JMP.z 	InverteY

			CMP R2, 20d ; Linha logo acima da raquete?
			JMP.nz NaoBateuRaquete ; Se não, pula a verificação da raquete

			; Se está na linha certa, verifica se a coluna da bola está dentro da raquete
			MOV R1, M[navpos] ; R1 = Início da raquete
			CMP R3, R1 ; A bola está à direita ou em cima do início da raquete?
			JMP.n NaoBateuRaquete ; Se for menor (à esquerda), não bateu (JMP if negative)

			ADD R1, TAMANHO_NAV ; R1 = Fim da raquete
			CMP R3, R1 ; A bola está à esquerda do fim da raquete?
			JMP.nn NaoBateuRaquete ; Se for maior ou igual, não bateu (JMP if not negative)
			JMP.z  NaoBateuRaquete

			; Se passou em todas as verificações, BATEU na raquete!
			JMP InverteY

			; Verificação de Game Over (bola caiu no chão)
NaoBateuRaquete:	CMP R2, 21d
					JMP.nz AtualizaPosicao
					MOV R1, OFF
					MOV M[ACTIVATE_TIMER], R1
					MOV R1, CARAC_VAZIO
					CALL printchar
					JMP endMovB

InverteY:			NEG R5 ; Inverte a direção Y
					MOV M[dirYBola], R5

			; Atualiza as coordenadas da bola com base na direção
AtualizaPosicao:	ADD R2, R5 ; novaLinha = linhaAtual + dirY
					ADD R3, R4 ; novaColuna = colunaAtual + dirX
					MOV M[linhaBola], R2
					MOV M[colunaBola], R3

			; Desenha a bola na nova posição
					MOV R1, CARAC_BOLA
					CALL printchar

endMovB:			POP R5
					POP R4
					POP R3
					POP R2
					POP R1
					RET


;=========================================================================
; R1 : caracter
; R2 : linha da nave
; R3 : coluna a ser printada
;=========================================================================

MovRight:	PUSH	R1
			PUSH 	R2
			PUSH	R3

			MOV 	R3,M [ navpos ]
			CMP 	R3, 67d
			JMP.z 	endMovR
			MOV		R1,CARAC_VAZIO
			MOV 	R2, LINHA_NAV
			CALL 	printchar
			INC 	R3
			CALL    printchar
			MOV 	R1,CARAC_NAV
			ADD		R3, TAMANHO_NAV
			CALL 	printchar
			DEC 	R3
			CALL	printchar
			INC 	M[navpos]
			INC 	M[navpos]
			
endMovR:	POP		R3
			POP		R2
			POP		R1
			RTI 
;=========================================================================
; R1 : caracter
; R2 : linha da nave
; R3 : coluna a ser printada
;=========================================================================

MovLeft:	PUSH	R1
			PUSH 	R2
			PUSH	R3

			MOV 	R3,M [ navpos ]
			CMP 	R3, 2
			JMP.n 	endMovL
			MOV		R1,CARAC_NAV
			MOV 	R2, LINHA_NAV
			DEC 	R3
			CALL 	printchar
			DEC 	R3
			CALL	printchar

			MOV 	R1,CARAC_VAZIO
			ADD		R3, TAMANHO_NAV
			CALL 	printchar
			INC		R3
			CALL	printchar
			DEC 	M[navpos]
			DEC 	M[navpos]
			
endMovL:	POP		R3
			POP		R2
			POP		R1
			RTI 

;=================================
;printchar para movimentar a nav
;=================================
printchar:		PUSH 	R1
				PUSH 	R2
				PUSH 	R3

				SHL		R2, 8d
				OR		R2,R3
				MOV		M[CURSOR], R2
				MOV 	M[WRITE], R1


				POP 	R3
				POP 	R2
				POP		R1
				RET

;=========================================================================
; Printf
; R1 endereço da string -> CARACTER ATUAL
; R2 caracter atual  -> LINHA
; R3 linha -> COLUNA
; R4 coluna -> ENDEREÇO DA STRING
; R5 contador
;=========================================================================
Printf:		PUSH R1
			PUSH R3
			PUSH R4
			

Ciclo:    	MOV 	R1, M[R4]
			CMP     R1, FIM_TEXTO    ; fim do texto
        	JMP.z   EndPrintf        

        	CALL printchar   ; escreve caractere

        	INC     R4               ; próximo caractere da string
        	INC     R3               ; próxima coluna
        	JMP     Ciclo

EndPrintf:	POP R4
			POP R3
			POP R1

			RET

;------------------------------------------------------------------------------
;PRINTMAPA: printa O MAPA MOV     R2, M[R1] INTEIRO  
;------------------------------------------------------------------------------
printMapa:		PUSH 	R1
				PUSH  	R2
				PUSH 	R3
				PUSH 	R4
				PUSH 	R5

				MOV     R4, linha0          ; R4 armazena o endereço da string atual, começando com linha0
        		MOV     R5, 0d              ; R5 é o contador de linha (começa em 0)

PrintLoop:		CMP     R5, 24d             ; Já imprimiu as 24 linhas (0 a 23)?
        		JMP.z   EndPrintLoop        ; Se sim, sai do loop

        		MOV     R2, R5              ; Define a linha de impressão (0, 1, 2, ...)
        		MOV     R3, 0d              ; Define a coluna de impressão como 0
        		CALL    Printf              ; Chama a rotina para imprimir a string

        		ADD     R4, 81d             ; Avança o ponteiro para a próxima string (80 chars + 1 terminador = 81 palavras)
        		INC     R5                  ; Incrementa o contador de linha
        		JMP     PrintLoop           ; Repete o loop

EndPrintLoop: 	POP 	R5
				POP 	R4
				POP 	R3
				POP 	R2
				POP 	R1
				RET



ConfigureTimer: PUSH R1 

				MOV R1, 3d
				MOV M[ TIMER_UNITS ], R1
				MOV R1, ON
				MOV M[ ACTIVATE_TIMER ], R1

				POP R1
				RET
;=============================================================
; MAINNNNNNNNNNNNNNNNNNNNNN
;=============================================================

Main:		ENI
        	MOV     R1, INITIAL_SP
        	MOV     SP, R1              ; Inicializa a pilha (Stack Pointer)
        	MOV     R1, CURSOR_INIT     ; Inicializa o cursor para limpar a tela
        	MOV     M[CURSOR], R1

			CALL	printMapa

			CALL 	ConfigureTimer

Cycle:	BR		Cycle	
Halt:   BR		Halt
