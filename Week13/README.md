# Week 13 Assignment: Generate an RNA-Seq count matrix

## Overview



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

### Step 1: Download data and genome (bioinfo environment)
```bash
micromamba activate bioinfo

# Create the design file
make design

# Download the UHR/HBR dataset
make data

# Download genome and annotation
make genome

# Index genome
make index
```

### Step 2: Processing Samples 

#### Process one sample
```bash
# Process one sample
make align SAMPLE=HBR_1
make count SAMPLE=HBR_1
make bw SAMPLE=HBR_1
```

#### Process all samples
```bash
# First verify design.csv is being read correctly
make -f Batch.mk show-samples

# Batch processing reads samples from design.csv
make -f Batch.mk all-align    # Aligns: HBR_1, HBR_2, HBR_3, UHR_1, UHR_2, UHR_3
make -f Batch.mk all-counts   # Counts all samples
make -f Batch.mk matrix       # Creates count matrix
```
