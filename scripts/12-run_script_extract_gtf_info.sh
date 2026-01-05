#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script will run 11-extract_gene_info_from_gtf.R
## Creation date : 13-11-2025
## Last Update : 05-01-2026
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="extract_gtf_info"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/%u/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/%u/RNAseq_project/.log/output/%x_%j.out

#Loading the config file
source /data/users/{$USER}/RNAseq_project/scripts/00-configs.sh


EXTRACT_RESULTS_DIR="${RESULTS_DIR}/summary/DE_Analysis"

apptainer exec  "${PATH_CONTAINER_DIR}/${RTRACKLAYER_IMG}.sif" \
    Rscript "${WORKING_DIR}/scripts/11-extract_gene_info_from_gtf.R" \
    "${REFSEQ_DIR}/${REFSEQ_NAME}.gtf" \
    "${EXTRACT_RESULTS_DIR}/${REFSEQ_NAME}.csv"