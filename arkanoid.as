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
linha4 		STR 	'                                    BXBXBX                                      ', FIM_TEXTO
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
game_state 	WORD	1d
Vidas       WORD    3d
MsgGameOver STR     'GAME OVER', '@';
ComboCount  WORD    1d      ; Multiplicador de pontos (inicia em 1)
CharBlocoB  EQU     'B'     ; Caracter do bloco tipo 1
CharBlocoX  EQU     'X'     ; Caracter do bloco tipo 2
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

Timer:              PUSH R1
                    ; 1. Verifica se o jogo já estava parado antes de começar
                    MOV R1, M[game_state]
                    CMP R1, OFF
                    JMP.Z DeactivateTimer

                    ; 2. Move a bola (aqui dentro pode ocorrer o Game Over)
                    CALL movBola

                    ; 3. VERIFICAÇÃO CRUCIAL: O jogo acabou DENTRO do movBola?
                    MOV R1, M[game_state]
                    CMP R1, OFF
                    JMP.Z DeactivateTimer  ; Se acabou, não reativa o timer!

                    ; 4. Se ainda está rolando, reativa o timer
                    CALL ConfigureTimer
                    JMP EndTimer

DeactivateTimer:    MOV R1, OFF
                    MOV M[ACTIVATE_TIMER], R1
EndTimer:           POP R1
                    RTI


ResetPosBola:  PUSH    R1
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
        	RET

ResetBola:	CALL ResetPosBola
			RTI

StartTimer: PUSH    R1
        	MOV     R1, ON
        	MOV     M[ACTIVATE_TIMER], R1  ; ON = 1 -> ativa o timer
			MOV 	M[game_state], R1
			CALL 	movBola
			CALL 	ConfigureTimer
        	POP     R1
        	RTI



;======================================
; AtualizaVidas: Escreve o valor de M[Vidas] na linha 1, coluna 76
;======================================
AtualizaVidas:  PUSH R1
                PUSH R2
                PUSH R3
                
                MOV  R1, M[Vidas]    ; Carrega número de vidas (ex: 3)
                ADD  R1, '0'         ; Converte para ASCII (3 + 48 = '3')
                
                MOV  R2, 1d          ; Linha 1 (onde está o texto Lifes:)
                MOV  R3, 76d         ; Coluna 76 (posição aproximada do número)
                
                CALL printchar       ; Escreve o número
                
                POP R3
                POP R2
                POP R1
                RET

;======================================
; ShowGameOver: Mostra GAME OVER no meio da tela
;======================================
ShowGameOver:   PUSH R1
                PUSH R2
                PUSH R3
                PUSH R4
                
                MOV  R4, MsgGameOver ; Endereço da string
                MOV  R2, 12d         ; Linha (meio)
                MOV  R3, 35d         ; Coluna (meio)
                
CicloGO:        MOV  R1, M[R4]       ; Lê caracter
                CMP  R1, FIM_TEXTO
                JMP.Z FimShowGO
                
                CALL printchar
                INC  R4
                INC  R3
                JMP  CicloGO
                
FimShowGO:      POP R4
                POP R3
                POP R2
                POP R1
                RET

;=========================================================================
; CalcEndereco: Calcula o endereço de memória de uma coordenada (L, C)
; Entrada: R2 (Linha), R3 (Coluna) -> Saída: R6 (Endereço)
;=========================================================================
CalcEndereco:   PUSH R2
                MOV R6, 81d
                MUL R2, R6
                ADD R6, R3
                ADD R6, linha0
                POP R2
                RET

;=========================================================================
; TrataColisaoBloco: Apaga bloco, aumenta score e combo
;=========================================================================
TrataColisaoBloco: PUSH R1
                   PUSH R4
                   PUSH R5
                   
                   MOV R1, CARAC_VAZIO
                   MOV M[R6], R1        ; Apaga da memória
                   CALL printchar       ; Apaga da tela

                   ; Atualiza Score (Score + 10 * Combo)
                   MOV R4, M[ComboCount]
                   MOV R5, 10d
                   MUL R5, R4
                   MOV R4, M[Score]
                   ADD R4, R5
                   MOV M[Score], R4

                   ; Aumenta Combo
                   MOV R1, M[ComboCount]
                   INC R1
                   MOV M[ComboCount], R1

                   POP R5
                   POP R4
                   POP R1
                   RET

;======================================
; movBola: Física com Check "XBX" (Coluna Anterior)
;======================================
movBola:    PUSH R1
            PUSH R2
            PUSH R3
            PUSH R4
            PUSH R5
            PUSH R6
            PUSH R7

            ; Apaga bola atual
            MOV R2, M[linhaBola]
            MOV R3, M[colunaBola]
            MOV R1, CARAC_VAZIO
            CALL printchar

            MOV R4, M[dirXBola]
            MOV R5, M[dirYBola]

            ; ================= EIXO X =================
            MOV R3, M[colunaBola]
            ADD R3, R4              ; R3 = Próximo X

            ; Verifica Bloco X (O que vamos bater)
            CALL CalcEndereco
            MOV R1, M[R6]
            CMP R1, CharBlocoB
            JMP.Z BateuBlocoX
            CMP R1, CharBlocoX
            JMP.Z BateuBlocoX
            JMP VerificaParedeX

BateuBlocoX: CALL TrataColisaoBloco ; Destrói o bloco da frente

            ; --- LÓGICA XBX (Verifica Coluna Anterior) ---
            PUSH R2
            PUSH R3
            PUSH R6
            
            MOV R2, M[linhaBola] ; Mesma Linha
            MOV R3, M[colunaBola]
            SUB R3, R4           ; Coluna Anterior (Onde viemos: Col - DirX)
            
            CALL CalcEndereco    ; Verifica o que tem atrás da bola
            MOV R6, M[R6]
            
            CMP R6, CharBlocoB   ; Tem bloco atrás?
            JMP.Z SlideY_NoX
            CMP R6, CharBlocoX   ; Tem bloco atrás?
            JMP.Z SlideY_NoX
            
            ; --- Colisão Padrão (Sem bloco atrás) ---
            POP R6
            POP R3
            POP R2
            NEG R4               ; Inverte X (Bate e volta)
            MOV M[dirXBola], R4
            JMP FimCheckX

 ; --- Caso XBX (Tem bloco atrás) ---
            ; Não inverte X (Continua andando para o espaço vazio que abriu)
            ; Inverte apenas Y (efeito de deslizar/quicar verticalmente)
SlideY_NoX: POP R6
            POP R3
            POP R2
            NEG R5               
            MOV M[dirYBola], R5
            JMP FimCheckX           


VerificaParedeX: CMP R3, 1d
                 JMP.Z InverteX_Wall
                 CMP R3, 79d
                 JMP.Z InverteX_Wall
                 
                 ; Caminho livre: Atualiza posição X
                 MOV M[colunaBola], R3
                 JMP FimCheckX

InverteX_Wall:   NEG R4
                 MOV M[dirXBola], R4

            ; ================= EIXO Y =================
FimCheckX:      MOV R2, M[linhaBola]    ; Início da verificação Y
                ADD R2, R5              ; R2 = Próximo Y
                MOV R3, M[colunaBola]   ; Usa X (atualizado ou não)

            ; Verifica Bloco Y
            CALL CalcEndereco
            MOV R1, M[R6]
            CMP R1, CharBlocoB
            JMP.Z BateuBlocoY
            CMP R1, CharBlocoX
            JMP.Z BateuBlocoY
            JMP VerificaTeto

BateuBlocoY:    CALL TrataColisaoBloco
                NEG R5
                MOV M[dirYBola], R5
                JMP FimCheckY

VerificaTeto:   CMP R2, LINHA_TOPO
                JMP.Z InverteY_Wall

            ; Verifica Raquete e Chão
                CMP R2, 20d
                JMP.NZ CheckChao

            ; Lógica Raquete
                MOV R1, M[navpos]
                CMP R3, R1
                JMP.N CheckChao
                ADD R1, TAMANHO_NAV
                CMP R3, R1
                JMP.NN CheckChao

            ; Bateu na Raquete
                MOV R1, 1d
                MOV M[ComboCount], R1   ; Reseta Combo
                JMP InverteY_Wall

CheckChao:      CMP R2, 21d
                JMP.NZ ConfirmaMovY
                
                MOV R1, 1d
                MOV M[ComboCount], R1
                
                MOV R1, M[Vidas]
                DEC R1
                MOV M[Vidas], R1
                CALL AtualizaVidas
                
                CMP R1, 0
                JMP.Z MorreuDeVez
                
                MOV R2, OFF
                MOV M[ACTIVATE_TIMER], R2
                MOV M[game_state], R2
                CALL ResetPosBola
                JMP SaiMovBola

MorreuDeVez:    MOV R1, OFF
                MOV M[game_state], R1
                CALL ShowGameOver
                JMP SaiMovBola

InverteY_Wall:  NEG R5
                MOV M[dirYBola], R5
                JMP FimCheckY

ConfirmaMovY:   MOV M[linhaBola], R2

FimCheckY:      MOV R2, M[linhaBola]
                MOV R3, M[colunaBola]
                MOV R1, CARAC_BOLA
                CALL printchar

SaiMovBola:     POP R7
                POP R6
                POP R5
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
