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

