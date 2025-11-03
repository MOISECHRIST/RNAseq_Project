#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will aggregate FASTQC quality control for all samples 
## Last Update : 03-11-2025
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="multiqc1"
#SBATCH --mem-per-cpu=500MB
#SBATCH --cpus-per-task=4
#SBATCH --time=01:00:00
#SBATCH --error=/data/users/mmeka/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/mmeka/RNAseq_project/.log/output/%x_%j.err

#Loading the config file
./00-config.sh

#First, create an output folder quality control summary
mkdir -p "${RESULTS_DIR}/summary/quality_control"

#Run multiqc 
multiqc "${RESULTS_DIR}/." -o "${RESULTS_DIR}/summary/quality_control"