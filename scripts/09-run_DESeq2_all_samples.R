#!/usr/local/bin/R 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this file I will run differential expression analysis.
##              This script takes the following parameters:
##                  (1) Path to the merged feature counts results
##                  (2) Path to metadata csv file
##                  (3) Path to the output directory without the '/' at the end
## Creation date : 12-11-2025
## Last Update : 13-11-2025
##------------------------------------------------------------------------

#Load package for differential expression analysis
library("DESeq2")

args <- commandArgs(trailingOnly=TRUE)

#Check whether the number of parameters is 3 
if(length(args)!=3){
  print("In this file I will run differential expression analysis.")
  print("This script takes the following parameters:")
  print("   (1) Path to the merged feature counts results")
  print("   (2) Path to metadata csv file")
  print("   (3) Path to the output directory without the '/' at the end")
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
check_ext <- c(check_file_extension(args[1],"csv"),
               check_file_extension(args[2],"csv"))

check_exist <- c(file.exists(args[1]),
                 file.exists(args[2]))

if((sum(check_ext)!=2) && (sum(check_exist)!=2)){
  print("In this file I will run differential expression analysis.")
  print("This script takes the following parameters:")
  print("   (1) Path to the merged feature counts results")
  print("   (2) Path to metadata csv file")
  print("   (3) Path to the output directory without the '/' at the end")
  stop("Error: Files provided do not exist or files extension provided are not correct.", call.=FALSE)
}

#store the parameters values
input_featurecount_path <- args[1]
metadata_path <- args[2]
results_dir_path <- args[3]

#read input data 
count_df <- read.csv(input_featurecount_path, header = T, sep = ",", row.names=1)

metadata <- read.csv(metadata_path, sep = ",", header = T, row.names=1)
metadata$batch <- factor(metadata$batch, levels = c("Wildtype", "Double_Knockout"))
metadata$condition <- factor(metadata$condition, levels = c("Control", "Case"))

#Check if all samples in the metadata file are present in our cts_df
check_samples_presence <- all(rownames(metadata) %in% colnames(count_df))
if(! check_samples_presence){
  stop("Error: Something went wrong, all samples present in metadata file are not present in featureCounts results.")
}

count_df <- count_df[, rownames(metadata)]

dds <- DESeqDataSetFromMatrix(countData = count_df,
                              colData = metadata,
                              design = ~ batch + condition + batch:condition)
                  

dds <- DESeq(dds)

print(resultsNames(dds))

save(dds, file=paste(results_dir_path,"differential_expression_model.RData", sep = "/"))

