FORMAT ELF
section '.text' executable

public simulador
public ajustaInfs
public fResultante
public ajustaX
public ajustaY
extrn help


;Disposições Gerais:
;a função que inicia o processo, de simulação, chama se < simulador >, o prototipo desta, no código
;escrito em C é: void simulador(float * p, int qtdP, float * tempo, float * g);
;Observações: os campos tempo e g, foram declarados como ponteiros para float, para que o código 
;pudesse ter uma fluidez maior na versão escrita com a extensão SSE, de modo que estes campos mencionados
;são ambos vetores alocados para 4 floats (16 bytes)
;
;os Deslocamentos postos abaixo nos acessos a memoria, correspondem ao DES do código em C, porém, como
;o deslocamento no código assembly deve ser disposto em bytes, e como é um vetor de floats, esse DES
;é multiplicado por 4


;cabeçalho da funcao < simulador >
;Tipo de retorno: void
;esta funcao faz apenas o papel dos laços para percorrer o vetor de particulas

			
simulador:			PUSH	EBP 			
					MOV 	EBP, 	ESP
					PUSH 	EBX
		
					MOV		EAX,	[EBP + 36] 		;Quantidade de particulas

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

		IT:			INC 	EBX
					JMP		FOR1

		AJUSTA:		CALL 	ajustaInfs
					
					POP 	EBX
					POP 	EBP
					RET


;cabeçalho da funcao < ajustaInfs >
;Tipo de retorno: void	
;funcao responsável por recalcular as velocidades escalares em X e Y, e também pela atualização
;das posições X e Y, apenas um ponteiro para o vetor de particulas foi passado por referencia
;para que a função possa alterar os valores internamente.					

ajustaInfs:			PUSHA

					MOV		EDX,	[EBP + 36]				;Qtd de particulas existentes no vetor	

					XOR 	ECX, 	ECX

	REAJUSTA:		CMP 	ECX, 	EDX
					JNB 	FIM

					CALL 	ajustaX 						;ajusta as informações em relação ao eixo X
					CALL 	ajustaY							;ajusta as informações em relação ao eixo Y

					MOV 	EAX, 	[EBP + 28]
					MOV 	DWORD [EAX + ECX * 4], 	0x00		
					MOV 	EAX, 	[EBP + 32]
					MOV 	DWORD [EAX + ECX * 4], 	0x00

															;ao fim de cada iteração as forças em X e Y são zeradas
															;inicialmente essas forças também estão zeradas, pois 
															;se é usado calloc para alocar espaço para o vetor.

					INC 	ECX
					JMP		REAJUSTA

			FIM:	POPA
					RET



;cabeçalho da funcao < ajustaX >
;Tipo de retorno: void	
;funcao chamada internamente por < ajustaInfs >, é responsavel por fazer os calculos de velocidade e posição
;em relação a orientação X


ajustaX:			
					PUSHA 	

					FLD		DWORD [EBP + 40]						;carregando para a FPU o tempo

					MOV 	EAX, 	[EBP + 28]
					FLD		DWORD [EAX + ECX * 4]			;pegando fx da estrutura apontada por EBX
					MOV 	EAX, 	[EBP + 8]
					FLD		DWORD [EAX + ECX * 4]			;massa da particula

					FDIVP	ST1,	ST 						;resulta na aceleracao em X da particula

					FMUL 	ST, 	ST1 					;t * ax

					MOV 	EAX, 	[EBP + 20]
					FLD		DWORD [EAX + ECX * 4]			;carregando a Velocidade em X
					FADDP 	ST1,	ST 						;resulta na nova velocidade em X da particula
															;neste momento, ST1 é Ax, e ST é Vx

					FST		DWORD [EAX + ECX * 4]			;velocidade em X atualizada na estrutura
					FMULP 	ST1, 	ST

					MOV 	EAX, 	[EBP + 12]
					FLD 	DWORD [EAX + ECX * 4]

					FADDP	ST1,	ST

					FSTP 	DWORD [EAX + ECX * 4]

					POPA
					RET


;cabeçalho da funcao < ajustaY >
;Tipo de retorno: void	
;funcao chamada internamente por < ajustaInfs >, é responsavel por fazer os calculos de velocidade e posição
;em relação a orientação Y


ajustaY:			PUSHA 	

					FLD		DWORD [EBP + 40]					;carregando para a FPU o tempo

					MOV 	EAX, 	[EBP + 32]
					FLD		DWORD [EAX + ECX * 4]			;pegando fy da estrutura apontada por EBX
					MOV 	EAX, 	[EBP + 8]
					FLD		DWORD [EAX + ECX * 4]			;massa da particula

					FDIVP	ST1,	ST 						;resulta na aceleracao em Y da particula

					FMUL 	ST, 	ST1 					;t * ay

					MOV 	EAX, 	[EBP + 24]
					FLD		DWORD [EAX + ECX * 4]			;carregando a Velocidade em Y
					FADDP 	ST1,	ST 						;resulta na nova velocidade em Y da particula
															;neste momento, ST1 é Ay, e ST é Vy

					FST		DWORD [EAX + ECX * 4]			;velocidade em Y atualizada na estrutura
					FMULP 	ST1, 	ST

					MOV 	EAX, 	[EBP + 16]
					FLD 	DWORD [EAX + ECX * 4]

					FADDP	ST1,	ST

					FSTP 	DWORD [EAX + ECX * 4]

					POPA
					RET

	

fResultante:		;os indices estao em EBX e ECX
							
					PUSHA 							

					MOV 	EAX, 	[EBP + 8]				;massa
					MOV 	EDX, 	[EBP + 12]				;x
					MOV 	EDI, 	[EBP + 16]				;y

					FLD 	DWORD [EBP + 44]		 				;carregando o valor de G

					FLD 	DWORD [EAX + EBX * 4] 			;massa do primeiro
					FMULP 	ST1, 	ST

					FLD 	DWORD [EAX + ECX * 4] 			;massa do segundo
					FMULP 	ST1, 	ST 						;ST = G * m1 * m2

					FLD 	DWORD [EDX + EBX * 4]
					FLD 	DWORD [EDX + ECX * 4]
					FSUBP 	ST1,	ST
					FMUL 	ST, 	ST 						;deltaX ^ 2

					FLD 	DWORD [EDI + EBX * 4]
					FLD 	DWORD [EDI + ECX * 4]
					FSUBP 	ST1,	ST
					FMUL 	ST, 	ST						;deltaY ^ 2


					FADDP 	ST1,	ST
					FSQRT 									;ST = distAB	

					FLD1 	
					FMUL 	ST, 	ST1
					FMUL 	ST, 	ST
					FMULP 	ST1, 	ST 						;ST = distAB ^ 3, ST1 = G * m1 * m2

					FDIVP 	ST1, 	ST 						;daqui para frente diferencia o X do Y

												
					FLD 	DWORD [EDX + ECX * 4]	
					FLD 	DWORD [EDX + EBX * 4]	
					FSUBP 	ST1,	ST 						;deltaX de forma com que direcione o angulo
					FMUL 	ST, 	ST1 					;forca calculada em X

					MOV 	EAX, 	[EBP + 28]				;fx

					FLD 	DWORD [EAX + EBX * 4] 	
					FADD 	ST,		ST1 	 				;forca atual em X, somada com a anterior
					FSTP 	DWORD [EAX + EBX * 4]			;att Fx de EBX

					FLD 	DWORD [EAX + ECX * 4]
					FXCH 	ST1
					FSUBP 	ST1, 	ST
					FSTP 	DWORD [EAX + ECX * 4]			;att Fx de ECX


					FLD 	DWORD [EDI + ECX * 4] 			;delta y "invertido"
					FLD 	DWORD [EDI + EBX * 4]
					FSUBP 	ST1,	ST
					FMULP 	ST1, 	ST 						;forca em y calculada

					MOV 	EAX, 	[EBP + 32]				;fy

					FLD 	DWORD [EAX + EBX * 4]
					FADD 	ST, 	ST1
					FSTP 	DWORD [EAX + EBX * 4]

					FLD 	DWORD [EAX + ECX * 4]
					FXCH 	ST1
					FSUBP 	ST1, 	ST
					FSTP 	DWORD [EAX + ECX * 4]  

					POPA
					RET