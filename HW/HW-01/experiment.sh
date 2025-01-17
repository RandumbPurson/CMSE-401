gcc wave.c -o wave.out -lm
for i in $(seq 1 5); do
	./wave.out;
done
