export TIMEFORMAT=%R

t=1
for zeros in {1..9}; do
	t="${t}0"
	echo "t=$t"
	result=$((time ./integral-p.out $t) 2>&1)
	pival=$(echo $result | cut -d' ' -f1)
	timeval=$(echo $result | cut -d' ' -f2)
	echo "$pival" >> pi-p.csv
	echo "$timeval" >> time-p.csv
done
