#ifndef SIMULADORC_H
#define SIMULADORC_H

#include <stdlib.h>
#include <math.h>

void simulador(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float tempo, float g);
void fResultanteAB(float * m, float * x, float * y, float *fx, float * fy, int iA, int iB, float g);
void ajustaInfs(float * m, float * x, float * y, float * vx, float * vy, float * fx, float * fy, int qtdP, float tempo);

#endif