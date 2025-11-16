# Week 12 Assignment: Evaluate data from the Cancer Genome in a Bottle project

# Assignment: Option 2 - Variant Calling and Evaluation
- Gene: TP53 (tumor suppressor on chr17)
- Region: chr17:7,661,779-7,687,550

## Overview
This analysis calls variants in normal and tumor samples from the Cancer Genome in a Bottle HG008 dataset, identifies tumor-specific variants, and compares results to the DeepVariant gold standard.

## Quick Start
### Step 0: Activate Environment
```bash
micromamba activate bioinfo
```

### Step 1: Call variants for normal sample
```bash
make genome
make bam SAMPLE_TYPE=normal
make vcf SAMPLE_TYPE=normal
```
### Step 2: Call variants for tumor sample
```bash
make bam SAMPLE_TYPE=tumor
make vcf SAMPLE_TYPE=tumor
```
### Step 3: Download gold standard
```bash
make gold
```
### Step 4: Evaluate and generate report
```bash
make -f Evaluate.mk compare
make -f Evaluate.mk evaluate
make -f Evaluate.mk report
```
### Step 5: Clean up (Optional, but good habit once all analysis is complete)
```bash
make clean                  # Remove all files
make -f Evaluate.mk clean   # Remove evaluation files
```

## Files Generated
Reference:
* refs/chr17.fasta - Reference genome for chr17
* refs/chr17.fasta.fai - Index

BAM files:
* bam/TP53-normal.bam - Normal sample alignments
* bam/TP53-tumor.bam - Tumor sample alignments

VCF files:
* vcf/TP53-normal.vcf.gz - Normal variants
* vcf/TP53-tumor.vcf.gz - Tumor variants
* vcf/tumor-specific.vcf.gz - Variants unique to tumor
* vcf/gold-standard.vcf.gz - DeepVariant gold standard
* vcf/gold-region.vcf.gz - Gold standard for our region

Analysis:
* vcf/isec/0000.vcf - Normal-only variants
* vcf/isec/0001.vcf - Tumor-specific variants
* vcf/isec/0002.vcf - Common variants
* report.txt - Final summary report

## Deliverable: Report with variant counts, tumor-specific variants, and comparison to gold standard.
### Step 6: iew report
```bash
cat report.txt
```
### Report.txt output:
```bash
========================================
Cancer Genome Variant Analysis Report
========================================

Gene: TP53
Region: chr17:7661779-7687550
Date: Sun Nov 16 15:14:15 EST 2025

----------------------------------------
1. VARIANT COUNTS
----------------------------------------

Normal sample:
-n   Total variants: 
      55
-n   SNPs: 
      40
-n   INDELs: 
      15

Tumor sample:
-n   Total variants: 
      37
-n   SNPs: 
      24
-n   INDELs: 
      13

----------------------------------------
2. TUMOR-SPECIFIC VARIANTS
----------------------------------------

-n Total tumor-specific variants: 
       5
-n   SNPs: 
       4
-n   INDELs: 
       1

Top 10 tumor-specific variants:
chr17	7664359	TTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATC	TTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATCTATC
chr17	7675217	T	G
chr17	7676341	T	C
chr17	7677340	A	C
chr17	7687289	A	C

----------------------------------------
3. GOLD STANDARD COMPARISON
----------------------------------------

-n Gold standard variants in region: 
       1

========================================
```

