all: gol 

CC:=gcc
EXT:=c
FLAGS:=-lm -lpng16 -O3

gameoflife.o: gameoflife.$(EXT)
	$(CC) $(FLAGS) -c gameoflife.$(EXT) 

png_util.o: png_util.$(EXT)
	$(CC) $(FLAGS) -c png_util.$(EXT)

gol: gameoflife.o png_util.o
	$(CC) $(FLAGS) -o gol gameoflife.o png_util.o

test: gol data.txt
	./gol < data.txt

test2: gol data.txt
	cuda-memcheck ./gol < data.txt

clean:
	rm *.o
	rm gol 

