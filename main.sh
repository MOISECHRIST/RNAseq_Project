#!/bin/bash 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This bash script I will run the whole Bulk RNAseq analysis for all samples 
## Creation date : 02-11-2025
## Last Update : 08-11-2025
##------------------------------------------------------------------------


##------------------------------------------------------------------------
## Step 1 : Run Quality Control of Reads
##------------------------------------------------------------------------

#FASTQC : QC of reads 
fastqc_job_id=$(sbatch scripts/01-run_quality_control.sh | awk '{ print $4 }')
echo "Launched Job : fastqc ($fastqc_job_id)"

##------------------------------------------------------------------------
## Step 2 : Run Alignment of Reads to the reference 
##------------------------------------------------------------------------

#HISAT2-BUILD : Indexe the reference genome 
hisat2_index_job_id=$(sbatch scripts/03-run_hisat2_ref_indexing.sh  | awk '{ print $4 }')
echo "Launched Job : hisat2_index ($hisat2_index_job_id)"

#HISAT2 : Alignment of reads to the reference 
hisat2_alignment_job_id=$(sbatch --dependency="afterok:$hisat2_index_job_id" scripts/04-run_hisat2_alignment.sh | awk '{ print $4 }')
echo "Launched Job : hisat2_alignment ($hisat2_alignment_job_id)"

#SAMTOOLS : SAM files processing (SAM -> BAM; sorting BAM and indexing the BAM)
sam_processing_job_id=$(sbatch --dependency="afterok:$hisat2_alignment_job_id" scripts/05-convert_to_bam_sort_index.sh | awk '{ print $4 }')
echo "Launched Job : sam_processing ($sam_processing_job_id)"

#SAMTOOLS : BAM files QC
bam_qc_job_id=$(sbatch --dependency="afterok:$sam_processing_job_id" scripts/06-run_qc_alignment.sh | awk '{ print $4 }')
echo "Launched Job : bam_qc ($bam_qc_job_id)"

##------------------------------------------------------------------------
## Step 3 : Merge all Quality Control step in one report
##------------------------------------------------------------------------

#MULTIQC : merge all QC report
multiqc_job_id=$(sbatch --dependency=singleton sbatch scripts/02-run_multiqc_merge_qc.sh | awk '{ print $4 }')
echo "Launched Job : multiqc ($multiqc_job_id)"