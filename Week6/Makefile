# Makefile for Week 6 Assignment

# Variables
GENOME_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
GENOME_FILE = genome.fna.gz

SAMPLE = SRR21835896
FASTQ_1 = $(SAMPLE)_1.fastq.gz
FASTQ_2 = $(SAMPLE)_2.fastq.gz
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
ANNOT  = S_aureus_USA300_annotation.gff.gz
META   = metadata/runinfo.csv
FASTQ1 = rnaseq_data/$(SAMPLE)_1.fastq.gz
FASTQ2 = rnaseq_data/$(SAMPLE)_2.fastq.gz

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
	fastq-dump -X 100000 --split-files --gzip --outdir rnaseq_data rnaseq_data/$(SAMPLE)/$(SAMPLE).sra

# Clean up
clean:
	rm -rf rnaseq_data metadata $(GENOME) $(ANNOT)

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

