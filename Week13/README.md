# Week 13 Assignment: Generate an RNA-Seq count matrix

## Overview
**MRSA RNA-seq Differential Expression Study**:
This pipeline processes RNA-seq data from MRSA to generate a count matrix showing gene expression levels. The workflow aligns reads to the S. aureus genome, quantifies gene expression using featureCounts, and produces IGV-compatible visualization files.

## Samples:


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
* stats - For statistical analysis of the count matrix

## Quick Start

### 1. Setup (run once)
```bash
micromamba activate bioinfo

# Create design file
make design

# Download reference genome and annotation
make genome

# Index genome
make index
```

### 2. Process all samples (batch)
```bash
# Download reads for all samples
make -f Looper.mk fastq

# Align all samples
make -f Looper.mk align

# Generate coverage tracks
make -f Looper.mk bigwig

# Count reads per gene
make -f Looper.mk count

# Create count matrix
make matrix
```

### 3. Or process one sample at a time
```bash
# Example with control replicate 3
make fastq SAMPLE=SRS15348647 SRR=SRR21835896
make align SAMPLE=SRS15348647
make bigwig SAMPLE=SRS15348647
make count SAMPLE=SRS15348647
make stats SAMPLE=SRS15348647
```
### 4. Cleanup
```bash
Clean Up
```

## Workflow Steps

### 1. Data Download
```bash
make genome         # S. aureus USA300 genome and GFF annotation
make -f Looper.mk fastq    # Download all 6 samples (140k reads each)
```

### 2. Alignment
```bash
make -f Looper.mk align    # Align with BWA, create sorted BAM files
make -f Looper.mk stats    # Generate alignment statistics
```

### 3. Visualization
```bash
make -f Looper.mk bigwig   # Create BigWig coverage tracks for IGV
```

### 4. Gene Counting
```bash
make -f Looper.mk count    # Count reads per gene with featureCounts
make matrix                 # Merge into count matrix
```
## IGV Visualization
Note: Data analysis done in IGV web browser: https://igv.org/app/ 

<img width="2254" height="1002" alt="SAOUHSC_01121" src="https://github.com/user-attachments/assets/6bc4464e-3912-4a2c-b528-3395b5887aee" />



## Count Matrix Analysis

### View the matrix:
```bash
head counts/count_matrix.txt
```


