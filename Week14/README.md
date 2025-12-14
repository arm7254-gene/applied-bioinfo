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
micromamba activate stats
make deseq2                 # DESeq2 analysis with PCA and heatmaps
make enrichment             # Functional enrichment analysis
```
