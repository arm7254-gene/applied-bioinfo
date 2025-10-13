# ============================================================
# Makefile for MRSA RNA-seq Analysis
# Author: A. Mercedes
# ============================================================
# Usage:
#   make genome                      # Download genome once
#   make fastq SRR=SRR21835896       # Download reads (customizable)
#   make index                       # Index genome once
#   make align SRR=SRR21835896       # Align specific sample
#   make stats SRR=SRR21835896       # Get alignment stats
#   make bigwig SRR=SRR21835896      # Create coverage track
# ============================================================

# ========== VARIABLES ==========

# Genome identifiers (fixed for S. aureus USA300)
ACC_GCF = GCF_000013425.1
GENOME_NAME = S_aureus_USA300
TAXON = "Staphylococcus aureus"

# Sample parameters (can override on command line)
SRR = SRR21835896
BIOPROJECT = PRJNA887926
NREADS = 140000

# URLs for reference data
GENOME_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
ANNOT_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz

# Directory organization
GENOME_DIR = genome
READS_DIR = reads
ALIGN_DIR = alignments
META_DIR = metadata

# Reference files (same for all samples)
GENOME_GZ = $(GENOME_DIR)/$(GENOME_NAME).fna.gz
GENOME_FA = $(GENOME_DIR)/$(GENOME_NAME).fna
GFF_GZ = $(GENOME_DIR)/$(GENOME_NAME).gff.gz
GFF = $(GENOME_DIR)/$(GENOME_NAME).gff
CHROM_SIZES = $(GENOME_DIR)/chrom.sizes

# Index files
INDEX_PREFIX = $(GENOME_FA)

# Sample-specific files (change based on SRR parameter)
FASTQ1 = $(READS_DIR)/$(SRR)_1.fastq.gz
FASTQ2 = $(READS_DIR)/$(SRR)_2.fastq.gz
BAM_UNSORTED = $(ALIGN_DIR)/$(SRR).bam
BAM = $(ALIGN_DIR)/$(SRR).sorted.bam
BAM_INDEX = $(BAM).bai
STATS = $(ALIGN_DIR)/$(SRR).stats.txt
BIGWIG = $(ALIGN_DIR)/$(SRR).bw

# Metadata
RUNINFO = $(META_DIR)/runinfo.csv

# ========== RULES ==========

# Download reference genome
genome: $(GENOME_FA) $(GFF)

$(GENOME_GZ):
	mkdir -p $(GENOME_DIR)
	wget "$(GENOME_URL)" -O $(GENOME_GZ)

$(GENOME_FA): $(GENOME_GZ)
	gunzip -c $(GENOME_GZ) > $(GENOME_FA)

$(GFF_GZ):
	mkdir -p $(GENOME_DIR)
	wget "$(ANNOT_URL)" -O $(GFF_GZ)

$(GFF): $(GFF_GZ)
	gunzip -c $(GFF_GZ) > $(GFF)

# Download metadata
metadata: $(RUNINFO)

$(RUNINFO):
	mkdir -p $(META_DIR)
	esearch -db sra -query "$(BIOPROJECT)[BioProject]" | efetch -format runinfo > $(RUNINFO)

# Download reads for specified SRR
fastq: $(FASTQ1) $(FASTQ2)

$(FASTQ1) $(FASTQ2):
	mkdir -p $(READS_DIR)
	prefetch $(SRR) --output-directory $(READS_DIR)/
	fastq-dump -X $(NREADS) --split-files --gzip --outdir $(READS_DIR) $(READS_DIR)/$(SRR)/$(SRR).sra

# Index genome with BWA
index: $(INDEX_PREFIX).bwt

$(INDEX_PREFIX).bwt: $(GENOME_FA)
	bwa index $(GENOME_FA)

# Align reads to reference genome
align: $(BAM) $(BAM_INDEX)

$(BAM): $(FASTQ1) $(FASTQ2) $(INDEX_PREFIX).bwt
	mkdir -p $(ALIGN_DIR)
	bwa mem $(GENOME_FA) $(FASTQ1) $(FASTQ2) | samtools view -b -o $(BAM_UNSORTED)
	samtools sort $(BAM_UNSORTED) -o $(BAM)
	rm $(BAM_UNSORTED)

$(BAM_INDEX): $(BAM)
	samtools index $(BAM)

# Generate alignment statistics
stats: $(STATS)

$(STATS): $(BAM)
	samtools flagstat $(BAM) > $(STATS)
	@echo "=== Alignment Statistics for $(SRR) ==="
	@cat $(STATS)

# Path to chromosome sizes file (defined first so Make can see it)
CHROM_SIZES = $(GENOME_DIR)/$(GENOME_NAME).chrom.sizes
GENOME_FAI = $(GENOME_FA).fai

# Generate bigWig coverage track
bigwig: $(BIGWIG)

$(BIGWIG): $(BAM) $(BAM_INDEX) $(CHROM_SIZES)
	# Convert BAM to bedGraph (sorted)
	bedtools genomecov -ibam $(BAM) -bg | sort -k1,1 -k2,2n > $(ALIGN_DIR)/$(SRR).bedGraph
	# Convert bedGraph to bigWig
	bedGraphToBigWig $(ALIGN_DIR)/$(SRR).bedGraph $(CHROM_SIZES) $(BIGWIG)
	# Clean up intermediate file
	rm $(ALIGN_DIR)/$(SRR).bedGraph

# Create chromosome sizes file from FASTA index
$(CHROM_SIZES): $(GENOME_FAI)
	cut -f1,2 $(GENOME_FAI) > $(CHROM_SIZES)

# Index reference genome (needed for bigWig and chrom.sizes)
$(GENOME_FAI): $(GENOME_FA)
	samtools faidx $(GENOME_FA)

# Remove all generated files
clean:
	rm -rf $(GENOME_DIR) $(READS_DIR) $(ALIGN_DIR) $(META_DIR)

# Remove only alignment files (keep genome and reads)
clean-align:
	rm -rf $(ALIGN_DIR)

.PHONY: genome metadata fastq index align stats bigwig clean clean-align
