#!/bin/bash

basep=$HOME/CMSE-401/HW/HW-02/edge_detection-master
in=images
out="out-images"

export TIMEFORMAT=%R

time10 () {
    total=0
    for i in {1..10}; do
	result=$((time $@) 2>&1)
	timeres=$(echo $result | tail -1)
	total=$(echo "$total+$timeres" | bc -l)
    done
    echo $(echo "$total/10" | bc -l)
}

for fpath in $basep/$in/*; do
    fname=$(basename $fpath)
    ftime=$((time10 $basep/process ${basep}/${in}/${fname} ${basep}/${out}/${fname}) 2>&1)
    echo $fname $ftime
done
