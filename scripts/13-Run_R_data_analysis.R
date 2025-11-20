#!/usr/local/bin/R 

##------------------------------------------------------------------------
## Author : MEKA Moise
## Email : moise.meka@students.unibe.ch
## Description : This script is for data analysis. 
#           Here we take as input ".RData" object from script 09 and then do :
##              -> Data exploration,
##              -> Extract and analyse DE results,
##              -> Overrepresentation analysis.
## Creation date : 20-11-2025
## Last Update : 20-11-2025
##------------------------------------------------------------------------

##------------------------------------------------------------------------
## Step 1 : Set Working Directory
##------------------------------------------------------------------------
setwd("~/Documents/Msc_Bioinf_UniBern/Master-1/Semester-1/RNA Seq Analysis/project/RNAseq_Project")

##------------------------------------------------------------------------
## Step 2 : Import libraries 
##------------------------------------------------------------------------
library(conflicted)
library("DESeq2")
library("clusterProfiler")
library("vsn")
library("pheatmap")
library(ggplot2)
##------------------------------------------------------------------------
## Step 3 : Load data
##------------------------------------------------------------------------
load("results/summary/DE_Analysis/differential_expression_model.RData")
gene.detail <- read.csv("results/summary/DE_Analysis/Mus_musculus.GRCm39.115.csv", 
                        sep=",", header = T)

#A glimpse of our data 
str(dds)
resultsNames(dds)
str(gene.detail)

##------------------------------------------------------------------------
## Step 4 : Data exploration 
##------------------------------------------------------------------------

# Data transformations
## Variance-Stabilizing transformation 
vsd <- vst(dds, blind=TRUE)

## Regularized log transformation
rld <- rlog(dds, blind=TRUE)


pdf("results/summary/DE_Analysis/plots/vst_data_transformation.pdf")
meanSdPlot(assay(vsd))
dev.off()

pdf("results/summary/DE_Analysis/plots/rlog_data_transformation.pdf")
meanSdPlot(assay(rld))
dev.off()


# Data visualization 

## QC Check
max_val <- 80
select <- order(rowMeans(counts(dds,normalized=TRUE)),
                decreasing=TRUE)
df <- as.data.frame(colData(dds)[,c("batch","condition")])

pdf("results/summary/DE_Analysis/plots/vst_qc_check.pdf")
pheatmap(assay(vsd)[select[1:max_val],], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=T, annotation_col=df)
dev.off()

pdf("results/summary/DE_Analysis/plots/rlog_qc_check.pdf")
pheatmap(assay(rld)[select[1:max_val],], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=T, annotation_col=df)
dev.off()

## PCA 

pdf("results/summary/DE_Analysis/plots/vst_plotPCA.pdf")
plotPCA(vsd, intgroup=c("condition", "batch"), 
                   ntop=length(select))
dev.off()


pdf("results/summary/DE_Analysis/plots/rlog_plotPCA.pdf")
plotPCA(rld, intgroup=c("condition", "batch"), 
                   ntop=length(select))
dev.off()


