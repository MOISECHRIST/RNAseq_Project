#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run the quality control for each sample 
## Last Update : 04-11-2025
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="fastqc"
#SBATCH --mem-per-cpu=500MB
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --error=/data/users/mmeka/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/mmeka/RNAseq_project/.log/output/%x_%j.err
#SBATCH --array=0-14


#Loading the config file
source /data/users/mmeka/RNAseq_project/scripts/00-configs.sh

#First, create an output folder for the analyzed sample 
mkdir -p "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/fastqc"

#Run fastqc for my
fastqc "${DATASET_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}_1.fastq.gz" \
    "${DATASET_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}_2.fastq.gz" \
    -o "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/fastqc"

