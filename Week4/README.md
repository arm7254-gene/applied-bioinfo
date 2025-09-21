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
# Calculate total genome size
grep -v "^#" S_aureus_USA300_annotation.gff | grep region | awk '{sum += $5} END {print "Total genome size:", sum " bp"}'
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
        
2. How big is the genome
   Total genome size: 17509287 bp
   
4. How many features of each type does the GFF file contain?
5. What is the longest gene?
6. What is its name and function?
7. Pick another gene and describe its name and function.
8. Look at the genomic features, are these closely packed, is there a lot of intragenomic space?
9. Using IGV estimate how much of the genome is covered by coding sequences.
10. Find alternative genome builds that could be used to perhaps answer a different question (find their accession numbers). 
