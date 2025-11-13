#!/usr/local/bin/R 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : In this file I will extract from the GTF file the information about gene (chr, gene_id, gene_name, start, end).
##              This script takes the following parameters:
##                  (1) Path to the GTF file
##                  (2) Path to the output CSV file
## Creation date : 12-11-2025
## Last Update : 13-11-2025
##------------------------------------------------------------------------

#Load package for differential expression analysis
library(rtracklayer)

args <- commandArgs(trailingOnly=TRUE)

#Check whether the number of parameters is 3 
if(length(args)!=2){
  print("In this file I will extract from the GTF file the information about gene (chr, gene_id, gene_name, start, end).")
  print("This script takes the following parameters:")
  print("   (1) Path to the GTF file")
  print("   (2) Path to the output CSV file")
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
check_ext <- c(check_file_extension(args[1],"gtf"),
               check_file_extension(args[2],"csv"))

check_exist <- file.exists(args[1])

if((sum(check_ext)!=2) && (check_exist!=TRUE)){
  print("In this file I will extract from the GTF file the information about gene (chr, gene_id, gene_name, start, end).")
  print("This script takes the following parameters:")
  print("   (1) Path to the GTF file")
  print("   (2) Path to the output CSV file")
  stop("Error: Files provided do not exist or files extension provided are not correct.", call.=FALSE)
}

gtf_path <- args[1]
output_path <- args[2]

gtf_data <- readGFF(gtf_path)

all_genes <- gtf_data[gtf_data$type=="gene",]

all_genes <- all_genes[,c("seqid","gene_id","gene_name","start", "end")]

write.csv(all_genes, output_path, row.names =FALSE)