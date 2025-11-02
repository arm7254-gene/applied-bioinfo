# ============================================================
# Makefile for MRSA RNA-seq Analysis (Single Sample)
# Author: A. Mercedes
# ============================================================
# Usage:
#   make usage                       # Show this help
#   make genome                      # Download genome once
#   make metadata                    # Download metadata / create design.csv
#   make index                        # Index genome once
#
# Single sample targets (require SAMPLE and SRR variables):
#   make fastq SAMPLE=... SRR=...    # Download FASTQ reads for one sample
#   make fastqc SAMPLE=...           # Run FASTQC on one sample
#   make align SAMPLE=...            # Align one sample
#   make stats SAMPLE=...            # Generate alignment stats for one sample
#   make bigwig SAMPLE=...           # Create coverage bigWig for one sample
#
# See Looper.mk for batch processing all samples
# ============================================================

# ========== VARIABLES ==========
ACC_GCF = GCF_000013425.1
GENOME_NAME = S_aureus_USA300
TAXON = "Staphylococcus aureus"

BIOPROJECT = PRJNA887926
NREADS = 140000

GENOME_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz
ANNOT_URL = https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz

GENOME_DIR = genome
READS_DIR = reads
ALIGN_DIR = alignments
FASTQC_DIR = fastqc_reports
META_DIR = metadata

DESIGN_FILE = design.csv                    # Top-level design file (user creates)
META_DESIGN = $(META_DIR)/design.csv        # Downloaded metadata design file

# Reference files
GENOME_GZ = $(GENOME_DIR)/$(GENOME_NAME).fna.gz
GENOME_FA = $(GENOME_DIR)/$(GENOME_NAME).fna
GFF_GZ = $(GENOME_DIR)/$(GENOME_NAME).gff.gz
GFF = $(GENOME_DIR)/$(GENOME_NAME).gff
GENOME_FAI = $(GENOME_FA).fai
CHROM_SIZES = $(GENOME_DIR)/$(GENOME_NAME).chrom.sizes
INDEX_PREFIX = $(GENOME_FA)

# Sample-specific files (must set SAMPLE and SRR variables)
SAMPLE ?= 
SRR ?= 

FASTQ1 = $(READS_DIR)/$(SAMPLE)_1.fastq.gz
FASTQ2 = $(READS_DIR)/$(SAMPLE)_2.fastq.gz
BAM_UNSORTED = $(ALIGN_DIR)/$(SAMPLE).bam
BAM = $(ALIGN_DIR)/$(SAMPLE).sorted.bam
BAM_INDEX = $(BAM).bai
STATS = $(ALIGN_DIR)/$(SAMPLE).stats.txt
BIGWIG = $(ALIGN_DIR)/$(SAMPLE).bw

# ========== RULES ==========

# ========== Usage (first target - default) ==========
usage:
	@echo "============================================================"
	@echo "MRSA RNA-seq Analysis Makefile"
	@echo "============================================================"
	@echo ""
	@echo "Setup targets (run once):"
	@echo "  make genome          Download reference genome"
	@echo "  make metadata        Download SRA metadata"
	@echo "  make index           Index genome for alignment"
	@echo ""
	@echo "Single sample targets (set SAMPLE and SRR):"
	@echo "  make fastq SAMPLE=SRS15348647 SRR=SRR21835896"
	@echo "  make fastqc SAMPLE=SRS15348647"
	@echo "  make align SAMPLE=SRS15348647"
	@echo "  make stats SAMPLE=SRS15348647"
	@echo "  make bigwig SAMPLE=SRS15348647"
	@echo ""
	@echo "Batch processing:"
	@echo "  See Looper.mk for processing all samples"
	@echo "  make -f Looper.mk all"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           Remove all generated files"
	@echo "  make clean-align     Remove only alignment files"
	@echo "============================================================"

# ========== Genome download ==========
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

# ========== Index genome ==========
index: $(INDEX_PREFIX).bwt $(CHROM_SIZES)

$(INDEX_PREFIX).bwt: $(GENOME_FA)
	bwa index $(GENOME_FA)

$(GENOME_FAI): $(GENOME_FA)
	samtools faidx $(GENOME_FA)

$(CHROM_SIZES): $(GENOME_FAI)
	cut -f1,2 $(GENOME_FAI) > $(CHROM_SIZES)

# ========== Metadata download ==========
metadata: $(META_DESIGN)

$(META_DESIGN):
	mkdir -p $(META_DIR)
	esearch -db sra -query "$(BIOPROJECT)[BioProject]" | efetch -format runinfo > $(META_DIR)/runinfo_full.csv
	echo "Run,Sample" > $(META_DESIGN)
	tail -n +2 $(META_DIR)/runinfo_full.csv | cut -d',' -f1,30 >> $(META_DESIGN)

# ========== Download FASTQ reads (single sample) ==========
fastq: $(FASTQ1) $(FASTQ2)

$(FASTQ1) $(FASTQ2):
	@if [ -z "$(SAMPLE)" ] || [ -z "$(SRR)" ]; then \
		echo "Error: Must specify SAMPLE and SRR variables"; \
		echo "Example: make fastq SAMPLE=SRS15348647 SRR=SRR21835896"; \
		exit 1; \
	fi
	mkdir -p $(READS_DIR)
	fastq-dump -X $(NREADS) --split-files --gzip --outdir $(READS_DIR) $(SRR)
	mv $(READS_DIR)/$(SRR)_1.fastq.gz $(FASTQ1)
	mv $(READS_DIR)/$(SRR)_2.fastq.gz $(FASTQ2)

# ========== FASTQC reports (single sample) ==========
fastqc: $(FASTQC_DIR)/$(SAMPLE)_1_fastqc.html

$(FASTQC_DIR)/$(SAMPLE)_1_fastqc.html: $(FASTQ1) $(FASTQ2)
	@if [ -z "$(SAMPLE)" ]; then \
		echo "Error: Must specify SAMPLE variable"; \
		echo "Example: make fastqc SAMPLE=SRS15348647"; \
		exit 1; \
	fi
	mkdir -p $(FASTQC_DIR)
	fastqc -o $(FASTQC_DIR) $(FASTQ1) $(FASTQ2)

# ========== Align reads to reference genome (single sample) ==========
align: $(BAM) $(BAM_INDEX)

$(BAM): $(FASTQ1) $(FASTQ2) $(INDEX_PREFIX).bwt
	@if [ -z "$(SAMPLE)" ]; then \
		echo "Error: Must specify SAMPLE variable"; \
		echo "Example: make align SAMPLE=SRS15348647"; \
		exit 1; \
	fi
	mkdir -p $(ALIGN_DIR)
	bwa mem $(GENOME_FA) $(FASTQ1) $(FASTQ2) | samtools view -b -o $(BAM_UNSORTED)
	samtools sort $(BAM_UNSORTED) -o $(BAM)
	rm $(BAM_UNSORTED)

$(BAM_INDEX): $(BAM)
	samtools index $(BAM)

# ========== Generate alignment statistics (single sample) ==========
stats: $(STATS)

$(STATS): $(BAM)
	@if [ -z "$(SAMPLE)" ]; then \
		echo "Error: Must specify SAMPLE variable"; \
		echo "Example: make stats SAMPLE=SRS15348647"; \
		exit 1; \
	fi
	samtools flagstat $(BAM) > $(STATS)
	@echo "=== Alignment Statistics for $(SAMPLE) ==="
	@cat $(STATS)

# ========== Generate bigWig coverage tracks (single sample) ==========
bigwig: $(BIGWIG)

$(BIGWIG): $(BAM) $(BAM_INDEX) $(CHROM_SIZES)
	@if [ -z "$(SAMPLE)" ]; then \
		echo "Error: Must specify SAMPLE variable"; \
		echo "Example: make bigwig SAMPLE=SRS15348647"; \
		exit 1; \
	fi
	bedtools genomecov -ibam $(BAM) -bg | sort -k1,1 -k2,2n > $(ALIGN_DIR)/$(SAMPLE).bedGraph
	bedGraphToBigWig $(ALIGN_DIR)/$(SAMPLE).bedGraph $(CHROM_SIZES) $(BIGWIG)
	rm $(ALIGN_DIR)/$(SAMPLE).bedGraph

# ========== Clean files ==========
clean:
	rm -rf $(GENOME_DIR) $(READS_DIR) $(ALIGN_DIR) $(FASTQC_DIR) $(META_DIR)

clean-align:
	rm -rf $(ALIGN_DIR)

.PHONY: usage genome metadata fastq fastqc index align stats bigwig clean clean-align
