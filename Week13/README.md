# Week 13 Assignment: Generate an RNA-Seq count matrix

## Overview

This pipeline processes RNA-seq data to generate a count matrix showing gene expression levels across samples. The workflow aligns reads to the human genome (chr22), quantifies gene expression, and produces IGV-compatible visualization files.

* Dataset: UHR (Universal Human Reference) vs HBR (Human Brain Reference)
* Chromosome: chr22 (for faster processing)

## Samples:
* HBR (Human Brain Reference): 3 replicates - total RNA from 23 human brains
* UHR (Universal Human Reference): 3 replicates - total RNA from 10 cancer cell lines

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
