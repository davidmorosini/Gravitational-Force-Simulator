#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "simuladorc.h"

#define G 6.674e-11
#define TAM 1000
	
void criaVetor(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int * qtdP, float * t, int * qtdI);
long interacaoGravitacional(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float qtdI, float tempo, float g);

//funções externas
unsigned long long getclock(); //funcao utilizando RDTSC escrita em assembly
void simulador(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float tempo, float g);


void help(void){
	printf("\nPASSOU\n");
}

int main(){
	unsigned qtdP, qtdI, i;
	float tempo, x[TAM], y[TAM], vx[TAM], vy[TAM];
	float * fx = (float *)calloc(TAM, sizeof(float));
	float * fy = (float *)calloc(TAM, sizeof(float));
	float * m = (float *)calloc(TAM, sizeof(float));	
	criaVetor(m, x, y, vx, vy, fx, fy, &qtdP, &tempo, &qtdI);
	long qtdClocks = interacaoGravitacional(m, x, y, vx, vy, fx, fy, qtdP, qtdI, tempo, G);

	printf("\n%ld", qtdClocks);
	for(i = 0; i < qtdP; i++)
		printf("\n%.10f\t%.10f\t%.10f\t%.10f", x[i], y[i], vx[i], vy[i]);
	printf("\n");
	return 0;
}

/*
Cabeçalho da função criaVetor
retorno (void) : O modo como as informações são repassadas para o simulador, impede que se tenha um único
retorno de todos os conjuntos de dados, logo, a passagem por referencia dos vetores alocados dentro da funcao
main, são o suficiente para alteralos.

Como o scanf retorna o número de argumentos lidos, e a especificação do trabalho diz que para indicar o fim das
particulas se usa uma linha em branco, caso o scanf não leia nada, ele termina a execução.
*/
void criaVetor(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int * qtdP, float * t, int * qtdI){
	unsigned i = 0;
	scanf("%u %f", qtdI, t);
	while(scanf("%f %f %f %f %f", &m[i], &x[i], &y[i], &vx[i], &vy[i]) > 0){
		i++;
	}		
	*qtdP = i; 		//quantidade de particulas
}

/*
Cabeçalho da função interaçãoGravitacional
retorno (long): retorna o tempo médio em clocks obtidos durante a ralização da simulação

A função simulador contida no corpo da função é padrão, sendo linkada a este código em C por meio de
diferentes parametros de compilação.
*/
long interacaoGravitacional(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float qtdI, float tempo, float g){
	int i;
	long c2, c1, total = 0;
	for(i = 0; i < qtdI; i++){
		c1 = getclock();
		simulador(m, x, y, vx, vy, fx, fy, qtdP, tempo, g);
		c2 = getclock();
		total += (c2 - c1);
	}
	total = (long)(total / qtdI);
	return total;
}