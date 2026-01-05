#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run the feature counts for all sample
## Creation date : 11-11-2025
## Last Update : 20-11-2025
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="feature_count"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/%u/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/%u/RNAseq_project/.log/output/%x_%j.out

THREADS=$SLURM_CPUS_PER_TASK

#Loading the config file
source /data/users/{$USER}/RNAseq_project/scripts/00-configs.sh

mkdir -p "${RESULTS_DIR}/summary/featureCounts/"
for i in `seq 0 14`; do
    if [ ! -f "${RESULTS_DIR}/summary/featureCounts/${SAMPLE_ID_LIST[${i}]}.sorted.bam" ]; then
        ln -s "${RESULTS_DIR}/${SAMPLE_ID_LIST[${i}]}/hisat2/${SAMPLE_ID_LIST[${i}]}.sorted.bam"  \
        "${RESULTS_DIR}/summary/featureCounts/${SAMPLE_ID_LIST[${i}]}.sorted.bam"
    fi 
done 

INPUT_FILES=`ls ${RESULTS_DIR}/summary/featureCounts/*.sorted.bam`

#Run the feature count R script
apptainer exec --bind /data/ "${PATH_CONTAINER_DIR}/${RSUBREAD_IMG}.sif" \
     featureCounts -T $THREADS -p --countReadPairs -t exon -s 2 -g gene_id \
     -a "${REFSEQ_DIR}/${REFSEQ_NAME}.gtf" \
     -o "${RESULTS_DIR}/summary/featureCounts/genes" \
     $INPUT_FILES 