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
args <- commandArgs(trailingOnly=TRUE)

if(file.exists(args[1])!=TRUE){
  stop("Error: Patg provided do not exist.", call.=FALSE)
}
path_to_working_dir <- args[1]

setwd(path_to_working_dir)

##------------------------------------------------------------------------
## Step 2 : Import libraries 
##------------------------------------------------------------------------
if (!require("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

cran_packages <- c(
  "conflicted", "vsn", "pheatmap", "ggplot2", "tidyr",
  "ggrepel", "cowplot", "RColorBrewer", "patchwork", "dplyr"
)

bioc_packages <- c(
  "DESeq2", "clusterProfiler", "org.Mm.eg.db", "enrichplot"
)

## Install CRAN packages
for(pkg in cran_packages){
  if(!requireNamespace(pkg, quietly = TRUE)){
    install.packages(pkg, dependencies = TRUE)
  }
}

## Install BiocManager
if(!requireNamespace("BiocManager", quietly = TRUE)){
  install.packages("BiocManager")
}

## Install Bioconductor packages 
for(pkg in bioc_packages){
  if(!requireNamespace(pkg, quietly = TRUE)){
    BiocManager::install(pkg, ask = FALSE)
  }
}

## Load packages
library(conflicted)
library("DESeq2")
library("clusterProfiler")
library(org.Mm.eg.db)
library("vsn")
library("pheatmap")
library(ggplot2)
library(ggrepel)
library(cowplot)
library("RColorBrewer")
library(enrichplot)
library(patchwork)
library(tidyr)
library(dplyr)

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
res_WT_control_case <- res_WT_control_case[gene.detail[!is.na(gene.detail$gene_name),"gene_id"],]

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_case))/nrow(res_WT_control_case)

## Filter of row with NA values
res_WT_control_case <- res_WT_control_case[!is.na(res_WT_control_case$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_case))/nrow(res_WT_control_case)

## Store all genes ID
WT_control_case_all_genes <- rownames(res_WT_control_case)

## How many genes are differentially expressed (DE) (padj < 0.05 and |log2FC|>1) 
res_WT_control_case <- subset(res_WT_control_case, padj< 0.05 & abs(log2FoldChange)>1 )

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
res_control_WT_DK <- res_control_WT_DK[gene.detail[!is.na(gene.detail$gene_name),"gene_id"],]

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_control_WT_DK))/nrow(res_control_WT_DK)

## Filter of row with NA values
res_control_WT_DK <- res_control_WT_DK[!is.na(res_control_WT_DK$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_control_WT_DK))/nrow(res_control_WT_DK)

## Store all genes ID
control_WT_DK_all_genes <- rownames(res_control_WT_DK)

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
res_WT_control_DK_case <- res_WT_control_DK_case[gene.detail[!is.na(gene.detail$gene_name),"gene_id"],]

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_DK_case))/nrow(res_WT_control_DK_case)

## Filter of row with NA values
res_WT_control_DK_case <- res_WT_control_DK_case[!is.na(res_WT_control_DK_case$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_WT_control_DK_case))/nrow(res_WT_control_DK_case)

## Store all genes ID
WT_control_DK_case_all_genes <- rownames(res_WT_control_DK_case)

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
res_case_WT_DK <- res_case_WT_DK[gene.detail[!is.na(gene.detail$gene_name),"gene_id"],]

## Check the proportion of missing values (NA) in results
100*colSums(is.na(res_case_WT_DK))/nrow(res_case_WT_DK)

## Filter of row with NA values
res_case_WT_DK <- res_case_WT_DK[!is.na(res_case_WT_DK$padj),]

## Check again the proportion of missing values (NA) in results
100*colSums(is.na(res_case_WT_DK))/nrow(res_case_WT_DK)

## Store all genes ID
case_WT_DK_all_genes <- rownames(res_case_WT_DK)

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
write.csv(regulated_genes, "results/summary/DE_Analysis/regulated_genes.csv", row.names =TRUE)

regulated_genes$comparison <- rownames(regulated_genes)

regulated_long <- regulated_genes %>%
  dplyr::select(comparison, num_up, num_down)%>%
  pivot_longer(
    cols = c(num_up, num_down),
    names_to = "regulation",
    values_to = "count"
  )

regulated_long$regulation <- recode(
  regulated_long$regulation,
  num_up = "Up-regulated",
  num_down = "Down-regulated"
)

pdf("results/summary/DE_Analysis/plots/number_regulated_gene.pdf")
ggplot(regulated_long,
       aes(x = comparison, y = count, fill = regulation)) +
  geom_bar(stat = "identity") +
  geom_text(
    aes(label = count),
    position = position_stack(vjust = 0.5),
    color = "white",
    size = 3
  ) +
  labs(
    x = "Comparison",
    y = "Number of genes"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

##------------------------------------------------------------------------
## Step 6 : Overrepresentation analysis
##------------------------------------------------------------------------

## Function to create a vector of foldchange with rownames gene name
named_foldChange <- function(de_results, gene_detail) {
  
  gene_id_list <- rownames(de_results)
  gene_name_list <- gene_detail[match(gene_id_list, gene_detail$gene_id), "gene_name"]
  
  fc_vector <- de_results$log2FoldChange
  
  names(fc_vector) <- gene_name_list
  
  return(fc_vector)
}

## List of GO Description related to our study base on the original publication
GO_module_L5 <- "response to type I interferon"

GO_module_L7 <- "antigen processing and presentation"

# Contrast 1 :
## Run overrepresentation analysis
ego_WT_control_case <- enrichGO(gene = WT_control_case_DE, OrgDb = org.Mm.eg.db, 
                                keyType = "ENSEMBL", ont="BP", readable=TRUE,
                                pvalueCutoff  = 0.01,qvalueCutoff  = 0.05, universe = WT_control_case_all_genes)

top <- 10
## Plot the top 10 GO terms detected in the overrepresentation analysis
p1 <- dotplot(ego_WT_control_case, showCategory=top, font.size=8)+ 
  ggtitle("WT control vs WT case")

## Plot cnetplot 
fc <- named_foldChange(res_WT_control_case, gene.detail)

h1 <- cnetplot(ego_WT_control_case, node_label = "all",
               color.params = list(foldChange = fc),
               cex.params= list(gene_label=0.5), showCategory= c(GO_module_L5, GO_module_L7))+ 
  ggtitle("WT control vs WT case")

# Contrast 2 :
## Run overrepresentation analysis
ego_control_WT_DK <- enrichGO(gene = control_WT_DK_DE, OrgDb = org.Mm.eg.db, 
                              keyType = "ENSEMBL", ont="BP", readable=TRUE,
                              pvalueCutoff  = 0.01,qvalueCutoff  = 0.05, universe = control_WT_DK_all_genes)

## Plot the top 10 GO terms detected in the overrepresentation analysis
p2 <- dotplot(ego_control_WT_DK, showCategory=top, font.size=8)+ 
  ggtitle("WT control vs DK control")

## Plot cnetplot
fc <- named_foldChange(res_control_WT_DK, gene.detail)

h2 <- cnetplot(ego_control_WT_DK, node_label = "all",
               color.params = list(foldChange = fc),
               cex.params= list(gene_label=0.5), showCategory= c(GO_module_L5, GO_module_L7))+
  ggtitle("WT control vs DK control")

# Contrast 3 :
## Run overrepresentation analysis
ego_WT_control_DK_case <- enrichGO(gene = WT_control_DK_case_DE, OrgDb = org.Mm.eg.db, 
                                   keyType = "ENSEMBL", ont="BP", readable=TRUE,
                                   pvalueCutoff  = 0.01,qvalueCutoff  = 0.05, universe = WT_control_DK_case_all_genes)

## Plot the top 10 GO terms detected in the overrepresentation analysis
p3 <- dotplot(ego_WT_control_DK_case, showCategory=top, font.size=8)+ 
  ggtitle("WT control vs DKO case")

## Plot cnetplot
fc <- named_foldChange(res_WT_control_DK_case, gene.detail)

### For Ifng/Gbp/Antigen presentation
h3 <- cnetplot(ego_WT_control_DK_case, node_label = "all",
               color.params = list(foldChange = fc),
               cex.params= list(gene_label=0.5), showCategory= c(GO_module_L5, GO_module_L7))+
  ggtitle("WT control vs DKO case")

# Contrast 4 :
## Run overrepresentation analysis
ego_case_WT_DK <- enrichGO(gene = case_WT_DK_DE, OrgDb = org.Mm.eg.db, 
                           keyType = "ENSEMBL", ont="BP", readable=TRUE,
                           pvalueCutoff  = 0.01,qvalueCutoff  = 0.05, , universe = gene.detail$gene_id)

## Plot the top 10 GO terms detected in the overrepresentation analysis
p4 <- dotplot(ego_case_WT_DK, showCategory=top, font.size=8)+ 
  ggtitle("WT case vs DKO case")

## Plot cnetplot
fc <- named_foldChange(res_case_WT_DK, gene.detail)

h4 <- cnetplot(ego_case_WT_DK, node_label = "all",
               color.params = list(foldChange = fc),
               cex.params= list(gene_label=0.5), showCategory= c(GO_module_L5, GO_module_L7))+
  ggtitle("WT case vs DKO case")

png("results/summary/DE_Analysis/plots/ORA_dotplot.png", width = 1380, height = 735)
plot_list(p1, p2, p3, p4,
          tag_levels = "A")
dev.off()


png("results/summary/DE_Analysis/plots/ORA_cnetplot_module_L5_L7.png", width = 1380, height = 735)
plot_list(h1, h2, h3, h4,
          tag_levels = "A")
dev.off()

