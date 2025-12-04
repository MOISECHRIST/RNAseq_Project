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
library(ggrepel)
library(cowplot)
library("RColorBrewer")

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


pdf("results/summary/DE_Analysis/plots/vst_data_transformation.pdf")
meanSdPlot(assay(vsd))
dev.off()


# Data visualization 

## QC Check
max_val <- 50
select <- order(rowMeans(counts(dds,normalized=TRUE)),
                decreasing=TRUE)
df <- as.data.frame(colData(dds)[,c("batch","condition")])

pdf("results/summary/DE_Analysis/plots/vst_qc_check.pdf")
pheatmap(assay(vsd)[select[1:max_val],], cluster_rows=F, show_rownames=FALSE,
         cluster_cols=T, annotation_col=df)
dev.off()

## Sample clustering (HAC of distance between samples)
sampleDists <- dist(t(assay(vsd)))

sampleDistMatrix <- as.matrix(sampleDists)
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)

pdf("results/summary/DE_Analysis/plots/vst_sample_clustering.pdf")
pheatmap(sampleDistMatrix,
         clustering_distance_rows=sampleDists,
         clustering_distance_cols=sampleDists,
         col=colors, annotation_col = df, 
         show_rownames = F)
dev.off()

## PCA 
pdf("results/summary/DE_Analysis/plots/vst_plotPCA.pdf")

pcaData <- plotPCA(vsd, intgroup=c("condition", "batch"), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
ggplot(pcaData, aes(PC1, PC2, color=condition, shape=batch)) +
  geom_point(size=3) + geom_text_repel(aes(label=name), size = 2.5) +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) + 
  coord_fixed()

dev.off()


##------------------------------------------------------------------------
## Step 5 : Differential expression analysis 
##------------------------------------------------------------------------

## Based on the original publication, select 2-3 genes 
## that are of particular interest and investigate their expression level
gene_list <- c("Mx1", "Ifit1", "Tap1")
gene_id <- gene.detail[gene.detail$gene_name %in% gene_list, ]$gene_id

pdf("results/summary/DE_Analysis/plots/plotCounts_selected_genes.pdf")
i <- 1
par(mfrow = c(3,1))
for(item in gene_id){
  plotCounts(dds, gene = item, 
             intgroup = c("batch", "condition"), 
             main = paste0("Gene : ",gene_list[i]), 
             normalized = T,
             transform = T) 
  i <- i+1
}
dev.off()

pdf("results/summary/DE_Analysis/plots/plotCounts_selected_genes_v2.pdf")
norm_counts <- counts(dds, normalized=TRUE)
select_plots <- list()
i <- 1
for(item in gene_id){
  df <- data.frame(
    counts = norm_counts[item, ],
    sample = colnames(norm_counts),
    condition = dds$condition,
    group = dds$batch
  )
  
  p <- ggplot(df, aes(x = condition, y = log2(counts+1))) +
    geom_point(size=2) +
    stat_summary(fun=mean, geom="line", color="red", aes(group=1)) +
    facet_wrap(~ group, nrow=1) +
    ggtitle(paste0("Gene : ",gene_list[i])) +
    theme_gray()
  select_plots[[i]] <- p 
  i <- i+1
}

plot_grid(plotlist = select_plots, nrow = 3)
dev.off()
# Contrast 1 : 
# Answer to the question : Which genes respond to T. gondii infection in wild-type mice?
res_WT_control_case <- results(dds, contrast = c("condition", "Case", "Control"))

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_case))/nrow(res_WT_control_case)

## Filter of row with NA values
res_WT_control_case <- res_WT_control_case[!is.na(res_WT_control_case$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_case))/nrow(res_WT_control_case)

## How many genes are differentially expressed (DE) (padj < 0.05 and |log2FC|>1) 
res_WT_control_case <- subset(res_WT_control_case, padj< 0.05 & abs(log2FoldChange)>1)

WT_control_case_DE <- rownames(res_WT_control_case)

## How many of the DE genes are up-regulated vs down-regulated?
### up-regulated 
WT_control_case_up_reg_genes <- rownames(subset(res_WT_control_case, log2FoldChange >1))

### down-regulated
WT_control_case_down_reg_genes <- rownames(subset(res_WT_control_case, log2FoldChange < -1))

## Based on the original publication, select 2-3 genes 
## that are of particular interest and investigate their expression level
res_WT_control_case[gene_id,]


# Contrast 2 : 
# Answer to the question : Which genes are different between DKO and WT in the absence of infection ?
res_control_WT_DK <- results(dds, name = "batch_Double_Knockout_vs_Wildtype")

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_control_WT_DK))/nrow(res_control_WT_DK)

## Filter of row with NA values
res_control_WT_DK <- res_control_WT_DK[!is.na(res_control_WT_DK$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_control_WT_DK))/nrow(res_control_WT_DK)

## How many genes are differentially expressed (DE) (padj < 0.05 and |log2FC|>1) 
res_control_WT_DK <- subset(res_control_WT_DK, padj< 0.05 & abs(log2FoldChange)>1)

control_WT_DK_DE <- rownames(res_control_WT_DK)

## How many of the DE genes are up-regulated vs down-regulated?
### up-regulated 
control_WT_DK_up_reg_genes <- rownames(subset(res_control_WT_DK, log2FoldChange >1))

### down-regulated
control_WT_DK_down_reg_genes <- rownames(subset(res_control_WT_DK, log2FoldChange < -1))

## Based on the original publication, select 2-3 genes 
## that are of particular interest and investigate their expression level
res_control_WT_DK[gene_id,]

# Contrast 3 : 
# Answer to the question : What is the overall impact of T. goodii infection in Double Knockout mice ? 
res_WT_control_DK_case <- results(dds,
                                  contrast=list(c("batch_Double_Knockout_vs_Wildtype",
                                    "batchDouble_Knockout.conditionCase",
                                    "condition_Case_vs_Control")))

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_DK_case))/nrow(res_WT_control_DK_case)

## Filter of row with NA values
res_WT_control_DK_case <- res_WT_control_DK_case[!is.na(res_WT_control_DK_case$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_DK_case))/nrow(res_WT_control_DK_case)

## How many genes are differentially expressed (DE) (padj < 0.05 and |log2FC|>1) 
res_WT_control_DK_case <- subset(res_WT_control_DK_case, padj< 0.05 & abs(log2FoldChange)>1)

WT_control_DK_case_DE <- rownames(res_WT_control_DK_case)

## How many of the DE genes are up-regulated vs down-regulated?
### up-regulated 
WT_control_DK_case_up_reg_genes <- rownames(subset(res_WT_control_DK_case, log2FoldChange >1))

### down-regulated
WT_control_DK_case_down_reg_genes <- rownames(subset(res_WT_control_DK_case, log2FoldChange < -1))

## Based on the original publication, select 2-3 genes 
## that are of particular interest and investigate their expression level
res_WT_control_DK_case[gene_id,]

# Contrast 4 :
# Answer to the question : Which genes show a response to infection that is significantly different between WT and DKO mice ?
res_case_WT_DK <- results(dds, contrast=list(c(
    "batch_Double_Knockout_vs_Wildtype",
    "batchDouble_Knockout.conditionCase")))

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_case_WT_DK))/nrow(res_case_WT_DK)

## Filter of row with NA values
res_case_WT_DK <- res_case_WT_DK[!is.na(res_case_WT_DK$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_case_WT_DK))/nrow(res_case_WT_DK)

## How many genes are differentially expressed (DE) (padj < 0.05 and |log2FC|>1) 
res_case_WT_DK <- subset(res_case_WT_DK, padj< 0.05 & abs(log2FoldChange)>1)

case_WT_DK_DE <- rownames(res_case_WT_DK)

## How many of the DE genes are up-regulated vs down-regulated?
### up-regulated 
case_WT_DK_up_reg_genes <- rownames(subset(res_case_WT_DK, log2FoldChange >1))

### down-regulated
case_WT_DK_down_reg_genes <- rownames(subset(res_case_WT_DK, log2FoldChange < -1))

## Based on the original publication, select 2-3 genes 
## that are of particular interest and investigate their expression level
res_case_WT_DK[gene_id,]


## Make a table 
regulated_genes <- data.frame(num_up=c(length(WT_control_case_up_reg_genes), 
                                  length(control_WT_DK_up_reg_genes),
                                  length(WT_control_DK_case_up_reg_genes),
                                  length(case_WT_DK_up_reg_genes)),
                  num_down=c(length(WT_control_case_down_reg_genes), 
                                    length(control_WT_DK_down_reg_genes),
                                    length(WT_control_DK_case_down_reg_genes),
                                    length(case_WT_DK_down_reg_genes)),
                  DE_genes=c(length(WT_control_case_DE), length(control_WT_DK_DE), 
                               length(WT_control_DK_case_DE), length(case_WT_DK_DE)),
                  row.names = c("WT control vs WT case", "WT control vs DK control", 
                                "WT control vs DKO case", "WT case vs DKO case"))

print(regulated_genes)



