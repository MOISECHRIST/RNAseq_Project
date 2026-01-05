#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script will combine all featureCounts results files for differential expression analysis
## Creation date : 12-11-2025
## Last Update : 05-01-2026
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="run_DE"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/%u/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/%u/RNAseq_project/.log/output/%x_%j.out

#Loading the config file
source /data/users/{$USER}/RNAseq_project/scripts/00-configs.sh

#Path to merged featureCounts files
MERGED_FCOUNTS_DIR="${RESULTS_DIR}/summary/DE_Analysis"
mkdir -p $MERGED_FCOUNTS_DIR

#Clean featureCounts results
tail -n+2 "${RESULTS_DIR}/summary/featureCounts/genes" | cut -f1,7- \
 | head -n1 |sed 's|/data/users/[^/]*/RNAseq_project/results/summary/featureCounts/||g' \
 | sed 's/.sorted.bam//g'  | tr "\t" "," > "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv" 

tail -n+3 "${RESULTS_DIR}/summary/featureCounts/genes" | cut -f1,7- | tr "\t" "," >> "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv"



#Run Differential Expression for our samples 
apptainer exec  "${PATH_CONTAINER_DIR}/${DESEQ2_IMG}.sif" \
    Rscript "${WORKING_DIR}/scripts/09-run_DESeq2_all_samples.R" \
    "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv" \
    "${METADATA_FILE}" "${MERGED_FCOUNTS_DIR}"
