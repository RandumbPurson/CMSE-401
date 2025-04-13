all: process

2d_wave.o: 2d_wave.c png_util.o
	gcc -fopenmp -lm -l png_util.o -c 2d_wave.c

png_util.o: png_util.c
	gcc -l lpng16 -c png_util.c

process: 2d_wave.o png_util.o
	gcc -fopenmp -o process -lm -l png16 2d_wave.o png_util.o

clean:
	rm *.o
	rm process
