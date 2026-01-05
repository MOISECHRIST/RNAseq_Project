#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run the sample alignment with HISAT2
## Creation date : 07-11-2025
## Last Update : 05-01-2026
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="hisat2_alignment"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/%u/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/%u/RNAseq_project/.log/output/%x_%j.out
#SBATCH --array=0-14

THREADS=$SLURM_CPUS_PER_TASK

#Loading the config file
source /data/users/{$USER}/RNAseq_project/scripts/00-configs.sh

#First, create an output folder for the analyzed sample 
mkdir -p "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2"

#Move to the sample result folder
cd  "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/"

#Ling refseq in this file
ln -s ${REFSEQ_DIR}/${REFSEQ_NAME}.* .

#Run HISAT2 alignment task 
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" hisat2 -p $THREADS --dta \
    -x "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${REFSEQ_NAME}.idx" \
    -1 "${DATASET_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}_1.fastq.gz" \
    -2 "${DATASET_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}_2.fastq.gz" \
    -S "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.sam"