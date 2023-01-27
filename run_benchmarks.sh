#!/bin/bash

road_datasets=("USA-road-d.NY")

# for road in ${road_datasets[@]}; do
#     bash datasets/get_and_extract_datasets.sh ${road}
# done

# running vineet benchmarks
cd vineet-2009
g++ Converter.cpp -o converter
nvcc MST/main.cu -o MST/vineet
for road in ${road_datasets[@]}; do
    ./converter ../datasets/"${road}.gr" "${road}.txt"
    ./MST/vineet "${road}.txt"
    rm "${road}.txt"
done
rm converter
rm MST/vineet
cd ..