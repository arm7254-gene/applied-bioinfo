# Week 5 Assignment - Group 3 Methicillin-resistant Staphylococcus aureus

# Week 5 Command Log

```bash
#!/bin/bash

# Simple script to download MRSA RNA-seq data
# BioProject: PRJNA887926

echo "Downloading MRSA data from BioProject PRJNA887926"

# Make directories
mkdir -p mrsa_data
cd mrsa_data
mkdir metadata fastq reference

# Get the sample information (from last week)
echo "BioProject: PRJNA887926"
echo "Control samples: SRR21835896, SRR21835897, SRR21835898" 
echo "Treatment samples: SRR21835899, SRR21835900, SRR21835901"

# Download metadata
echo "Getting project info..."
esearch -db sra -query "PRJNA887926[BioProject]" | efetch -format runinfo > metadata/runinfo.csv

# Pick one sample to download - using first control sample
SAMPLE="SRR21835896"
echo "Downloading sample: $SAMPLE"

# Download the SRA file
prefetch $SAMPLE --output-directory ./

# Convert to fastq but only get some reads for 10x coverage
# S. aureus genome is ~2.8 Mb, so 10x coverage = 28 Mb sequence
# With 150bp paired reads, need about 93,000 read pairs
echo "Converting to fastq (limiting to ~100k reads for 10x coverage)..."
fasterq-dump $SAMPLE/$SAMPLE.sra --outdir fastq/ --split-files --stop 100000

# Compress the files
gzip fastq/*.fastq

# Download reference genome
echo "Downloading reference genome..."
cd reference
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz"
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz" 
gunzip *.gz
cd ..

echo "Done! Downloaded:"
echo "- Sample $SAMPLE with ~100k read pairs"  
echo "- Reference genome and annotation"
echo "- Should give about 10x coverage of S. aureus genome"

# How I calculated 10x coverage:
# S. aureus genome = ~2.8 million bp
# 10x coverage = 28 million bp of sequence needed
# 150bp paired reads (300bp total per pair)
# 28,000,000 / 300 = ~93,000 read pairs needed
# I used 100,000 to be safe
```

# Week 5 Assignment Questions

1. Identify the BioProject and SRR accession numbers for the sequencing data associated with the publication.

- BioProject: PRJNA887926
- SRR Accession Numbers:
   - Control samples: SRR21835896, SRR21835897, SRR21835898
   - Treatment samples: SRR21835899, SRR21835900, SRR21835901

