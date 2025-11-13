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
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/mmeka/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/mmeka/RNAseq_project/.log/output/%x_%j.out

THREADS=$SLURM_CPUS_PER_TASK

#Loading the config file
source /data/users/mmeka/RNAseq_project/scripts/00-configs.sh

#Go to REFSEQ Directory 
cd "${REFSEQ_DIR}"

#First extract splice sites and exon regions 
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" hisat2_extract_splice_sites.py "${REFSEQ_NAME}.gtf" > "${REFSEQ_NAME}.ss"

apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" hisat2_extract_exons.py "${REFSEQ_NAME}.gtf" > "${REFSEQ_NAME}.exon"


#Perform the HISAT2 Indexing of our reference (fasta file)
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" hisat2-build -p $THREADS --ss "${REFSEQ_NAME}.ss" --exon "${REFSEQ_NAME}.exon" \
 "${REFSEQ_NAME}.fa" "${REFSEQ_NAME}.idx"