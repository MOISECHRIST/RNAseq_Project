#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run the feature counts for each sample
## Creation date : 11-11-2025
## Last Update : 11-11-2025
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="feature_count"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/mmeka/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/mmeka/RNAseq_project/.log/output/%x_%j.out
#SBATCH --array=0-14

#Loading the config file
source /data/users/mmeka/RNAseq_project/scripts/00-configs.sh


#Run the feature count R script
apptainer exec "${PATH_CONTAINER_DIR}/${RSUBREAD_IMG}.sif" \
    Rscript "${WORKING_DIR}/scripts/07-run_feature_count.R" \
    "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.sorted.bam" \
    "${REFSEQ_DIR}/${REFSEQ_NAME}.gtf" \
    "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.featurecounts.csv"