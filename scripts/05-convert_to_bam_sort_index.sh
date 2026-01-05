#!/bin/bash

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will convert SAM files into BAM files, sort and index the BAM files
## Creation date : 07-11-2025
## Last Update : 05-01-2026
##------------------------------------------------------------------------


#SBATCH --partition=pibu_el8
#SBATCH --mail-user=moise.meka@students.unibe.ch
#SBATCH --mail-type=start,end,fail
#SBATCH --job-name="sam_processing"
#SBATCH --mem=150GB
#SBATCH --cpus-per-task=16
#SBATCH --time=20:00:00
#SBATCH --error=/data/users/%u/RNAseq_project/.log/errors/%x_%j.err
#SBATCH --output=/data/users/%u/RNAseq_project/.log/output/%x_%j.out
#SBATCH --array=0-14

THREADS=$SLURM_CPUS_PER_TASK

#Loading the config file
source /data/users/{$USER}/RNAseq_project/scripts/00-configs.sh

#Move to the sample result folder
cd  "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/"

#Indexing the reference with Samtools 
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" \
    samtools faidx "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${REFSEQ_NAME}.fa"

#Convert SAM in to bam
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" \
    samtools view -b -@ $THREADS -t "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${REFSEQ_NAME}.fa.fai" \
    "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.sam" > \
    "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.bam"

#Sort BAM file
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" \
    samtools sort -@ $THREADS -o "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.sorted.bam" \
    "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.bam"

#index bam
apptainer exec "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" \
    samtools index -@ $THREADS "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.sorted.bam" 

#Remove intermediate files

rm "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.sam"
rm "${RESULTS_DIR}/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}/hisat2/${SAMPLE_ID_LIST[${SLURM_ARRAY_TASK_ID}]}.bam"