# Run and save y-values
echo "Saving y-values..."
gcc wave.c -o wave.out -lm -Ofast -D'SAVE'
for i in $(seq 1 5); do
	time ./wave.out;
done

# Run without saving y-values
echo "Not saving y-values..."
gcc wave.c -o wave.out -lm -Ofast
for i in $(seq 1 5); do
	time ./wave.out;
done
