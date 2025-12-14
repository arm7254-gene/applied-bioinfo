# ============================================================
# RNA-Seq Count Matrix Pipeline
# Author: A. Mercedes
# Week 13 Assignment
# ============================================================
# This Makefile automates:
#   1. Genome/annotation download
#   2. Read download
#   3. Genome indexing (HISAT2)
#   4. Alignment (HISAT2)
#   5. Feature counting (featureCounts)
#   6. Coverage tracks (BigWig)
# ============================================================
# Usage:
#   make usage
#   make genome
#   make fastq SAMPLE=HBR_1
#   make align SAMPLE=HBR_1
#   make count SAMPLE=HBR_1
# ============================================================

# Variables - can be overridden on command line
SAMPLE = HBR_1
NREADS = 1000000

# URLs
GENOME_URL = https://ftp.ensembl.org/pub/release-104/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.22.fa.gz
GTF_URL = https://ftp.ensembl.org/pub/release-104/gtf/homo_sapiens/Homo_sapiens.GRCh38.104.chr.gtf.gz

# Directories
READS_DIR = reads
GENOME_DIR = genome
BAM_DIR = bam
COUNTS_DIR = counts

# File paths
GENOME_FA = $(GENOME_DIR)/chr22.fa
GTF = $(GENOME_DIR)/chr22.gtf
R1 = $(READS_DIR)/$(SAMPLE)_R1.fq
BAM = $(BAM_DIR)/$(SAMPLE).bam
BW = $(BAM_DIR)/$(SAMPLE).bw
COUNT = $(COUNTS_DIR)/$(SAMPLE).counts.txt

# ============================================================
# Targets
# ============================================================

usage:
	@echo "RNA-Seq Count Matrix Pipeline"
	@echo "=============================="
	@echo ""
	@echo "Current settings:"
	@echo "  SAMPLE = $(SAMPLE)"
	@echo "  NREADS = $(NREADS)"
	@echo ""
	@echo "Targets:"
	@echo "  usage   - Show this help"
	@echo "  data    - Download UHR/HBR dataset"
	@echo "  genome  - Download reference genome (chr22) and GTF"
	@echo "  index   - Index genome with HISAT2"
	@echo "  fastq   - Verify reads exist for SAMPLE"
	@echo "  align   - Align reads and create BAM"
	@echo "  bw      - Create BigWig coverage track"
	@echo "  count   - Count reads per gene"
	@echo "  stats   - Show alignment statistics"
	@echo ""
	@echo "Examples:"
	@echo "  make fastq SAMPLE=HBR_1"
	@echo "  make align SAMPLE=UHR_2"
	@echo "  make count SAMPLE=HBR_3"

# Download genome and annotation
genome: $(GENOME_FA) $(GTF)

$(GENOME_FA):
	@echo "Downloading chromosome 22 reference..."
	mkdir -p $(GENOME_DIR)
	wget -q --show-progress $(GENOME_URL) -O $(GENOME_DIR)/chr22.fa.gz
	gunzip $(GENOME_DIR)/chr22.fa.gz

$(GTF):
	@echo "Downloading GTF annotation..."
	mkdir -p $(GENOME_DIR)
	wget -q --show-progress $(GTF_URL) -O $(GENOME_DIR)/chr22.gtf.gz
	gunzip $(GENOME_DIR)/chr22.gtf.gz
	@echo "Filtering for chromosome 22 only..."
	grep "^22" $(GENOME_DIR)/chr22.gtf > $(GTF).tmp
	mv $(GTF).tmp $(GTF)

# Index genome with HISAT2
index: $(GENOME_DIR)/chr22.1.ht2

$(GENOME_DIR)/chr22.1.ht2: $(GENOME_FA)
	@echo "Indexing genome with HISAT2..."
	hisat2-build $(GENOME_FA) $(GENOME_DIR)/chr22

# Download UHR/HBR dataset
data: uhr-hbr.tar.gz
	tar xzvf uhr-hbr.tar.gz

uhr-hbr.tar.gz:
	@echo "Downloading UHR/HBR RNA-seq dataset..."
	wget http://data.biostarhandbook.com/data/uhr-hbr.tar.gz

# Verify reads exist
fastq: $(R1)

$(R1): data
	@if [ ! -f $(R1) ]; then \
		echo "ERROR: $(R1) not found after download!"; \
		exit 1; \
	fi
	@echo "Reads found: $(R1)"

# Align reads
align: $(BAM).bai

$(BAM): $(GENOME_DIR)/chr22.1.ht2 $(R1)
	@echo "Aligning $(SAMPLE)..."
	mkdir -p $(BAM_DIR)
	hisat2 -x $(GENOME_DIR)/chr22 \
		-U $(R1) \
		--threads 4 \
		2> $(BAM).log \
		| samtools view -b - \
		| samtools sort -o $(BAM)

$(BAM).bai: $(BAM)
	samtools index $(BAM)
	@echo "Alignment complete: $(BAM)"

# Generate BigWig coverage track
bw: $(BW)

$(BW): $(BAM).bai
	@echo "Creating BigWig coverage track..."
	bamCoverage -b $(BAM) -o $(BW) --binSize 10
	@echo "BigWig created: $(BW)"

# Count reads per gene
count: $(COUNT)

$(COUNT): $(BAM).bai $(GTF)
	@echo "Counting reads per gene for $(SAMPLE)..."
	mkdir -p $(COUNTS_DIR)
	featureCounts -a $(GTF) \
		-o $(COUNT) \
		-t exon \
		-g gene_id \
		$(BAM)
	@echo "Counts saved to: $(COUNT)"

# Alignment statistics
stats: $(BAM).bai
	@echo ""
	@echo "=== Alignment Statistics for $(SAMPLE) ==="
	@samtools flagstat $(BAM)
	@echo ""
	@echo "Alignment log: $(BAM).log"

# Clean up
clean:
	rm -rf $(BAM_DIR) $(COUNTS_DIR)
	@echo "Cleaned alignments and counts"

clean-all:
	rm -rf $(GENOME_DIR) $(BAM_DIR) $(COUNTS_DIR)
	@echo "Cleaned all generated files (keeping reads)"
