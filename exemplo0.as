;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
WRITE	        EQU     FFFEh
INITIAL_SP      EQU     FDFFh
CURSOR			EQU     FFFCh
CURSOR_INIT		EQU     FFFFh
FIM_TEXTO 		EQU 	'@'

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
coluna 	WORD	0d
linha0 	STR 	'--------------------------------------------------------------------------------', FIM_TEXTO
;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
		ORIG	FE00h
INT0	WORD 	RotinaEusoulindo


;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

RotinaEusoulindo: CALL printchar
		RTI

Funcao: PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4



		POP R4
		POP R3
		POP R2
		POP R1

		RET

; R1 endereço da string
; R2 caracter atual
; R3 linha
; R4 coluna
; R5 contador

Printf:		PUSH R1
			PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5
			PUSH R6

			MOV 	R5, 0d

Ciclo:	MOV 	R6, R3
		ADD		R1, R5
		MOV		R2, M[R1]
		CMP 	R2, FIM_TEXTO
		JMP.z   EndPrintf
		ADD 	R4, R5
		SHL 	R6, 8
		OR 		R6, R4
		MOV 	M[CURSOR], R6
		MOV 	M[WRITE], R2
		SUB 	R4, R5
		SUB     R1, R5
		INC     R5
		JMP   	Ciclo

EndPrintf:	POP R6
			POP R5
			POP R4
			POP R3
			POP R2
			POP R1

			RET

;------------------------------------------------------------------------------
;printchar: printa caracter
; R1 = endereço da string
; R2 = LINHA
; R3 = COLUNA
; R4 = CARACTER    
;------------------------------------------------------------------------------

printchar: 		PUSH 	R1
				PUSH 	R2
				PUSH 	R3
				PUSH 	R4

				MOV 	R1, nome
				MOV 	R4, M[index]
				ADD 	R4, R1
				MOV 	R1, M[R4]
				CMP 	R1, FIM_TEXTO
				JMP.z 	endprintchar
				MOV		R2, M[linha]
				MOV 	R3, M[coluna]
				SHL		R2, 8d
				OR		R2,R3
				MOV		M[CURSOR], R2
				MOV 	M[WRITE], R1

				INC 	M[coluna]
				INC 	M[linha]
				INC 	M[index]

endprintchar:	POP R4
				POP R3
				POP R2
				POP R1
				RET

Main:	ENI
		MOV		R1, INITIAL_SP
		MOV		SP, R1		 		; We need to initialize the stack
		MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
		MOV		M[ CURSOR ], R1		; with value CURSOR_INIT
		
			
				
Cycle:	BR		Cycle	
Halt:   BR		Halt
