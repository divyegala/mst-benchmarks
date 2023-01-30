#!/bin/bash

# download and extract datasets
road_datasets=("USA-road-d.NY.gr" "USA-road-d.BAY.gr" "USA-road-d.COL.gr" "USA-road-d.FLA.gr" \
               "USA-road-d.NW.gr" "USA-road-d.NE.gr" "USA-road-d.CAL.gr" "USA-road-d.LKS.gr" \
               "USA-road-d.E.gr" "USA-road-d.W.gr" "USA-road-d.CTR.gr" "USA-road-d.USA.gr")

for road in ${road_datasets[@]}; do
    bash datasets/get_and_extract_datasets.sh ${road}
done

# running rapids benchmarks
cd cugraph
# get cugraph dev env, useful later as well
conda env create -n rapids-bench python=3.8 --file=conda/environments/cugraph_dev_cuda11.5.yml
conda run -n rapids-bench bash build.sh --skip_cpp_tests --without_cugraphops
for road in ${road_datasets[@]}; do
    echo ${road} >> ../out.txt
    conda run -n rapids-bench python run_rapids_bench.py "../datasets/${road}" | grep -E "RAPIDS Finished in: [0-9]+" >> ../out.txt
done
cd ..


# running sousa benchmarks
cd sousa-2015
nvcc -Iinclude/ -Imoderngpu/include/ apps/boruvka_gpu/main.cu src/BoruvkaUMinho_GPU.cu src/cu_CSR_Graph.cu moderngpu/src/mgpucontext.cu moderngpu/src/mgpuutil.cpp -o BoruvkaUMinho_GPU
export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH
for road in ${road_datasets[@]}; do
    echo ${road} >> ../out.txt
    conda run -n rapids-bench python create_sousa_dataset.py "../datasets/${road}" ${road}
    ./BoruvkaUMinho_GPU ${road} 512 | grep -E "Sousa Finished in: [0-9]+" >> ../out.txt
    rm ${road}
done
rm BoruvkaUMinho_GPU
cd ..
