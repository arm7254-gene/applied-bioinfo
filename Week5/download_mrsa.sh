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
