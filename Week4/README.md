# Week 4 Assignment - Group 3 Methicillin-resistant Staphylococcus aureus

# Week 4 Command Log

Step 1: Download the Reference Genome and Annotations
```bash
# Create main project directory
mkdir project

#change directories
cd project/

# Create specific project directory
mkdir -p mrsa_analysis
cd mrsa_analysis

#activate environment
micromamba activate bioinfo

# Get the genome FASTA file
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz"
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz"

# Unzip the files
gunzip *.gz

# Rename for easier use
mv GCF_000013425.1_ASM1342v1_genomic.fna S_aureus_USA300_genome.fna
mv GCF_000013425.1_ASM1342v1_genomic.gff S_aureus_USA300_annotation.gff

# Quick check of what we downloaded
echo "Genome file:"
ls -lh S_aureus_USA300_genome.fna
echo "First few lines of genome:"
head -3 S_aureus_USA300_genome.fna

echo -e "\nAnnotation file:"
ls -lh S_aureus_USA300_annotation.gff
echo "First few annotation lines:"
head -5 S_aureus_USA300_annotation.gff
```
Step 2: Basic Analysis Commands
```bash

```
# Week 4 Assignment Questions

1. Identify the accession numbers for the genome
   * Reference genome: GCF_000013425.1 (or NC_007793.1)
   * Sample data: BioProject ID PRJNA887926
      * Control replicate 1 - SRR21835898
      * Control replicate 2 - SRR21835897
      * Control replicate 3 - SRR21835896
      * Treatment replicate 1 - SRR21835901	
      * Treatment replicate 2 - SRR21835900
      * Treatment replicate 3 - SRR21835899
