# ============================================================
# Cancer Genome Variant Calling - Single Sample Pipeline
# ============================================================
# Usage:
#   make usage           # Show this help
#   make genome          # Download reference genome
#   make bam             # Extract BAM for region
#   make vcf             # Call variants
#   make stats           # Get variant statistics
# ============================================================

# Choosen gene - TP53 (tumor suppressor, chr17)
CHR = chr17
REGION = chr17:7661779-7687550
GENE = TP53

# Sample type (normal or tumor)
SAMPLE_TYPE = normal

# URLs
REF_URL = https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/GRCh38/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta.gz
NORMAL_BAM_URL = https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Element-AVITI-20241216/HG008-N-D_Element-StdInsert_77x_GRCh38-GIABv3.bam
TUMOR_BAM_URL = https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/Element-AVITI-20241216/HG008-T_Element-StdInsert_111x_GRCh38-GIABv3.bam
GOLD_URL = https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/data_somatic/HG008/Liss_lab/analysis/Ultima_DeepVariant-somatic-SNV-INDEL_20240822/HG008_edv_AF_recalibration.result.PASS.vcf.gz

# File paths
REF = refs/$(CHR).fasta
BAM = bam/$(GENE)-$(SAMPLE_TYPE).bam
VCF = vcf/$(GENE)-$(SAMPLE_TYPE).vcf.gz
GOLD_VCF = vcf/gold-standard.vcf.gz

# ============================================================
# Targets
# ============================================================

usage:
	@echo "Cancer Genome Variant Calling Pipeline"
	@echo "======================================="
	@echo ""
	@echo "Region: $(GENE) gene at $(REGION)"
	@echo "Sample type: $(SAMPLE_TYPE)"
	@echo ""
	@echo "Targets:"
	@echo "  usage    - Show this message"
	@echo "  genome   - Download reference for $(CHR)"
	@echo "  bam      - Extract BAM for $(REGION)"
	@echo "  vcf      - Call variants"
	@echo "  stats    - Get statistics"
	@echo "  gold     - Download gold standard"
	@echo ""
	@echo "Override SAMPLE_TYPE on command line:"
	@echo "  make bam SAMPLE_TYPE=tumor"
	@echo "  make vcf SAMPLE_TYPE=tumor"

# Download and extract reference genome
genome:
	@echo "Step 1: Downloading full reference genome (if needed)..."
	mkdir -p refs
	@if [ ! -f refs/GRCh38.fasta.gz ]; then \
		wget -q --show-progress $(REF_URL) -O refs/GRCh38.fasta.gz; \
	else \
		echo "Already downloaded."; \
	fi
	@echo ""
	@echo "Step 2: Decompressing reference..."
	gunzip -c refs/GRCh38.fasta.gz > refs/GRCh38.fasta
	@echo ""
	@echo "Step 3: Indexing full reference..."
	samtools faidx refs/GRCh38.fasta
	@echo ""
	@echo "Step 4: Extracting $(CHR)..."
	samtools faidx refs/GRCh38.fasta $(CHR) > $(REF)
	@echo ""
	@echo "Step 5: Indexing $(CHR)..."
	samtools faidx $(REF)
	@echo ""
	@echo "Step 6: Cleaning up large files..."
	rm -f refs/GRCh38.fasta refs/GRCh38.fasta.fai
	@echo ""
	@echo "Done! Reference ready at $(REF)"

$(REF).fai: $(REF)
	samtools faidx $(REF)

# Extract BAM for region of interest
bam: $(BAM).bai

$(BAM): $(REF).fai
	@echo "Extracting $(SAMPLE_TYPE) BAM for region $(REGION)..."
	mkdir -p bam
ifeq ($(SAMPLE_TYPE),normal)
	samtools view -b $(NORMAL_BAM_URL) $(REGION) > $(BAM)
else
	samtools view -b $(TUMOR_BAM_URL) $(REGION) > $(BAM)
endif

$(BAM).bai: $(BAM)
	samtools index $(BAM)
	samtools flagstat $(BAM) > $(BAM).stats.txt
	@echo "BAM stats saved to $(BAM).stats.txt"

# Call variants
vcf: $(VCF)

$(VCF): $(REF).fai $(BAM).bai
	@echo "Calling variants for $(SAMPLE_TYPE) sample..."
	mkdir -p vcf
	bcftools mpileup -Ou -f $(REF) $(BAM) | bcftools call -mv -Oz -o $(VCF)
	bcftools index $(VCF)

# Get variant statistics
stats: $(VCF)
	@echo ""
	@echo "=== Variant Statistics for $(SAMPLE_TYPE) sample ==="
	@echo ""
	bcftools stats $(VCF) | grep ^SN
	@echo ""
	@echo "Total variants:"
	bcftools view -H $(VCF) | wc -l
	@echo ""
	@echo "SNPs:"
	bcftools view -v snps -H $(VCF) | wc -l
	@echo ""
	@echo "INDELs:"
	bcftools view -v indels -H $(VCF) | wc -l

# Download gold standard
gold: $(GOLD_VCF)

$(GOLD_VCF):
	@echo "Downloading gold standard..."
	mkdir -p vcf
	curl -L $(GOLD_URL) -o $(GOLD_VCF)
	curl -L $(GOLD_URL).tbi -o $(GOLD_VCF).tbi

clean:
	rm -rf refs bam vcf
	@echo "Cleaned all files"