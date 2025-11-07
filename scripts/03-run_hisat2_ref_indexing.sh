#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run reference indexing using hisat2 
## Creation date : 07-11-2025
## Last Update : 07-11-2025
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="hisat2_index"
#SBATCH --mem=25GB
#SBATCH --cpus-per-task=10
#SBATCH --time=10:00:00
#SBATCH --error=/data/users/mmeka/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/mmeka/RNAseq_project/.log/output/%x_%j.out

THREADS=$SLURM_CPUS_PER_TASK

#Loading the config file
source /data/users/mmeka/RNAseq_project/scripts/00-configs.sh

#Go to REFSEQ Directory 
cd "${REFSEQ_DIR}"

#Perform the HISAT2 Indexing of our reference (fasta file)
hisat2-build -p $THREADS "${REFSEQ_NAME}.fa.gz" "${REFSEQ_NAME}"