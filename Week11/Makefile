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
#   make vcf SAMPLE=...              # Call variants for one sample
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
VCF_DIR = variants

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

# Variant calling files
RAW_VCF = $(VCF_DIR)/$(SAMPLE).raw.vcf.gz
FILTERED_VCF = $(VCF_DIR)/$(SAMPLE).vcf.gz
VCF_INDEX = $(FILTERED_VCF).tbi
VCF_STATS = $(VCF_DIR)/$(SAMPLE).vcf.stats.txt

# Multisample VCF
MULTISAMPLE_VCF = $(VCF_DIR)/all_samples.vcf.gz
MULTISAMPLE_INDEX = $(MULTISAMPLE_VCF).tbi
MULTISAMPLE_STATS = $(VCF_DIR)/all_samples.vcf.stats.txt

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
	@echo "  make vcf SAMPLE=SRS15348647"
	@echo ""
	@echo "Multisample analysis:"
	@echo "  make merge-vcf       Merge all sample VCFs into multisample VCF"
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

# ========== Variant calling (single sample) ==========
vcf: $(FILTERED_VCF) $(VCF_INDEX) $(VCF_STATS)

# Step 1: Call raw variants with bcftools mpileup + call
$(RAW_VCF): $(BAM) $(BAM_INDEX) $(GENOME_FA) $(GENOME_FAI)
	@if [ -z "$(SAMPLE)" ]; then \
		echo "Error: Must specify SAMPLE variable"; \
		echo "Example: make vcf SAMPLE=SRS15348647"; \
		exit 1; \
	fi
	mkdir -p $(VCF_DIR)
	@echo "=== Calling variants for $(SAMPLE) ==="
	bcftools mpileup -Ou -f $(GENOME_FA) $(BAM) | \
	bcftools call -mv -Oz -o $(RAW_VCF)

# Step 2: Filter variants (quality >= 20, depth >= 10)
$(FILTERED_VCF): $(RAW_VCF)
	@echo "=== Filtering variants for $(SAMPLE) ==="
	bcftools filter -i 'QUAL>=20 && DP>=10' -Oz -o $(FILTERED_VCF) $(RAW_VCF)

# Step 3: Index the filtered VCF
$(VCF_INDEX): $(FILTERED_VCF)
	bcftools index -t $(FILTERED_VCF)

# Step 4: Generate VCF statistics
$(VCF_STATS): $(FILTERED_VCF)
	@echo "=== Generating variant statistics for $(SAMPLE) ==="
	bcftools stats $(FILTERED_VCF) > $(VCF_STATS)
	@echo ""
	@echo "=== Variant Summary for $(SAMPLE) ==="
	@grep "^SN" $(VCF_STATS) | cut -f2-
	@echo ""
	@echo "Full statistics saved to: $(VCF_STATS)"

# ========== Merge VCFs into multisample VCF ==========
merge-vcf: $(MULTISAMPLE_VCF) $(MULTISAMPLE_INDEX) $(MULTISAMPLE_STATS)

$(MULTISAMPLE_VCF): $(DESIGN_FILE)
	@echo "=== Merging individual VCFs into multisample VCF ==="
	@# Check that all individual VCFs exist
	@for sample in $(tail -n +2 $(DESIGN_FILE) | cut -d',' -f2); do \
		if [ ! -f $(VCF_DIR)/$sample.vcf.gz ]; then \
			echo "Error: VCF file $(VCF_DIR)/$sample.vcf.gz not found"; \
			echo "Run 'make -f Looper.mk vcf' first to generate all sample VCFs"; \
			exit 1; \
		fi; \
	done
	@# Create list of VCF files to merge
	@tail -n +2 $(DESIGN_FILE) | cut -d',' -f2 | \
		awk '{print "$(VCF_DIR)/" $$1 ".vcf.gz"}' > $(VCF_DIR)/vcf_list.txt
	@# Merge VCFs
	bcftools merge -l $(VCF_DIR)/vcf_list.txt -Oz -o $(MULTISAMPLE_VCF)
	@rm $(VCF_DIR)/vcf_list.txt
	@echo "=== Multisample VCF created: $(MULTISAMPLE_VCF) ==="

$(MULTISAMPLE_INDEX): $(MULTISAMPLE_VCF)
	bcftools index -t $(MULTISAMPLE_VCF)

$(MULTISAMPLE_STATS): $(MULTISAMPLE_VCF)
	@echo "=== Generating multisample variant statistics ==="
	bcftools stats $(MULTISAMPLE_VCF) > $(MULTISAMPLE_STATS)
	@echo ""
	@echo "=== Multisample Variant Summary ==="
	@grep "^SN" $(MULTISAMPLE_STATS) | cut -f2-
	@echo ""
	@echo "Full statistics saved to: $(MULTISAMPLE_STATS)"

# ========== Annotate variants with snpEff ==========
annotate: $(ANNOTATED_VCF)

$(ANNOTATED_VCF): $(MULTISAMPLE_VCF) $(GFF)
	@echo "=== Annotating variants with snpEff ==="
	mkdir -p snpEff_db/data/$(GENOME_NAME)
	cp $(GENOME_FA) snpEff_db/data/$(GENOME_NAME)/sequences.fa
	cp $(GFF) snpEff_db/data/$(GENOME_NAME)/genes.gff
	echo "data.dir = ./snpEff_db/data/" > snpEff_db/snpEff.config
	echo "$(GENOME_NAME).genome : $(GENOME_NAME)" >> snpEff_db/snpEff.config
	snpEff build -gff3 -c snpEff_db/snpEff.config -dataDir ./snpEff_db/data $(GENOME_NAME)
	snpEff ann -c snpEff_db/snpEff.config -dataDir ./snpEff_db/data \
		-stats $(ANNOTATION_SUMMARY) $(GENOME_NAME) $(MULTISAMPLE_VCF) > $(ANNOTATED_VCF)
	@echo "Done. Check $(ANNOTATED_VCF) and $(ANNOTATION_SUMMARY)"


# ========== Clean files ==========
clean:
	rm -rf $(GENOME_DIR) $(READS_DIR) $(ALIGN_DIR) $(FASTQC_DIR) $(META_DIR) $(VCF_DIR)

clean-align:
	rm -rf $(ALIGN_DIR)

clean-vcf:
	rm -rf $(VCF_DIR)

.PHONY: usage genome metadata fastq fastqc index align stats bigwig vcf merge-vcf clean clean-align clean-vcf
