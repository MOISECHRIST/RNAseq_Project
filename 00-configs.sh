#!/bin/bash 

##---------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this file, I will create the variables that will contain 
##              the paths to the working directory, the dataset and outputs for all steps in this project 
##              and also parameters for certains analysis
## Last Update : 02-11-2025
##---------------------------------------

##------------------------------------------------------------------------
## Set up path for working directory and the dataset useful information 
##------------------------------------------------------------------------

#Define the path to our working directory
WORKING_DIR=/data/users/mmeka/RNAseq_project/

#Define the path to our dataset directory
DATASET_DIR=/data/courses/rnaseq_course/toxoplasma_de/reads_Lung/

#Define the list of sample id  
SAMPLE_ID_LIST=$(ls $DATASET_DIR/*.fastq.gz | cut -d"/" -f8 | cut -d_ -f 1 | sort | uniq)


