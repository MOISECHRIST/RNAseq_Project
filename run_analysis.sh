#!/bin/bash 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run the whole Bulk RNAseq analysis for all samples 
## Last Update : 03-11-2025
##------------------------------------------------------------------------


##------------------------------------------------------------------------
## Run Quality Control
##------------------------------------------------------------------------

#FastQC
sbatch scripts/01-run_quality_control.sh 

#Check if FastQC was successful 
if [ $? -ne 0 ]; then
    echo "FastQC Quality Control failed."
    exit 1
fi

#MultiQC for the First QC
sbatch scripts/02-run_multiqc_first_qc.sh
