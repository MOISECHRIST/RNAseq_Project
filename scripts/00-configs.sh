#!/bin/bash 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this configuration file, I will set up all the global paths and variables that will be used in 
##                this project and import all the useful modules needed for it.
## Creation date : 02-11-2025
## Last Update : 13-11-2025
##------------------------------------------------------------------------

##------------------------------------------------------------------------
## Set up path for working directory
##------------------------------------------------------------------------

#Define the path to our working directory
WORKING_DIR=/data/users/mmeka/RNAseq_project

##------------------------------------------------------------------------
## Set up path for all scripts
##------------------------------------------------------------------------

if [[ ":$PATH:" != *":${WORKING_DIR}/scripts:"* ]]; then
  export PATH="${WORKING_DIR}/scripts:$PATH"
fi

##------------------------------------------------------------------------
## Set up path and variables for our dataset (fastq and refseq files) and metadata
##------------------------------------------------------------------------

#Define the path to our data directory
DATA_DIR=${WORKING_DIR}/data

if [ ! -d "$DATA_DIR" ]; then 
    mkdir $DATA_DIR
fi

#Check if there is a link to the dataset containing fastq files
DATASET_DIR="$DATA_DIR"/dataset
if [ ! -d "$DATASET_DIR" ]; then 
    ln -s /data/courses/rnaseq_course/toxoplasma_de/reads_Lung "$DATASET_DIR"
fi

#Define the list of sample id  
SAMPLE_ID_LIST=($(ls $DATASET_DIR/*.fastq.gz | cut -d"/" -f8 | cut -d_ -f 1 | sort | uniq))

#Define the path to metadata file
METADATA_FILE=${DATA_DIR}/metadata.csv

#Define path to reference fasta, gtf and gff3 files 
REFSEQ_DIR="$DATA_DIR"/refseq

#Define variable with reference sequence name
REFSEQ_NAME="Mus_musculus.GRCm39.115"

#Check if there is refseq fasta file 
if [ ! -f "${REFSEQ_DIR}/${REFSEQ_NAME}.fa" ]; then 
    cd "${REFSEQ_DIR}"
    wget https://ftp.ensembl.org/pub/release-115/fasta/mus_musculus/dna/Mus_musculus.GRCm39.dna.primary_assembly.fa.gz 
    gunzip Mus_musculus.GRCm39.dna.primary_assembly.fa.gz
    mv Mus_musculus.GRCm39.dna.primary_assembly.fa "${REFSEQ_NAME}.fa"
fi

#Check if there is refseq gtf file 
if [ ! -f "${REFSEQ_DIR}/${REFSEQ_NAME}.gtf" ]; then 
    cd "${REFSEQ_DIR}"
    wget https://ftp.ensembl.org/pub/release-115/gtf/mus_musculus/Mus_musculus.GRCm39.115.gtf.gz 
    gunzip Mus_musculus.GRCm39.115.gtf.gz 
fi

#Check if there is refseq gff3 file 
if [ ! -f "${REFSEQ_DIR}/${REFSEQ_NAME}.gff3" ]; then 
    cd "${REFSEQ_DIR}"
    wget https://ftp.ensembl.org/pub/release-115/gff3/mus_musculus/Mus_musculus.GRCm39.115.gff3.gz 
    gunzip Mus_musculus.GRCm39.115.gff3.gz
fi

##------------------------------------------------------------------------
## Set up path for results and logs
##------------------------------------------------------------------------

#Define the path to our results directory
RESULTS_DIR=${WORKING_DIR}/results

#Then Create the results directory if required 
if [ ! -d "$RESULTS_DIR" ]; then 
    mkdir $RESULTS_DIR
fi

#Set up our directories for logs
OUTPUT_LOG=${WORKING_DIR}/.log/output
ERROR_LOG=${WORKING_DIR}/.log/errors

mkdir -p "$OUTPUT_LOG" "$ERROR_LOG"

##------------------------------------------------------------------------
## Set up the path for containers
##------------------------------------------------------------------------

PATH_CONTAINER_DIR="$WORKING_DIR"/container

if [ ! -d "$PATH_CONTAINER_DIR" ]; then 
    mkdir $PATH_CONTAINER_DIR
fi

#Create symbolics link for images from /containers/apptainer
IBU_CONTAINER_DIR=/containers/apptainer

FASTQC_IMG=fastqc-0.12.1
HISAT2_SAMTOOLS_IMG=hisat2_samtools_408dfd02f175cd88

if [ ! -f "${PATH_CONTAINER_DIR}/${FASTQC_IMG}.sif" ]; then
    ln -s "${IBU_CONTAINER_DIR}/fastqc-0.12.1.sif" "${PATH_CONTAINER_DIR}/fastqc-0.12.1.sif"
fi

if [ ! -f "${PATH_CONTAINER_DIR}/${HISAT2_SAMTOOLS_IMG}.sif" ]; then
    ln -s "${IBU_CONTAINER_DIR}/hisat2_samtools_408dfd02f175cd88.sif" "${PATH_CONTAINER_DIR}/hisat2_samtools_408dfd02f175cd88.sif"
fi

#Pull required images 
MULTIQC_IMG=multiqc_1.32--pyhdfd78af_1

if [ ! -f "${PATH_CONTAINER_DIR}/${MULTIQC_IMG}.sif" ]; then 
    cd $PATH_CONTAINER_DIR
    apptainer pull docker://quay.io/biocontainers/multiqc:1.32--pyhdfd78af_1
fi

RSUBREAD_IMG=bioconductor-rsubread_2.20.0--r44h15a9599_1

if [ ! -f "${PATH_CONTAINER_DIR}/${RSUBREAD_IMG}.sif" ]; then 
    cd $PATH_CONTAINER_DIR
    apptainer pull docker://quay.io/biocontainers/bioconductor-rsubread:2.20.0--r44h15a9599_1
fi

DESEQ2_IMG=bioconductor-deseq2_1.46.0--r44he5774e6_1

if [ ! -f "${PATH_CONTAINER_DIR}/${DESEQ2_IMG}.sif" ]; then
    cd $PATH_CONTAINER_DIR
    apptainer pull docker://quay.io/biocontainers/bioconductor-deseq2:1.46.0--r44he5774e6_1
fi


RTRACKLAYER_IMG=bioconductor-rtracklayer_1.66.0--r44h15a9599_1

if [ ! -f "${PATH_CONTAINER_DIR}/${RTRACKLAYER_IMG}.sif" ]; then
    cd $PATH_CONTAINER_DIR
    apptainer pull docker://quay.io/biocontainers/bioconductor-rtracklayer:1.66.0--r44h15a9599_1
fi