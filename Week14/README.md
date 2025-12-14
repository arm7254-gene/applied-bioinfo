# Week 14 Assignment: Perform an RNA-Seq differential gene expression study  

#### **Methicillin-Resistant Staphylococcus aureus: Control vs Treatment** <br> BioProject: PRJNA887926 <br> Organism: Staphylococcus aureus subsp. aureus USA300

## Overview
**MRSA RNA-seq Differential Expression Study**:
This pipeline processes RNA-seq data from MRSA to generate a count matrix showing gene expression levels. The workflow aligns reads to the S. aureus genome, quantifies gene expression using featureCounts, and produces IGV-compatible visualization files.

## Samples:

In Im et al.(2022), they investigated the regulatory mechanism responsible for the inhibitory effect of NaP on MRSA using RNA-Seq analysis

| Source                  | Sample Description    | Sample ID     | SRR Accession |
| :---------------------- | :-------------------- | :------------ | :------------ |
| BioProject PRJNA887926  | Control Replicate 1   |  SRS15348645  | SRR21835898   |
|                         | Control Replicate 2   |  SRS15348646  | SRR21835897   |
|                         | Control Replicate 3   |  SRS15348647  | SRR21835896   |
|                         | Treatment Replicate 1 |  SRS15348642  | SRR21835901   |
|                         | Treatment Replicate 2 |  SRS15348643  | SRR21835900   |
|                         | Treatment Replicate 3 |  SRS15348644  | SRR21835899   |

## Setup 

### Environment Requirements

This pipeline uses two conda environments:
* bioinfo - For data download, alignment, and counting
  ```bash
  micromamba activate bioinfo
  ```
* stats - For statistical analysis of the count matrix
  ```bash
  micromamba activate stats
  ```

## Computational Pipeline
### Read Alignment (bioinfo environment)
```bash
make design          # Create experimental design file
make genome          # Download reference genome and GFF annotation
make index           # Index genome with BWA
make -f Looper.mk fastq    # Download FASTQ files from SRA
make -f Looper.mk align    # Align reads with BWA
make -f Looper.mk bigwig   # Generate coverage tracks
```

### Quantification (bioinfo environment)
```bash
make -f Looper.mk count    # Count reads per gene with featureCounts
make matrix                 # Merge counts into matrix
```

### Differential Expression (stats environment)
```bash
make deseq2                 # DESeq2 analysis with PCA and heatmaps
make enrichment             # Functional enrichment analysis
```

#### Statistical Analysis
* Normalization: DESeq2 median-of-ratios
* Differential Expression: DESeq2 (v1.x)
* Significance Thresholds: padj < 0.05, |log2 fold-change| > 1
* Visualization: PCA, heatmaps, volcano plots, MA plots

### Results

#### Principal Component Analysis
<img width="800" height="600" alt="pca_plot" src="https://github.com/user-attachments/assets/b0ff8dc1-134c-4842-80fc-e7c83a074869" />

#### Visualization Files:

##### Heatmap: Top 50 different
<img width="800" height="1000" alt="heatmap_significant" src="https://github.com/user-attachments/assets/00a5e017-b97f-4e0b-9546-5196cd35a41e" />
ially expressed genes

##### Volcano plot: Significance vs fold-change
<img width="800" height="600" alt="volcano_plot" src="https://github.com/user-attachments/assets/42a70c8b-2c1a-4667-abe1-9179c604d577" />

##### MA plot: Mean expression vs log fold-change
<img width="800" height="600" alt="ma_plot" src="https://github.com/user-attachments/assets/0856bb19-76ea-4c84-8bcf-7e5095432384" />


