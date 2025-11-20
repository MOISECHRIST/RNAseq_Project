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

#Import libraries 
library(conflicted)
library("DESeq2")
library("clusterProfiler")
library("vsn")
library("pheatmap")

#Load data
load("results/summary/DE_Analysis/differential_expression_model.RData")
gene.detail <- read.csv("results/summary/DE_Analysis/Mus_musculus.GRCm39.115.csv", 
                        sep=",", header = T)

#A glimpse of our data 
str(dds)
str(gene.detail)

#Data transformations
##Variance-Stabilizing transformation 
vsd <- vst(dds, blind=FALSE)

##Regularized log transformation
rld <- rlog(dds, blind=FALSE)

##this gives log2(n + 1)
ntd <- normTransform(dds)

pdf("results/summary/DE_Analysis/plots/vst_data_transformation.pdf")
meanSdPlot(assay(vsd))
dev.off()

pdf("results/summary/DE_Analysis/plots/rlog_data_transformation.pdf")
meanSdPlot(assay(rld))
dev.off()

pdf("results/summary/DE_Analysis/plots/ntd_data_transformation.pdf")
meanSdPlot(assay(ntd))
dev.off()

#Data visualization : QC Check
max_val <- 30
select <- order(rowMeans(counts(dds,normalized=TRUE)),
                decreasing=TRUE)
df <- as.data.frame(colData(dds)[,c("batch","condition")])

pdf("results/summary/DE_Analysis/plots/ntd_qc_check.pdf")
pheatmap(assay(ntd)[select[1:max_val],], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=T, annotation_col=df)
dev.off()

pdf("results/summary/DE_Analysis/plots/vst_qc_check.pdf")
pheatmap(assay(vsd)[select[1:max_val],], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=T, annotation_col=df)
dev.off()

pdf("results/summary/DE_Analysis/plots/rlog_qc_check.pdf")
pheatmap(assay(rld)[select[1:max_val],], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=T, annotation_col=df)
dev.off()


