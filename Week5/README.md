# Week 5 Assignment - Group 3 Methicillin-resistant Staphylococcus aureus

# Week 5 Command Log

## Step 1: Write a Bash script:

```bash
# Expanded MRSA data download script
# Building on code from last week
# BioProject: PRJNA887926

# Original code from last week (NOT executed, just for reference)

echo "MRSA RNA-seq data download script"
echo "Building on last week's genome download"

# Original code from last week - setting up directories and downloading genome
echo "Setting up project structure..."

# Create main project directory
mkdir -p project
cd project/

# Create specific project directory  
mkdir -p mrsa_analysis
cd mrsa_analysis

# Activate environment
echo "Activating bioinfo environment..."
micromamba activate bioinfo

echo "Downloading reference genome (from last week)..."

# Get the genome FASTA file
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz"
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz"

# Unzip the files
gunzip *.gz

# Rename for easier use
mv GCF_000013425.1_ASM1342v1_genomic.fna S_aureus_USA300_genome.fna
mv GCF_000013425.1_ASM1342v1_genomic.gff S_aureus_USA300_annotation.gff

echo "Reference genome downloaded and renamed"

# ============================================

# To use this week's script:
# 1. Create file: nano download_mrsa.sh (paste below script content, Ctrl+O, Enter, Ctrl+X)
# 2. Make it executable: chmod +x download_mrsa.sh  
# 3. Run it: ./download_mrsa.sh

# ============================================

#!/bin/bash

# NEW CODE - Expanding from last week to download RNA-seq data
echo ""
echo "=== NEW THIS WEEK: Downloading RNA-seq samples ==="

# Create directory for RNA-seq data
mkdir -p rnaseq_data
mkdir -p metadata

# BioProject and SRR numbers identified last week
echo "BioProject: PRJNA887926"
echo "Control samples: SRR21835896, SRR21835897, SRR21835898"  
echo "Treatment samples: SRR21835899, SRR21835900, SRR21835901"

# Get project metadata
echo "Getting sample information..."
esearch -db sra -query "PRJNA887926[BioProject]" | efetch -format runinfo > metadata/runinfo.csv

# Pick one sample to download for 10x coverage
SAMPLE="SRR21835896"
echo "Downloading sample: $SAMPLE (Control replicate 3)"

# Download the SRA file
echo "Downloading SRA file..."
prefetch $SAMPLE --output-directory rnaseq_data/

# Convert to fastq with read limit for 10x coverage
echo "Converting to FASTQ (limiting reads for ~10x coverage)..."

# Coverage calculation:
# S. aureus genome = ~2.8 Mb
# 10x coverage = 28 Mb sequence needed  
# 150bp paired reads = 300bp per pair
# 28,000,000 / 300 = ~93,000 read pairs
# Using 100,000 to be safe

fasterq-dump rnaseq_data/$SAMPLE/$SAMPLE.sra --outdir rnaseq_data/ --split-files --stop 100000

# Compress fastq files
echo "Compressing FASTQ files..."
gzip rnaseq_data/*.fastq

echo ""
echo "Download complete!"
echo "Files downloaded:"
echo "- Reference genome: S_aureus_USA300_genome.fna"
echo "- Gene annotation: S_aureus_USA300_annotation.gff" 
echo "- RNA-seq sample: $SAMPLE (~100k read pairs for 10x coverage)"
echo ""
echo "10x coverage calculation:"
echo "- S. aureus genome size: ~2.8 million bp"
echo "- 10x coverage needs: 28 million bp of sequence"
echo "- With 150bp paired reads: ~93,000 pairs needed"
echo "- Downloaded 100,000 pairs to be safe"

# End of script
# To run this script again or modify it:
# - Edit the file: nano download_mrsa.sh
# - Run again: ./download_mrsa.sh
```

# Week 5 Assignment Questions

1. Identify the BioProject and SRR accession numbers for the sequencing data associated with the publication.

- BioProject: PRJNA887926
- SRR Accession Numbers:
   - Control samples: SRR21835896, SRR21835897, SRR21835898
   - Treatment samples: SRR21835899, SRR21835900, SRR21835901

