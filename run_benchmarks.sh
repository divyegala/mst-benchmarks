#!/bin/bash

# download and extract datasets
road_datasets=("USA-road-d.NY.gr")

for road in ${road_datasets[@]}; do
    bash datasets/get_and_extract_datasets.sh ${road}
done

# running vineet benchmarks
cd vineet-2009
g++ Converter.cpp -o converter
nvcc MST/main.cu -o MST/vineet
for road in ${road_datasets[@]}; do
    ./converter "../datasets/${road}" ${road}
    ./MST/vineet ${road}
    rm ${road}
done
rm converter
rm MST/vineet
cd ..

# get cugraph
# yes | conda create -n rapids-22.12 -c rapidsai -c conda-forge -c nvidia  \
#     cugraph=22.12 python=3.9 cudatoolkit=11.5

# running sousa benchmarks
cd sousa-2015
nvcc -Iinclude/ -Imoderngpu/include/ apps/boruvka_gpu/main.cu src/BoruvkaUMinho_GPU.cu src/cu_CSR_Graph.cu moderngpu/src/mgpucontext.cu moderngpu/src/mgpuutil.cpp -o BoruvkaUMinho_GPU
export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH
for road in ${road_datasets[@]}; do
    conda run -n rapids-22.12 python create_sousa_dataset.py "../datasets/${road}" ${road}
    ./BoruvkaUMinho_GPU ${road} 512
    rm ${road}
done
rm BoruvkaUMinho_GPU
cd ..

for road in ${road_datasets[@]}; do
    rm "datasets/${road}"
done