# Week 6 Assignment

# Week 6 Command Log

## Step 1: Transform the script into a Makefile that includes rules for: Obtaining the genome and Downloading sequencing reads from SRA

```bash

# Navigate to the week 6 directory
cd /Users/annettemercedes/Documents/GitHub/applied-bioinfo/Week6

# Create the Makefile with a text editor.
nano Makefile

# Paste the following:

# Makefile for Week 6 Assignment
# Automates downloading MRSA genome, annotation, metadata, and RNA-seq reads

# Variables
BIOPROJECT = PRJNA887926
SAMPLE = SRR21835896

# Genome + annotation URLs
GENOME_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
ANNOT_URL  = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz

# Output files
GENOME = S_aureus_USA300_genome.fna.gz
GENOME_UNZIPPED = S_aureus_USA300_genome.fna
ANNOT  = S_aureus_USA300_annotation.gff.gz
META   = metadata/runinfo.csv
FASTQ1 = rnaseq_data/$(SAMPLE)_1.fastq.gz
FASTQ2 = rnaseq_data/$(SAMPLE)_2.fastq.gz

# Alignment output files
INDEX_PREFIX = $(GENOME_UNZIPPED)
BAM_UNSORTED = alignments/$(SAMPLE).bam
BAM_SORTED = alignments/$(SAMPLE).sorted.bam
BAM_INDEX = $(BAM_SORTED).bai

# Default target
all: $(GENOME) $(ANNOT) $(META) $(FASTQ1) $(FASTQ2)

# Rule: metadata
$(META):
	mkdir -p metadata
	esearch -db sra -query "$(BIOPROJECT)[BioProject]" | efetch -format runinfo > $(META)

# Rule: genome
$(GENOME):
	wget "$(GENOME_URL)" -O $(GENOME)

# Rule: annotation
$(ANNOT):
	wget "$(ANNOT_URL)" -O $(ANNOT)

# Rule: download reads (~100k pairs for ~10x coverage)
$(FASTQ1) $(FASTQ2):
	mkdir -p rnaseq_data
	prefetch $(SAMPLE) --output-directory rnaseq_data/
	fastq-dump -X 140000 --split-files --gzip --outdir rnaseq_data rnaseq_data/$(SAMPLE)/$(SAMPLE).sra

# Rule: unzip genome (needed for indexing)
$(GENOME_UNZIPPED): $(GENOME)
	gunzip -c $(GENOME) > $(GENOME_UNZIPPED)

# Rule: index the genome
index: $(GENOME_UNZIPPED).bwt

$(GENOME_UNZIPPED).bwt: $(GENOME_UNZIPPED)
	bwa index $(GENOME_UNZIPPED)

# Rule: align reads and generate sorted, indexed BAM file
align: $(BAM_SORTED) $(BAM_INDEX)

$(BAM_SORTED): $(FASTQ1) $(FASTQ2) $(GENOME_UNZIPPED).bwt
	mkdir -p alignments
	bwa mem $(GENOME_UNZIPPED) $(FASTQ1) $(FASTQ2) | samtools view -b -o $(BAM_UNSORTED)
	samtools sort $(BAM_UNSORTED) -o $(BAM_SORTED)
	rm $(BAM_UNSORTED)

$(BAM_INDEX): $(BAM_SORTED)
	samtools index $(BAM_SORTED)

# Clean up
clean:
	rm -rf rnaseq_data metadata alignments $(GENOME) $(ANNOT) $(GENOME_UNZIPPED) $(GENOME_UNZIPPED).*

.PHONY: all clean index align

# Alignment statistics file
BAM_STATS = alignments/$(SAMPLE).stats.txt

# Rule: generate alignment statistics
stats: $(BAM_STATS)

$(BAM_STATS): $(BAM_SORTED)
	samtools flagstat $(BAM_SORTED) > $(BAM_STATS)
	@echo "=== Alignment Statistics ===" 
	@cat $(BAM_STATS)

# Save and close
# In nano: press CTRL + O → Enter → CTRL + X
```
## Step 2: Explain the use of the Makefile in your project.

Using the Makefile

This week’s assignment required transforming last week’s bash script into a Makefile. The Makefile automates two main tasks:
1. Download the reference genome from NCBI RefSeq
2. Download sequencing reads from SRA (sample SRR21835896)

**Commands:**
* Run everything in sequence:
```bash
make && make index && make align
```
* To run an individual step:
```bash
make           # Download genome, annotation, metadata, and reads
make index     # Index the genome
make align     # Align reads and create sorted BAM
make clean     # Remove all generated files
```
* To generate alignment statistics for the BAM file
```bash
make stats
```
* To clean up (remove downloaded files):
```bash
make clean
```

## Step 3: Visualize the resulting BAM files for both simulated reads and reads downloaded from SRA.

# Week 6 Assignment Questions

1. What percentage of reads aligned to the genome?
   - 99.01%
   - Total primary reads: 280,000
   - Primary mapped reads: 277,238
   - Percentage: 277,238 / 280,000 = 99.01%
2. What was the expected average coverage?
   - Given:
     * Number of read pairs: 140,000
     * Read length: 101 bp (from your seqkit analysis)
     * Total reads: 280,000 (140,000 × 2)
     * Genome size: S. aureus USA300 ≈ 2.8 Mb (2,800,000 bp)
```bash
Total sequenced bases = 280,000 reads × 101 bp = 28,280,000 bp

Expected coverage = Total bases / Genome size
                  = 28,280,000 / 2,800,000
                  = 10.1x
```
3. What is the observed average coverage?
   To get the actual observed coverage, you need to run:
   ```bash
   samtools depth alignments/SRR21835896.sorted.bam | awk '{sum+=$3} END {print "Average coverage: " sum/NR}'
   ```
   - Average coverage: 22.1946
4. How much does the coverage vary across the genome? (Provide a visual estimate.)
   
