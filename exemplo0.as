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
CARAC_NAV		EQU		'_'
TAMANHO_NAV		EQU		7d

;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------

		ORIG	8000h
nome 	STR 	'Tamo Junto', FIM_TEXTO
index 	WORD	0d
linha 	WORD 	0d
linhaNave 	WORD 	21d
navpos	WORD	35d
coluna 	WORD	0d
linha0 	STR 	'--------------------------------------------------------------------------------', FIM_TEXTO
linha1 	STR 	'   Score: XYZ                                                        Lifes: 3   ', FIM_TEXTO
linha2 	STR 	'--------------------------------------------------------------------------------', FIM_TEXTO
linha3 	STR 	'         B X B X                                      B X                       ', FIM_TEXTO
linha4 	STR 	'                               B X B X B X                                      ', FIM_TEXTO
linha5 	STR 	'         B X B X                                      B X                       ', FIM_TEXTO
linha6 	STR 	'                               B X B X B X                                      ', FIM_TEXTO
linha7 	STR 	'         B X B X                                      B X                       ', FIM_TEXTO
linha8 	STR 	'                               B X B X B X                                      ', FIM_TEXTO
linha9 	STR 	'         B X B X                                      B X                       ', FIM_TEXTO
linha10 STR 	'                               B X B X B X                                      ', FIM_TEXTO
linha11 STR 	'         B X B X                                      B X                       ', FIM_TEXTO
linha12 STR 	'                               B X B X B X                                      ', FIM_TEXTO
linha13 STR 	'                                                                                ', FIM_TEXTO
linha14 STR 	'                                                                                ', FIM_TEXTO
linha15 STR 	'                                                                                ', FIM_TEXTO
linha16 STR 	'                                                                                ', FIM_TEXTO
linha17 STR 	'                                                                                ', FIM_TEXTO
linha18 STR 	'                                                                                ', FIM_TEXTO
linha19 STR 	'                                                                                ', FIM_TEXTO
linha20 STR 	'                                                                                ', FIM_TEXTO
linha21 STR 	'                                   _______                                      ', FIM_TEXTO
linha22 STR 	'                                                                                ', FIM_TEXTO
linha23	STR 	'--------------------------------------------------------------------------------', FIM_TEXTO


;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
		ORIG	FE00h
INT1	WORD	MovLeft
INT0	WORD	MovRight

;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;======================================
;TEMPLATE ROTINA
;======================================
Funcao: PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4



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
			CMP 	R3, 73d
			JMP.z 	endMovR
			MOV		R1,CARAC_VAZIO
			MOV 	R2, LINHA_NAV
			CALL 	printchar
			MOV 	R1,CARAC_NAV
			ADD		R3, TAMANHO_NAV
			CALL 	printchar
			INC 	M[navpos]
			
endMovR:		POP		R3
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
			CMP 	R3, 0
			JMP.z 	endMovL
			MOV		R1,CARAC_NAV
			MOV 	R2, LINHA_NAV
			DEC 	R3
			CALL 	printchar
			MOV 	R1,CARAC_VAZIO
			ADD		R3, TAMANHO_NAV
			CALL 	printchar
			DEC 	M[navpos]
			
endMovL:		POP		R3
			POP		R2
			POP		R1
			RTI 

;=================================
;printchar para movimentar a nav
;=================================
printchar:	PUSH 	R1
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
; R1 endereço da string
; R2 caracter atual
; R3 linha
; R4 coluna
; R5 contador
;=========================================================================
Printf:		PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5
			PUSH R6

Ciclo:  MOV     R2, M[R1]        ; pega caractere
        CMP     R2, FIM_TEXTO    ; fim do texto
        JMP.z   EndPrintf        

        MOV     R5, R3           ; linha
        SHL     R5, 8
        OR      R5, R4           ; posição cursor
        MOV     M[CURSOR], R5
        MOV     M[WRITE], R2     ; escreve caractere

        INC     R1               ; próximo caractere da string
        INC     R4               ; próxima coluna
        JMP     Ciclo

EndPrintf:	POP R6
			POP R5
			POP R4
			POP R3
			POP R2
			POP R1

			RET

;------------------------------------------------------------------------------
;PRINTMAPA: printa O MAPA INTEIRO  
;------------------------------------------------------------------------------
printMapa:		PUSH 	R1
				PUSH 	R3
				PUSH 	R4
				PUSH 	R5
				PUSH 	R6

				MOV     R6, linha0          ; R6 armazena o endereço da string atual, começando com linha0
        		MOV     R5, 0d              ; R5 é o contador de linha (começa em 0)

PrintLoop:		CMP     R5, 24d             ; Já imprimiu as 24 linhas (0 a 23)?
        		JMP.z   EndPrintLoop        ; Se sim, sai do loop

        		MOV     R1, R6              ; Copia o endereço da string atual para R1 (parâmetro do Printf)
        		MOV     R3, R5              ; Define a linha de impressão (0, 1, 2, ...)
        		MOV     R4, 0d              ; Define a coluna de impressão como 0
        		CALL    Printf              ; Chama a rotina para imprimir a string

        		ADD     R6, 81d             ; Avança o ponteiro para a próxima string (80 chars + 1 terminador = 81 palavras)
        		INC     R5                  ; Incrementa o contador de linha
        		JMP     PrintLoop           ; Repete o loop

EndPrintLoop: 	POP 	R6
				POP 	R5
				POP 	R4
				POP 	R3
				POP 	R1
				RET

Main:		ENI
        	MOV     R1, INITIAL_SP
        	MOV     SP, R1              ; Inicializa a pilha (Stack Pointer)
        	MOV     R1, CURSOR_INIT     ; Inicializa o cursor para limpar a tela
        	MOV     M[CURSOR], R1
			CALL	printMapa

Cycle:	BR		Cycle	
Halt:   BR		Halt
