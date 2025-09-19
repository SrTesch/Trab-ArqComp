;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CR              EQU     0Ah
FIM_TEXTO       EQU     '@'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		EQU     FFFCh
CURSOR_INIT	EQU	FFFFh
ROW_POSITION	EQU	0d
COL_POSITION	EQU	0d
ROW_SHIFT	EQU	8d
COLUMN_SHIFT	EQU	8d
PULA_LINHA	EQU	81d
MAPA 		EQU      8000h
NAVE_CORPO	EQU	'='
LINHA_NAVE	EQU	22d
APAGA           EQU     ' '
BOLA            EQU     'o'

TIMER_UNIT	EQU	FFF6H
ACTIVE_TIMER	EQU	FFF7H
OFF		EQU	0d
ON 		EQU     1

DIREITA         EQU     -1d
ESQUERDA        EQU      1d
CIMA            EQU     -1d
BAIXO           EQU      1d
;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------
	ORIG 	8000h
L0	STR	'################################################################################', FIM_TEXTO
L1	STR	'#                                                                              #', FIM_TEXTO
L2	STR	'#                                                                              #', FIM_TEXTO
L3	STR	'#                                                                              #', FIM_TEXTO
L4	STR	'#                                                                              #', FIM_TEXTO
L5	STR	'#                                                                              #', FIM_TEXTO
L6	STR	'#                                                                              #', FIM_TEXTO
L7	STR	'#                                                                              #', FIM_TEXTO
L8	STR	'#                                                                              #', FIM_TEXTO
L9	STR	'#                                                                              #', FIM_TEXTO
L10	STR	'#                                                                              #', FIM_TEXTO
L11	STR	'#                                                                              #', FIM_TEXTO
L12	STR	'#                                                                              #', FIM_TEXTO
L13	STR	'#                                                                              #', FIM_TEXTO
L14	STR	'#                                                                              #', FIM_TEXTO
L15	STR	'#                                                                              #', FIM_TEXTO
L16	STR	'#                                                                              #', FIM_TEXTO
L17	STR	'#                                                                              #', FIM_TEXTO
L18	STR	'#                                                                              #', FIM_TEXTO
L19	STR	'#                                                                              #', FIM_TEXTO
L20	STR	'#                                                                              #', FIM_TEXTO
L21	STR	'#                                                                              #', FIM_TEXTO
L22	STR	'#                                                                              #', FIM_TEXTO
L23	STR	'################################################################################', FIM_TEXTO

RowIndex		WORD	0d
ColumnIndex		WORD	0d

Corpo_Nave		STR		'=========='	
Tamanho_Corpo	WORD	10d
Posicao_NaveI	WORD	22d
Posicao_NaveF	WORD	32d

LinhaBola       WORD    21d
ColunaBola      WORD    26d
Teste           WORD    1d

DirLinha    WORD   -1d    ; -1 = sobe, 1 = desce
DirColuna   WORD    1d    ; -1 = esqu, 1 = dir
;------------------------------------------------------------------------------
; ZONA III: definicao de tabela de interrupções
;------------------------------------------------------------------------------
	ORIG    FE00h
INT0    WORD    Esqueda
INT1    WORD    Direita
	                
        ORIG    FE0Fh
INT15	WORD	Timer



;------------------------------------------------------------------------------
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main

;------------------------------------------------------------------------------  
; Timer
;------------------------------------------------------------------------------  
Timer:  PUSH R1
	PUSH R2
	PUSH R3

        CALL apagaBola
        ;MOV R1, M[DirLinha]
        ;ADD M[LinhaBola], R1   ; Atualiza a posição da linha

        ;MOV R2, M[DirColuna]
        ;ADD M[ColunaBola], R2  ; Atualiza a posição da coluna


        ;CALL MoveCima
        CALL DirecaoBolaY
        CALL ConfTimer

	POP R3
	POP R2
	POP R1 
	RTI

;------------------------------------------------------------------------------
;ConfTimer
;------------------------------------------------------------------------------

ConfTimer:PUSH R1
	PUSH R2
	PUSH R3

	MOV R1, 5d
	MOV M[TIMER_UNIT], R1

	MOV R1, ON
	MOV	M[ACTIVE_TIMER], R1


	POP R3
	POP R2
	POP R1
	RET 



;------------------------------------------------------------------------------
;Função imprimi mapa
;------------------------------------------------------------------------------

Maprint:    PUSH R1
            PUSH R2
            PUSH R3

            MOV R1, L0          ; Primeira linha
            MOV R2, 0           ; Contador de linhas

cicloMap:   CALL print          ; Imprime linha atual
            INC R2              ; Próxima linha

            CMP R2, 24d
            JMP.Z fimMap
            
            ADD R1, PULA_LINHA  ; Próxima linha na memória
            MOV M[RowIndex], R2 ; Atualiza índice da linha

            JMP cicloMap

fimMap:     POP R3
            POP R2
            POP R1
            RET

;------------------------------------------------------------------------------
; Função print para o mapa
;------------------------------------------------------------------------------

print:	    PUSH 	R1	; &String inicial = L0
			PUSH 	R2	
			PUSH 	R3	 
			PUSH 	R4 ; valor do R1


printciclo:	MOV 	R4, M[ R1 ] ; valor do que esta em R1

			CMP 	R4, FIM_TEXTO
			JMP.Z 	Endprint

			MOV R2, M[RowIndex]

			SHL R2,	ROW_SHIFT ; linha
			OR  R2, R3
			MOV M[ CURSOR ], R2
			MOV M[ IO_WRITE ], R4

			INC R3 ; avança para proxima coluna
			INC R1 ; incrementa para a próxima letra da str

			JMP printciclo


Endprint:POP R4
			POP R3
			POP R2
			POP R1
			RET

;------------------------------------------------------------------------------
;Direita
;------------------------------------------------------------------------------
Direita:PUSH R1
        PUSH R2

        MOV R1, LINHA_NAVE       
        SHL R1, ROW_SHIFT
        OR R1, M[Posicao_NaveI] 

        MOV M[CURSOR], R1
        MOV R2, APAGA             
        MOV M[IO_WRITE], R2

        INC M[Posicao_NaveI]
        INC M[Posicao_NaveF]
        
        CALL Imprimenave

        POP R2
        POP R1
        RTI


;------------------------------------------------------------------------------
;Esquerda
;------------------------------------------------------------------------------
Esqueda:PUSH R1
        PUSH R2


        MOV R1, LINHA_NAVE       
        SHL R1, ROW_SHIFT
        OR R1, M[Posicao_NaveF] 
        
        MOV M[CURSOR], R1
        MOV R2, APAGA             
        MOV M[IO_WRITE], R3

        DEC M[Posicao_NaveF]
        DEC M[Posicao_NaveI]
        CALL Imprimenave

        POP R2
        POP R1
        RTI

;------------------------------------------------------------------------------
;Imprime nave
;------------------------------------------------------------------------------
Imprimenave:    PUSH R1
                PUSH R2
                PUSH R3
                PUSH R4

                MOV R1, Corpo_Nave      ; Ponteiro para string da nave
                MOV R2, 0               ; Contador inicia em 0

Loopnave:       CMP R2, M[Tamanho_Corpo] ; Compara com tamanho
                JMP.Z Fimcorponave
                
                ; Calcula posição do cursor
                MOV R4, M[Posicao_NaveI] ; Coluna inicial
                ADD R4, R2              ; Coluna + offset
                
                MOV R3, LINHA_NAVE      ; Linha fixa
                SHL R3, ROW_SHIFT       ; Linha << 8
                OR R3, R4               ; Combina linha e coluna
                
                ; Posiciona cursor e escreve
                MOV M[CURSOR], R3
                MOV R3, M[R1]           ; Pega caractere da string
                MOV M[IO_WRITE], R3     ; ESCREVE no display
                
                ; Prepara próximo
                INC R1                  ; Próximo caractere
                INC R2                  ; Incrementa contador
                JMP Loopnave

Fimcorponave:   POP R4
                POP R3
                POP R2
                POP R1
                RET

;------------------------------------------------------------------------------
;DirecaoBola
;------------------------------------------------------------------------------
DirecaoBolaY:   PUSH R1

                MOV R1, M[DirLinha]
                CMP R1, CIMA
                CALL.Z MoveCima

                CMP R1, CIMA
                CALL.Z MoveBaixo

                POP R1
                RET


;------------------------------------------------------------------------------
;Função
;------------------------------------------------------------------------------

MoveCima:       PUSH R1
		PUSH R2
		PUSH R3
                PUSH R4

                MOV R1, M[LinhaBola]
                MOV R2, M[ColunaBola]

ColideCima:     DEC R1

                MOV R4, R1
                MOV R3, PULA_LINHA

                MUL R3, R1
                ADD R2, R1
                ADD R2, MAPA

                MOV R2, M [R2]
                CMP R2, '#'
                JMP.Z InverteCima 

ContinuaCima:   MOV M[LinhaBola], R4                

FimBolaCima:	CALL PrintBola
                POP R4
                POP R3
		POP R2
		POP R1
		RET 

InverteCima:    MOV R4, BAIXO
                MOV M[DirLinha], R4
                JMP FimBolaCima

;------------------------------------------------------------------------------
;Baixo
;------------------------------------------------------------------------------

MoveBaixo:      PUSH R1
		PUSH R2
		PUSH R3
                PUSH R4

                MOV R1, M[LinhaBola]
                MOV R2, M[ColunaBola]

ColideBaixo:    INC R1

                MOV R4, R1
                MOV R3, PULA_LINHA

                MUL R3, R1
                ADD R2, R1
                ADD R2, MAPA

                MOV R2, M [R2]
                CMP R2, '#'
                JMP.Z InverteBaixo 

ContinuaBaixo:  MOV M[LinhaBola], R4                

FimBolaBaixo:	CALL PrintBola
                POP R4
                POP R3
		POP R2
		POP R1
		RET 

InverteBaixo:   MOV R4, BAIXO
                MOV M[DirLinha], R4
                JMP FimBolaBaixo


;------------------------------------------------------------------------------
;PrintBola e apagaBola
;------------------------------------------------------------------------------
PrintBola:      PUSH R1
                PUSH R2

                MOV R1, M[ColunaBola]
                MOV R2, M[LinhaBola]

                SHL R2,	ROW_SHIFT ; linha
		OR  R1, R2 
		MOV M[ CURSOR ], R1

                MOV R2, BOLA
		MOV M[ IO_WRITE ], R2

                POP R2
                POP R1
                RET

;------------------------------------------------------------------------------
;apagaBola
;------------------------------------------------------------------------------
apagaBola:      PUSH R1
                PUSH R2

                MOV R1, M[ColunaBola]
                MOV R2, M[LinhaBola]

                SHL R2,	ROW_SHIFT ; linha
		OR  R1, R2 
		MOV M[ CURSOR ], R1

                MOV R2, APAGA
		MOV M[ IO_WRITE ], R2

                POP R2
                POP R1
                RET


Main:ENI

	MOV		R1, INITIAL_SP
	MOV		SP, R1		 		; We need to initialize the stack
	MOV		R1, CURSOR_INIT		; We need to initialize the cursor 
	MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

	CALL Maprint
        CALL Imprimenave
        CALL PrintBola

        CALL ConfTimer

        
	

;./p3as-win arkanoid.as; java -jar p3sim.jar arkanoid.exe
Cycle: 			BR		Cycle	
Halt:           BR		Halt