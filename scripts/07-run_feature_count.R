#!/usr/local/bin/R 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this file I will run feature counts for one bam file
## Creation date : 11-11-2025
## Last Update : 11-11-2025
##------------------------------------------------------------------------

#Install required packages
if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

BiocManager::install("Rsubread",ask = F)

install.packages("optparse")

#Load package for optional argument parse 
library("optparse")

#Load package for feature count 
library("Rsubread")


#Define parameters 
parser <- OptionParser(description = "Compute the feature count for alignment file (BAM).")

parser <- add_option(parser, "--annotation", type="character",
                help="Path to the gtf annotation file")

parser <- add_option(parser,  "--input", type="character",
                help="Path to the BAM file")

parser <- add_option(parser,  "--output", type="character",
                help="Path for the output feature counts")

opt <- parse_args(parser)

annotation_gtf <- opt$annotation

bam_file_path <- opt$input

counts_output_path <- opt$output

#Run feature counts
fc_PE<-featureCounts(bam_file_path,annot.ext=annotation_gtf,isPairedEnd=TRUE)

#Save the feature counts 
write.csv(fc_PE$counts,counts_output_path)