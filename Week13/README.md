# Week 13 Assignment: Generate an RNA-Seq count matrix

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

### Top Gene Candidates:
```bash
# Find genes with highest counts
tail -n +2 counts/count_matrix.txt | sort -t',' -k2 -rn | head -20
```
#### Gene: SAOUHSC_01121 - Strong differential expression!
* Control: 4,616, 4,127, 4,226
* Treatment: 176, 255, 274
* ~16-fold decrease in treatment! 

<img width="2254" height="1002" alt="SAOUHSC_01121" src="https://github.com/user-attachments/assets/6bc4464e-3912-4a2c-b528-3395b5887aee" />

<img width="2254" height="1002" alt="SAOUHSC_01121_Zoom" src="https://github.com/user-attachments/assets/318466e6-8e38-45a1-b341-07458d3a159d" />

#### Gene: SAOUHSC_00233  - Strong differential expression!
* Control: 3,641, 3,648, 3,970
* Treatment: 213, 188, 139
* ~20-fold decrease in treatment!

<img width="2254" height="1002" alt="SAOUHSC_00233" src="https://github.com/user-attachments/assets/47d5e1e7-3bdc-46d7-af40-8ecc5f2eb98f" />

<img width="2254" height="1002" alt="SAOUHSC_00233_Zoom" src="https://github.com/user-attachments/assets/ad98d795-0a59-42b8-aa6d-a37beb6eb10a" />

## Count Matrix Analysis

### View the matrix:
```bash
head counts/count_matrix.txt
```
#### Output
```bash
Geneid,SRS15348645,SRS15348646,SRS15348647,SRS15348642,SRS15348643,SRS15348644
gene-SAOUHSC_00001,70,67,53,83,79,92
gene-SAOUHSC_00002,37,47,53,81,48,53
gene-SAOUHSC_00003,1,2,0,3,3,2
gene-SAOUHSC_00004,16,24,8,41,38,42
gene-SAOUHSC_00005,45,26,28,84,71,86
gene-SAOUHSC_00006,26,38,22,60,60,68
gene-SAOUHSC_00007,5,0,2,0,0,0
gene-SAOUHSC_00008,61,79,56,46,55,42
gene-SAOUHSC_00009,58,79,70,26,20,30
```

### Find genes with consistent expression:
```bash
# Look for genes with similar counts across replicates
tail -n +2 counts/count_matrix.txt | sort -t',' -k2 -rn | head -20
```
#### Output
```bash
gene-SAOUHSC_00206,11861,12044,9049,8561,8035,8239
gene-SAOUHSC_02261,5149,5699,6709,3120,2622,2622
gene-SAOUHSC_01121,4616,4127,4226,176,255,274
gene-SAOUHSC_02264,4245,4059,3810,1853,2031,1744
gene-SAOUHSC_02265,3991,4310,5377,2838,2463,2367
gene-SAOUHSC_02260,3716,4583,2768,1453,1663,1769
gene-SAOUHSC_00233,3641,3648,3970,213,188,139
gene-SAOUHSC_01490,3171,3290,1639,1704,1895,1666
gene-SAOUHSC_01001,3161,3205,4346,4467,4102,3934
gene-SAOUHSC_00356,2856,2654,1491,1533,1787,2060
gene-SAOUHSC_00300,2633,2423,2397,2742,2734,2828
gene-SAOUHSC_00529,2470,2558,2454,2307,2352,2670
gene-SAOUHSC_01418,2328,2334,1932,985,1110,1078
gene-SAOUHSC_00187,2135,2357,2634,736,764,802
gene-SAOUHSC_00144,2063,2106,2604,833,924,857
gene-SAOUHSC_02751,2022,2001,1808,601,735,603
gene-SAOUHSC_02441,1782,1931,2095,2759,2415,2578
gene-SAOUHSC_02849,1768,1851,1692,1386,1338,1176
gene-SAOUHSC_02443,1736,1801,2891,3702,3182,3167
gene-SAOUHSC_00094,1714,1622,1366,332,361,345
```
Note: The above is not easily appreciated as is, so use the R visualization described below to create a heatmap of the above results!

## R Visualization

### Step 1: Create R script
```bash
cat > visualize_counts.R << 'EOF'
#!/usr/bin/env Rscript
# Super simple count matrix visualization
# Usage: Rscript visualize_counts.R

# Load library
library(gplots)

# Read count matrix
counts <- read.csv("counts/count_matrix.txt", row.names=1)

# Get top 30 most highly expressed genes
top_genes <- head(counts[order(-rowSums(counts)),], 30)

# Create heatmap
png("counts/heatmap_top30.png", width=800, height=1000)
heatmap.2(as.matrix(top_genes), 
          trace="none",
          col=colorpanel(100, "blue", "white", "red"),
          margins=c(10,15),
          main="Top 30 Most Expressed Genes\nControl vs Treatment",
          cexRow=0.8,
          cexCol=1.2)
dev.off()

cat("\n=== Heatmap created: counts/heatmap_top30.png ===\n\n")

# Print summary
cat("Top 5 genes by total expression:\n")
print(head(top_genes, 5))

cat("\n\nControl samples (first 3 columns) vs Treatment samples (last 3 columns)\n")
cat("Red = high expression, Blue = low expression\n")
EOF

# Now run it
Rscript visualize_counts.R
```

### Step 2: Activate Stats Environment
```bash
micromamba activate stats
```

### Step 3: Run Script (from the terminal)
```bash
# Run the script
Rscript visualize_counts.R
```
Note: Heatmap created: counts/heatmap_top30.png will be added to the ../counts

<img width="800" height="1000" alt="heatmap_top30" src="https://github.com/user-attachments/assets/1cee1407-073c-479a-bc13-06a42775e92e" />


