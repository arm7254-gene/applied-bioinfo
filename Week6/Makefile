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
