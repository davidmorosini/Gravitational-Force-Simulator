#include "simuladorc.h"
#include <stdlib.h>
#include <math.h>

void fResultanteAB(float * m, float * x, float * y, float *fx, float * fy, int iA, int iB, float g){
	float deltaX = x[iB] - x[iA]; 		//a ordem da subtração deve ser esta para que sinal resultante indique
	float deltaY = y[iB] - y[iA];		//a direção da força.

	float r = sqrt((deltaX * deltaX) + (deltaY * deltaY)); 		//distancia entra os dois pontos
	float aux = 0;

	if(r != 0){ 	//para que caso as particulas estejam no mesmo lugar, ñão possuir fres
		aux = (g * m[iA] * m[iB] / (r * r * r));
	}

	/*Considerando que F = G*Ma*Mb/r*r, e que
	Fx = F * Cos(0), Fy = F * Sen(0),  logo:
	Fx = F * deltaX / r  e   Fy = F * deltaY / r
	o que diferencia Fx de Fy, é o multiplicador da equacao restante:
	G*Ma*Mb/(r*r*r), esses multiplicadores são justamente
	deltaX e deltaY
	*/

	float fresX = aux * deltaX;			//F resultante em x
	float fresY = aux * deltaY;			//F resultante em y

	fx[iA] += fresX;
	fx[iB] -= fresX; 					//Fab = -Fba

	fy[iA] += fresY;
	fy[iB] -= fresY;
}

void ajustaInfs(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float tempo){
	int i;
	float ax, ay, vxNovo, vyNovo, xNovo, yNovo;
	
	for(i = 0; i < qtdP; i++){	
		ax = fx[i] / m[i];
		vxNovo = vx[i] + ax * tempo;
		xNovo = x[i] + (vxNovo * tempo);

		ay = fy[i] / m[i];
		vyNovo = vy[i] + ay * tempo;
		yNovo = y[i] + (vyNovo * tempo);

		/*
		a (aceleração) = F (força) / m (massa)
		v (velocidade) = v0 (velocidade inicial) + a * t (tempo)
		p (posição) = p0 (posição inicial) + v * t 
		*/

		x[i] = xNovo;
		vx[i] = vxNovo;
		fx[i] = 0;

		y[i] = yNovo;
		vy[i] = vyNovo;
		fy[i] = 0;					/*ambas as forças são zeradas a cada fim de interação, para que uma 
									interação não interfira na outra*/		
	}
	
}

void simulador(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float tempo, float g){
	int i, j;
	for(i = 0; i < qtdP - 1; i++)
		for(j = i + 1; j < qtdP; j++)
				fResultanteAB(m, x, y, fx, fy, i, j, g);	
				/*calcula a resultante de forças baseando nos valores iniciais de cada iteração*/
	ajustaInfs(m, x, y, vx, vy, fx, fy, qtdP, tempo);
	/*E só ao fim do calculo das forças resultantes, pode se alterar as posições e velocidades de cada particula*/
}	

