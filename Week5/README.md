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

fastq-dump -X 100000 --outdir rnaseq_data/ --split-files rnaseq_data/$SAMPLE/$SAMPLE.sra

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
## Step 2: Check Stats

```bash
# Navigate to rnaseq_data directory where FASTQ files are stored
cd rnaseq_data/

# Generate basic statistics for the RNA-seq data (read count, length, etc.)
seqkit stats SRR21835896_1.fastq.gz

# > **Output**
file                    format  type  num_seqs     sum_len  min_len  avg_len  max_len
SRR21835896_1.fastq.gz  FASTQ   DNA    100,000  10,100,000      101      101      101
#...
```

## Step 3: Run FASTQC

```bash
# FASTQC Quality Control Script
# Run quality analysis on downloaded RNA-seq data

# ============================================
# To use this script:
# 1. Create file: nano run_fastqc.sh (paste content (#!/bin/bash..), Ctrl+O, Enter, Ctrl+X)
# 2. Make it executable: chmod +x run_fastqc.sh
# 3. Run it: ./run_fastqc.sh
# ============================================

#!/bin/bash

echo "Running FASTQC quality control analysis..."

# Set sample name (same as in download script)
SAMPLE="SRR21835896"

echo "Analyzing sample: $SAMPLE"

# Create output directory for FASTQC reports
mkdir -p fastqc_reports

# Check if the fastq files exist
if [ ! -f "rnaseq_data/${SAMPLE}_1.fastq.gz" ]; then
    echo "ERROR: FASTQ files not found!"
    echo "Make sure you've run the download script first"
    exit 1
fi

# Run FASTQC on both paired-end files
echo "Running FASTQC on paired-end reads..."
fastqc rnaseq_data/${SAMPLE}_1.fastq.gz rnaseq_data/${SAMPLE}_2.fastq.gz --outdir fastqc_reports

# Check if FASTQC completed successfully
if [ -f "fastqc_reports/${SAMPLE}_1_fastqc.html" ]; then
    echo ""
    echo "FASTQC analysis completed successfully!"
    echo ""
    echo "Quality reports generated:"
    echo "- Read 1 report: fastqc_reports/${SAMPLE}_1_fastqc.html" 
    echo "- Read 2 report: fastqc_reports/${SAMPLE}_2_fastqc.html"
    echo ""
    echo "Files also created:"
    ls fastqc_reports/
    echo ""
    echo "To view quality reports:"
    echo "1. Open the .html files in a web browser"
    echo "2. Or use: open fastqc_reports/${SAMPLE}_1_fastqc.html (on Mac)"
else
    echo "ERROR: FASTQC analysis failed"
    echo "Check that fastqc is installed and fastq files exist"
    exit 1
fi

echo "FASTQC analysis complete!"

```

# Week 5 Assignment Questions

1. Identify the BioProject and SRR accession numbers for the sequencing data associated with the publication.

- BioProject: PRJNA887926
- SRR Accession Numbers:
   - Control samples: SRR21835896, SRR21835897, SRR21835898
   - Treatment samples: SRR21835899, SRR21835900, SRR21835901
 
2. FASTQC Summarized Findings

FASTQC Quality Report Summary
- Sample: SRR21835896_1 (Control replicate, RNA-seq data)
- Overall Quality: GOOD - suitable for downstream analysis

**Key Metrics:**

* 15.75 million high-quality reads (101 bp each)
* 33% GC content (appropriate for S. aureus)
* Zero poor-quality sequences flagged

**Notable Findings:**

* High sequence duplication detected (top sequence = 2.38% of reads)
* This is typical for bacterial RNA-seq due to highly expressed genes

**Conclusion:** Data quality is adequate for gene expression analysis and comparison with propionate-treated samples.
