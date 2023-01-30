# mst-benchmarks

# Requirements
- Anaconda (or Miniconda)

# Cloning this repo
```
git clone --recurse-submodules https://github.com/divyegala/mst-benchmarks.git
```

# Run benchmarks
```
bash run_benchmarks.sh
```
This script needs to be run in a conda initialized shell. It automatically
downloads road-network datasets from the 9th DIMACS challenge.
The output will be written in a text file called `out.txt` in the
root of this repository, where the timings are measured in 
milliseconds unit.