#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script will combine all featureCounts results files for differential expression analysis
## Creation date : 12-11-2025
## Last Update : 13-11-2025
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="run_DE"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/mmeka/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/mmeka/RNAseq_project/.log/output/%x_%j.out

#Loading the config file
source /data/users/mmeka/RNAseq_project/scripts/00-configs.sh

#Path to merged featureCounts files
MERGED_FCOUNTS_DIR="${RESULTS_DIR}/summary/DE_Analysis"
mkdir -p $MERGED_FCOUNTS_DIR

#Combine all featureCounts files from all samples
sample_id="${SAMPLE_ID_LIST[0]}"
cat  "${RESULTS_DIR}/${sample_id}/hisat2/${sample_id}.featurecounts.csv" > "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv"

for idx in `seq 1 14`; do 
    sample_id="${SAMPLE_ID_LIST[${idx}]}"
    join -t, -1 1 -2 1 "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv" "${RESULTS_DIR}/${sample_id}/hisat2/${sample_id}.featurecounts.csv" > \
    "${MERGED_FCOUNTS_DIR}/tmp.csv"

    cat "${MERGED_FCOUNTS_DIR}/tmp.csv" > "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv"

done 

rm "${MERGED_FCOUNTS_DIR}/tmp.csv"

#Run Differential Expression for our samples 
apptainer exec  "${PATH_CONTAINER_DIR}/${DESEQ2_IMG}.sif" \
    Rscript "${WORKING_DIR}/scripts/09-run_DESeq2_all_samples.R" \
    "${MERGED_FCOUNTS_DIR}/featureCounts_all_samples.csv" \
    "${METADATA_FILE}" "${MERGED_FCOUNTS_DIR}"
