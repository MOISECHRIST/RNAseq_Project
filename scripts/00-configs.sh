#!/bin/bash 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this configuration file, I will set up all the global paths and variables that will be used in 
##                this project and import all the useful modules needed for it.
## Creation date : 02-11-2025
## Last Update : 04-11-2025
##------------------------------------------------------------------------

##------------------------------------------------------------------------
## Set up path for working directory
##------------------------------------------------------------------------

#Define the path to our working directory
WORKING_DIR=/data/users/mmeka/RNAseq_project

##------------------------------------------------------------------------
## Set up path for all scripts
##------------------------------------------------------------------------

mkdir -p "${WORKING_DIR}/scripts"

if [[ ":$PATH:" != *":${WORKING_DIR}/scripts:"* ]]; then
  export PATH="${WORKING_DIR}/scripts:$PATH"
fi

##------------------------------------------------------------------------
## Set up path and variables for our dataset and metadata
##------------------------------------------------------------------------

#Define the path to our dataset directory
DATA_DIR=${WORKING_DIR}/data

if [ ! -d "$DATA_DIR" ]; then 
    mkdir $DATA_DIR
fi

#Check if there is a link to the dataset containing fastq files
DATASET_DIR="$DATA_DIR"/dataset
if [ ! -d "$DATASET_DIR" ]; then 
    ls -s /data/courses/rnaseq_course/toxoplasma_de/reads_Lung "$DATASET_DIR"
fi

#Define the list of sample id  
SAMPLE_ID_LIST=($(ls $DATASET_DIR/*.fastq.gz | cut -d"/" -f8 | cut -d_ -f 1 | sort | uniq))

#Define the path to metadata file
METADATA_FILE=${DATA_DIR}/metadata.csv

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
## Loading modules for RNAseq analysis
##------------------------------------------------------------------------

#Loading modules for quality control step
module add FastQC/0.11.9-Java-11
module add MultiQC/1.11-foss-2021a 


