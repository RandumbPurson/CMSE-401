all: pi-p pi

pi: pi.c
	gcc -lm -o pi pi.c

pi-p:
	gcc -lm -fopenmp -o pi-p pi-p.c

clean:
	rm pi
	rm pi-p
