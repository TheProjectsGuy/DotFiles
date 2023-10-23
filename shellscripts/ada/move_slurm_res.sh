#!/bin/bash

# Move a SLURM result file, given the job number
job_num=$1
if [[ -z $job_num ]]; then
    echo "Pass job number to script!"
    exit 1
fi
# Get tar file
scp $USER@ada:/share1/avneesh.mishra/results/slurm_res_${job_num}.tar ./
# Create directory
mkdir $job_num
# Unzip there
tar -xf ./slurm_res_${job_num}.tar -C ./$job_num

# Report
echo "Unzipped job result $job_num to ./$job_num"
