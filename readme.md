# RNAseq Project

## About project 
Here I will put an introduction about this project with these elements :
- Context 
- Problem 
- Objectives

## Methodology 
- Here is the place of the methodology. 
- How we did to attend our objectives.
- I will also add here an image for the workflow used

## Results 
I will add all important results as images for this project 

## Project structure

```
.
├── main.sh
├── container
|   └──[list of containers (.sif)]
├── data
│   ├── dataset -> /data/courses/rnaseq_course/toxoplasma_de/reads_Lung
│   └── refseq
|       ├── Mus_musculus.GRCm39.115.exon
|       ├── Mus_musculus.GRCm39.115.fa
|       ├── Mus_musculus.GRCm39.115.gff3
|       ├── Mus_musculus.GRCm39.115.gtf
|       ├── Mus_musculus.GRCm39.115.idx.1.ht2
|       ├── Mus_musculus.GRCm39.115.idx.2.ht2
|       ├── Mus_musculus.GRCm39.115.idx.3.ht2
|       ├── Mus_musculus.GRCm39.115.idx.4.ht2
|       ├── Mus_musculus.GRCm39.115.idx.5.ht2
|       ├── Mus_musculus.GRCm39.115.idx.6.ht2
|       ├── Mus_musculus.GRCm39.115.idx.7.ht2
|       ├── Mus_musculus.GRCm39.115.idx.8.ht2
|       └── Mus_musculus.GRCm39.115.ss
├── .log
│   ├── errors
|   |   └──[error logs (.err)]
│   └── output
|       └──[output logs (.out)]
├── results
│   ├── SRR78219*
│   │   ├── fastqc
|   |   |   └──[raw reads QC results]
│   │   └── hisat2
|   |      |──[alignment results]
|   |      |──[alignment QC results]
|   |      └──[featureCounts results]
│   └── summary
│       ├── DE_Analysis
|       |   |──[featureCount Matrix]
|       |   |──Mus_musculus.GRCm39.115.csv
|       |   |──differential_expression_model.RData
|       |   └──plots
│       └── quality_control
│           |── multiqc_data
|           └──multiqc_report.html
└── scripts
    |── [R script]
    └──[bash script]
```