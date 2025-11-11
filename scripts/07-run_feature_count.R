#!/usr/local/bin/R 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this file I will run feature counts for one bam file.
##              This script takes the following parameters:
##                  (1) Path to the BAM file
##                  (2) Path to the GTF file
##                  (3) Path to the output CSV file
## Creation date : 11-11-2025
## Last Update : 11-11-2025
##------------------------------------------------------------------------

#Load package for feature count 
library("Rsubread")

args <- commandArgs(trailingOnly=TRUE)

#Check whether the number of parameters is 3 
if(length(args)!=3){
  print("In this file I will run feature counts for one bam file.")
  print("This script takes the following parameters:")
  print("   (1) Path to the BAM file")
  print("   (2) Path to the GTF file")
  print("   (3) Path to the output CSV file", sep="\n")
  stop("Error: Required arguments are not provided.", call.=FALSE)
} 

#fonction to check the file extension
check_file_extension <- function(file_path, extension){
  file_name <- basename(file_path)
  file_name_vect <- strsplit(file_name, "\\.")[[1]]
  l <- length(file_name_vect)

  return(file_name_vect[l]==extension)
}

#Check whether the files passed as parameters exist and have the correct extensions
check_ext <- c(check_file_extension(args[1],"bam"),
              check_file_extension(args[2],"gtf"),
              check_file_extension(args[3],"csv"))

check_exist <- c(file.exists(args[1]),
                file.exists(args[2]))

if((sum(check_ext)!=3) && (sum(check_exist)!=2)){
  print("In this file I will run feature counts for one bam file.")
  print("This script takes the following parameters:")
  print("   (1) Path to the BAM file")
  print("   (2) Path to the GTF file")
  print("   (3) Path to the output CSV file", sep="\n")
  stop("Error: Files provided do not exist", call.=FALSE)
}

#store the parameters values
bam_file_path <- args[1]

annotation_gtf <- args[2]

counts_output_path <- args[3]

#Run the feature counts
fc_PE<-featureCounts(bam_file_path,annot.ext=annotation_gtf,
isGTFAnnotationFile = TRUE, isPairedEnd=TRUE)

#Clean the count table
counts_df <- as.data.frame(fc_PE$counts)

sample_id <- strsplit(colnames(counts_df)[1],"\\.")[[1]][1]

counts_df$sample_id <- rep(sample_id, nrow(counts_df))

colnames(counts_df) <- c("counts","sample_id")

counts_df$gene_id <- row.names(counts_df)

counts_df <- counts_df[,c(3,2,1)]

print(head(counts_df))

#Save the feature counts 
write.csv(counts_df, counts_output_path, row.names = F)