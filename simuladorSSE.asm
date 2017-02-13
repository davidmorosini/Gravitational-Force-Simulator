FORMAT ELF
section '.text' executable

public simulador
public ajustaInfs
public fResultante
public ajustaX
public ajustaY
extrn help

;void simulador(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, 
;float tempo, float g)	
;protótipo da função

simulador:					PUSH	EBP 			
							MOV 	EBP, 	ESP
							PUSH 	EBX
				
							MOV		EAX,	[EBP + 36] 				;Quantidade de particulas

							XOR 	EBX, 	EBX

			FOR1: 			CMP 	EBX, 	EAX
							JNB 	AJUSTA

							MOV 	ECX, 	EBX
							INC 	ECX

			FOR2: 			CMP 	ECX, 	EAX
							JNB 	IT

							CALL	fResultante

							INC 	ECX
							JMP 	FOR2

			IT:				ADD 	EBX, 	0x04
							JMP 	FOR1


			AJUSTA:			CALL 	ajustaInfs
							
							POP 	EBX
							POP 	EBP
							RET


ajustaInfs:					PUSHA

							MOV		EDX,	[EBP + 36]				;qtd de particulas existentes no vetor	

							XOR 	ECX, 	ECX


			REAJUSTA:		CMP 	ECX, 	EDX
							JNB 	FIM

							CALL 	ajustaX
							CALL 	ajustaY

							ADD 	ECX, 	0x04
							JMP 	REAJUSTA
							

					FIM:	POPA
							RET
						

ajustaX:					MOVSS 	XMM0, 	[EBP + 40]	 				;Carregando Tempo
							SHUFPS 	XMM0, 	XMM0, 	0x00				;poe em todas as posicoes

							MOV 	EAX, 	[EBP + 28]
							MOVUPS 	XMM1, 	[EAX + ECX * 4]		;carregando Fx

							MOV 	EAX, 	[EBP + 8]
							MOVUPS 	XMM2, 	[EAX + ECX * 4]		;carregando M
							DIVPS 	XMM1, 	XMM2				;calc aceleração em XMM1

							MULPS 	XMM1, 	XMM0
							
							MOV 	EAX, 	[EBP + 20]
							MOVUPS 	XMM2, [EAX + ECX * 4]		;carregando Vx
							ADDPS 	XMM1, 	XMM2				;nova velocidade em X calculada

							MOVUPS 	[EAX + ECX * 4], 	XMM1

							MULPS 	XMM0, 	XMM1

							MOV 	EAX, 	[EBP + 12]
							MOVUPS 	XMM1, 	[EAX + ECX * 4]				;carregando X
							ADDPS 	XMM0, 	XMM1

							MOVUPS 	[EAX + ECX * 4], 	XMM0			;salvando X

							MOV 	EDI, 	0x00
							CVTSI2SS 	XMM0,  	EDI					;carrega um inteiro como ponto flutuante
							SHUFPS 	XMM0, 	XMM0, 	0x00
							
							MOV 	EAX, 	[EBP + 28] 				;vetor de Fx
							MOVUPS 	[EAX + ECX * 4], 	XMM0
							
							RET

;void simulador(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float * 
;tempo, float * g)

ajustaY:					
							MOVSS 	XMM0, 	[EBP + 40]	 				;Carregando Tempo
							SHUFPS 	XMM0, 	XMM0, 	0x00				;poe em todas as posicoes

							MOV 	EAX, 	[EBP + 32]
							MOVUPS 	XMM1, 	[EAX + ECX * 4]				;carregando Fy

							MOV 	EAX, 	[EBP + 8]
							MOVUPS 	XMM2, 	[EAX + ECX * 4]				;carregando M
							DIVPS 	XMM1, 	XMM2						;calc aceleração em XMM1

							MULPS 	XMM1, 	XMM0
							
							MOV 	EAX, 	[EBP + 24]
							MOVUPS 	XMM2, [EAX + ECX * 4]				;carregando Vx
							ADDPS 	XMM1, 	XMM2						;nova velocidade em X calculada

							MOVUPS 	[EAX + ECX * 4], 	XMM1

							MULPS 	XMM0, 	XMM1

							MOV 	EAX, 	[EBP + 16]
							MOVUPS 	XMM1, 	[EAX + ECX * 4]				;carregando X
							ADDPS 	XMM0, 	XMM1

							MOVUPS 	[EAX + ECX * 4], 	XMM0			;salvando X

							MOV 	EDI, 	0x00
							CVTSI2SS 	XMM0,  	EDI					;carrega um inteiro como ponto flutuante
							SHUFPS 	XMM0, 	XMM0, 	0x00
							
							MOV 	EAX, 	[EBP + 32] 				;vetor de Fx
							MOVUPS 	[EAX + ECX * 4], 	XMM0
							
							RET


fResultante:				;os indices das particulas atuais da iteração estao em EBX e ECX
					
							PUSHA 	

							MOV 	EAX, 	[EBP + 8]					;Carregando o vetor de Massas
							MOV 	EDX, 	[EBP + 12]					;Carregando o vetor de X
							MOV 	EDI, 	[EBP + 16]					;Carregando o vetor de Y

							MOVSS 	XMM0, 	[EBP + 44]	 				;Carregando o vetor de G
							SHUFPS 	XMM0, 	XMM0, 	0x00				;copia o valor de g para todas as posicoes 

							MOVUPS 	XMM1, 	[EAX + EBX * 4]				;massa do primeiro
							MULPS 	XMM0, 	XMM1 
							MOVUPS 	XMM1, 	[EAX + ECX * 4]				;massa do segundo
							MULPS 	XMM0, 	XMM1 						;XMM0 = G * m1 * m2


							MOVUPS 	XMM1, 	[EDX + EBX * 4]				;posicao x da primeira particula
							MOVUPS 	XMM2, 	[EDX + ECX * 4]				;posicao x da segunda particula
							SUBPS 	XMM1, 	XMM2
							MULPS 	XMM1, 	XMM1 						;(deltaX ^ 2) em XMM1

							MOVUPS 	XMM2, 	[EDI + EBX * 4]				;posicao y da primeira particula
							MOVUPS 	XMM3, 	[EDI + ECX * 4]				;posicao y da segunda particula
							SUBPS 	XMM2, 	XMM3
							MULPS 	XMM2, 	XMM2						;(deltaY ^ 2) em XMM2

							ADDPS	XMM1, 	XMM2
							SQRTPS 	XMM1, 	XMM1 						;XMM1 = distAB	e XMM0 = G*m1*m2

							MOVAPS 	XMM2, 	XMM1 	
							MULPS 	XMM1, 	XMM1
							MULPS 	XMM1, 	XMM2						;XMM1 = distAB ^ 3, XMM0 = G * m1 * m2

							DIVPS 	XMM0, 	XMM1 						;daqui para frente diferencia o X do Y

							MOVUPS 	XMM1, 	[EDX + ECX * 4]				;X do segundo
							MOVUPS 	XMM2, 	[EDX + EBX * 4]				;X do primeiro
							SUBPS 	XMM1, 	XMM2 						;deltaX de forma com que direcione o angulo
							MULPS 	XMM1, 	XMM0 						;forca calculada em X

							MOV 	EAX, 	[EBP + 28]					;forca anterior em X

							MOVUPS 	XMM2, 	[EAX + EBX * 4] 	
							ADDPS 	XMM2, 	XMM1		 				;forca atual em X, somada com a anterior
							MOVUPS 	[EAX + EBX * 4], 	XMM2			;att Fx de EBX

							MOVUPS 	XMM2, 	[EAX + ECX * 4] 	
							SUBPS 	XMM2, 	XMM1		 				;forca atual em X, somada com a anterior
							MOVUPS 	[EAX + ECX * 4], 	XMM2			;att Fx de ECX


							MOVUPS 	XMM1, 	[EDI + ECX * 4]	
							MOVUPS 	XMM2, 	[EDI + EBX * 4]	
							SUBPS 	XMM1, 	XMM2 						;deltaY de forma com que direcione o angulo
							MULPS 	XMM1, 	XMM0 						;forca calculada em Y

							MOV 	EAX, 	[EBP + 32]

							MOVUPS 	XMM2, 	[EAX + EBX * 4] 	
							ADDPS 	XMM2, 	XMM1		 				;forca atual em Y, somada com a anterior
							MOVUPS 	[EAX + EBX * 4], 	XMM2			;att Fy de EBX

							MOVUPS 	XMM2, 	[EAX + ECX * 4] 	
							SUBPS 	XMM2, 	XMM1		 				;forca atual em Y, somada com a anterior
							MOVUPS 	[EAX + ECX * 4], 	XMM2			;att Fy de ECX

							POPA
							RET