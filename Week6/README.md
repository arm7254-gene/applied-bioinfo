# Week 6 Assignment

# Week 6 Command Log

## Step 1: Transform the script into a Makefile that includes rules for: Obtaining the genome and Downloading sequencing reads from SRA

```bash

# Navigate to the week 6 directory
cd /Users/annettemercedes/Documents/GitHub/applied-bioinfo/Week6

# Create the Makefile with a text editor.
nano Makefile

# Paste this minimal version (covers genome + reads)
# Makefile for Week 6 Assignment

# Variables
GENOME_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
GENOME_FILE = genome.fna.gz

SAMPLE = SRR21835896
FASTQ_1 = $(SAMPLE)_1.fastq.gz
FASTQ_2 = $(SAMPLE)_2.fastq.gz

# Default target
all: $(GENOME_FILE) $(FASTQ_1) $(FASTQ_2)

# Rule to download genome
$(GENOME_FILE):
	curl -L -o $(GENOME_FILE) $(GENOME_URL)

# Rule to download reads
$(FASTQ_1) $(FASTQ_2):
	fastq-dump -X 100000 --split-files --gzip $(SAMPLE)

# Clean up
clean:
	rm -f $(GENOME_FILE) $(FASTQ_1) $(FASTQ_2)

# Save and close
# In nano: press CTRL + O → Enter → CTRL + X
```
## Step 2: Explain the use of the Makefile in your project.

Using the Makefile

This week’s assignment required transforming last week’s bash script into a Makefile. The Makefile automates two main tasks:
1. Download the reference genome from NCBI RefSeq
2. Download sequencing reads from SRA (sample SRR21835896)

**Commands:**
* To run the full workflow (download genome + reads):
```bash
make
```
* To run an individual step:
```bash
make genome.fna.gz        # download genome only
make SRR21835896_1.fastq.gz   # download reads only
```
* To clean up (remove downloaded files):
```bash
make clean
```

## Step 3: Visualize the resulting BAM files for both simulated reads and reads downloaded from SRA.

# Week 6 Assignment Questions

1. What percentage of reads aligned to the genome?
2. What was the expected average coverage?
3. What is the observed average coverage?
4. How much does the coverage vary across the genome? (Provide a visual estimate.)
