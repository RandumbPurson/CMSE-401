#!/bin/bash

repo=edge_detection-master
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

for fpath in $repo/$in/*; do
    fname=$(basename $fpath)
    ftime=$((time10 $repo/process ${repo}/${in}/${fname} ${repo}/${out}/${fname}) 2>&1)
    echo $fname $ftime
done
