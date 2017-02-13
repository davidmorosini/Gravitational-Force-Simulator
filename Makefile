c: main.o simuladorC.o clock.o
	gcc -m32 main.o simuladorC.o clock.o -o main -lm -O0

asm: main.o simuladorAs.o clock.o
	gcc main.o simuladorAs.o clock.o -o main

otim: main.o simuladorC.o clock.o
	gcc main.o simuladorC.o clock.o -o main -lm -Os

sse: main.o simuladorSSE.o clock.o
	gcc main.o simuladorSSE.o clock.o -o main

main.o: main.c
	gcc -c main.c

clock.o: clock.asm
	fasm clock.asm

simuladorC.o: simuladorC.c
	gcc -c simuladorC.c

simuladorAs.o: simuladorAs.asm
	fasm simuladorAs.asm

simuladorSSE.o: simuladorSSE.asm
	fasm simuladorSSE.asm

