# ============================================================
# Makefile for MRSA RNA-seq Analysis
# Author: A. Mercedes
# ============================================================
# Usage:
#   make genome                      # Download genome once
#   make metadata                    # Download metadata / create design.csv
#   make fastq                        # Download FASTQ reads named by Sample
#   make fastqc                       # Run FASTQC on all samples
#   make index                        # Index genome once
#   make align                        # Align all samples (BAM named by Sample)
#   make stats                        # Generate alignment stats per Sample
#   make bigwig                       # Create coverage bigWig per Sample
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

DESIGN_FILE = $(META_DIR)/design.csv   # === NEW ===

# Reference files
GENOME_GZ = $(GENOME_DIR)/$(GENOME_NAME).fna.gz
GENOME_FA = $(GENOME_DIR)/$(GENOME_NAME).fna
GFF_GZ = $(GENOME_DIR)/$(GENOME_NAME).gff.gz
GFF = $(GENOME_DIR)/$(GENOME_NAME).gff
GENOME_FAI = $(GENOME_FA).fai
CHROM_SIZES = $(GENOME_DIR)/$(GENOME_NAME).chrom.sizes
INDEX_PREFIX = $(GENOME_FA)

# Sample-specific files (placeholders, filled by GNU parallel)
SRR ?= SRR21835896
SAMPLE ?= SRS15348647

FASTQ1 = $(READS_DIR)/$(SAMPLE)_1.fastq.gz  # === NEW: renamed by Sample
FASTQ2 = $(READS_DIR)/$(SAMPLE)_2.fastq.gz
BAM_UNSORTED = $(ALIGN_DIR)/$(SAMPLE).bam
BAM = $(ALIGN_DIR)/$(SAMPLE).sorted.bam
BAM_INDEX = $(BAM).bai
STATS = $(ALIGN_DIR)/$(SAMPLE).stats.txt
BIGWIG = $(ALIGN_DIR)/$(SAMPLE).bw

# ========== RULES ==========

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
index: $(INDEX_PREFIX).bwt

$(INDEX_PREFIX).bwt: $(GENOME_FA)
	bwa index $(GENOME_FA)

$(GENOME_FAI): $(GENOME_FA)
	samtools faidx $(GENOME_FA)

$(CHROM_SIZES): $(GENOME_FAI)
	cut -f1,2 $(GENOME_FAI) > $(CHROM_SIZES)

# ========== Metadata / design.csv ==========
metadata: $(DESIGN_FILE)

$(DESIGN_FILE):
	mkdir -p $(META_DIR)
	esearch -db sra -query "$(BIOPROJECT)[BioProject]" | efetch -format runinfo > $(META_DIR)/runinfo_full.csv
	cut -d',' -f1,2 $(META_DIR)/runinfo_full.csv > $(DESIGN_FILE)

# ========== Download FASTQ reads (renamed by Sample) === NEW ==========
fastq:
	mkdir -p $(READS_DIR)
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j 4 \
		'prefetch {Run} --output-directory $(READS_DIR)/ && \
		 fastq-dump -X $(NREADS) --split-files --gzip --outdir $(READS_DIR) $(READS_DIR)/{Run}/{Run}.sra && \
		 mv $(READS_DIR)/{Run}_1.fastq.gz $(READS_DIR)/{Sample}_1.fastq.gz && \
		 mv $(READS_DIR)/{Run}_2.fastq.gz $(READS_DIR)/{Sample}_2.fastq.gz'

# ========== FASTQC reports === NEW ==========
fastqc:
	mkdir -p $(FASTQC_DIR)
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j 4 \
		fastqc -o $(FASTQC_DIR) $(READS_DIR)/{Sample}_1.fastq.gz $(READS_DIR)/{Sample}_2.fastq.gz

# ========== Align reads to reference genome ==========
align:
	mkdir -p $(ALIGN_DIR)
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j 4 \
		make SRR={Run} SAMPLE={Sample} single_align

.PHONY: single_align
single_align: $(BAM) $(BAM_INDEX)

$(BAM): $(FASTQ1) $(FASTQ2)
	bwa mem $(GENOME_FA) $(FASTQ1) $(FASTQ2) | samtools view -b -o $(BAM_UNSORTED)
	samtools sort $(BAM_UNSORTED) -o $(BAM)
	rm $(BAM_UNSORTED)

$(BAM_INDEX): $(BAM)
	samtools index $(BAM)

# ========== Generate alignment statistics ==========
stats:
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j 4 \
		make SAMPLE={Sample} single_stats

.PHONY: single_stats
single_stats: $(STATS)

$(STATS): $(BAM)
	samtools flagstat $(BAM) > $(STATS)
	@echo "=== Alignment Statistics for $(SAMPLE) ==="
	@cat $(STATS)

# ========== Generate bigWig coverage tracks ==========
bigwig:
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j 4 \
		make SAMPLE={Sample} single_bw

.PHONY: single_bw
single_bw: $(BIGWIG)

$(BIGWIG): $(BAM) $(BAM_INDEX) $(CHROM_SIZES)
	bedtools genomecov -ibam $(BAM) -bg | sort -k1,1 -k2,2n > $(ALIGN_DIR)/$(SAMPLE).bedGraph
	bedGraphToBigWig $(ALIGN_DIR)/$(SAMPLE).bedGraph $(CHROM_SIZES) $(BIGWIG)
	rm $(ALIGN_DIR)/$(SAMPLE).bedGraph

# ========== Clean files ==========
clean:
	rm -rf $(GENOME_DIR) $(READS_DIR) $(ALIGN_DIR) $(FASTQC_DIR) $(META_DIR)

clean-align:
	rm -rf $(ALIGN_DIR)

.PHONY: genome metadata fastq fastqc index align stats bigwig clean clean-align

