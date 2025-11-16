# ============================================================
# Variant Evaluation - Compare Normal vs Tumor
# ============================================================
# Usage:
#   make usage       # Show help
#   make compare     # Find unique/common variants
#   make evaluate    # Compare to gold standard
#   make report      # Generate report
# ============================================================

GENE = TP53
CHR = chr17
REGION = chr17:7661779-7687550

NORMAL_VCF = vcf/$(GENE)-normal.vcf.gz
TUMOR_VCF = vcf/$(GENE)-tumor.vcf.gz
GOLD_VCF = vcf/gold-standard.vcf.gz

MERGED_VCF = vcf/merged.vcf.gz
TUMOR_SPECIFIC = vcf/tumor-specific.vcf.gz
GOLD_REGION = vcf/gold-region.vcf.gz

REPORT = report.txt

usage:
	@echo "Variant Evaluation Pipeline"
	@echo "==========================="
	@echo ""
	@echo "Targets:"
	@echo "  compare   - Find unique tumor variants"
	@echo "  evaluate  - Compare to gold standard"
	@echo "  report    - Generate summary report"

# Compare normal and tumor to find tumor-specific variants
compare:
	@echo "Comparing normal and tumor samples..."
	mkdir -p vcf
	bcftools isec -p vcf/isec $(NORMAL_VCF) $(TUMOR_VCF)
	bcftools view -Oz -o $(TUMOR_SPECIFIC) vcf/isec/0001.vcf
	bcftools index $(TUMOR_SPECIFIC)
	@echo ""
	@echo "Files created:"
	@echo "  vcf/isec/0000.vcf - Normal-only variants"
	@echo "  vcf/isec/0001.vcf - Tumor-specific variants"
	@echo "  vcf/isec/0002.vcf - Common variants"
	@echo ""

# Extract gold standard for our region
evaluate: compare
	@echo "Extracting gold standard for region $(REGION)..."
	bcftools view -r $(REGION) $(GOLD_VCF) -Oz -o $(GOLD_REGION)
	bcftools index $(GOLD_REGION)
	@echo "Gold standard extracted to $(GOLD_REGION)"

# Generate summary report
report: evaluate
	@echo "Generating variant analysis report..."
	@echo "" > $(REPORT)
	@echo "========================================" >> $(REPORT)
	@echo "Cancer Genome Variant Analysis Report" >> $(REPORT)
	@echo "========================================" >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "Gene: $(GENE)" >> $(REPORT)
	@echo "Region: $(REGION)" >> $(REPORT)
	@echo "Date: $$(date)" >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "----------------------------------------" >> $(REPORT)
	@echo "1. VARIANT COUNTS" >> $(REPORT)
	@echo "----------------------------------------" >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "Normal sample:" >> $(REPORT)
	@echo -n "  Total variants: " >> $(REPORT)
	@bcftools view -H $(NORMAL_VCF) | wc -l >> $(REPORT)
	@echo -n "  SNPs: " >> $(REPORT)
	@bcftools view -v snps -H $(NORMAL_VCF) | wc -l >> $(REPORT)
	@echo -n "  INDELs: " >> $(REPORT)
	@bcftools view -v indels -H $(NORMAL_VCF) | wc -l >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "Tumor sample:" >> $(REPORT)
	@echo -n "  Total variants: " >> $(REPORT)
	@bcftools view -H $(TUMOR_VCF) | wc -l >> $(REPORT)
	@echo -n "  SNPs: " >> $(REPORT)
	@bcftools view -v snps -H $(TUMOR_VCF) | wc -l >> $(REPORT)
	@echo -n "  INDELs: " >> $(REPORT)
	@bcftools view -v indels -H $(TUMOR_VCF) | wc -l >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "----------------------------------------" >> $(REPORT)
	@echo "2. TUMOR-SPECIFIC VARIANTS" >> $(REPORT)
	@echo "----------------------------------------" >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo -n "Total tumor-specific variants: " >> $(REPORT)
	@bcftools view -H $(TUMOR_SPECIFIC) | wc -l >> $(REPORT)
	@echo -n "  SNPs: " >> $(REPORT)
	@bcftools view -v snps -H $(TUMOR_SPECIFIC) | wc -l >> $(REPORT)
	@echo -n "  INDELs: " >> $(REPORT)
	@bcftools view -v indels -H $(TUMOR_SPECIFIC) | wc -l >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "Top 10 tumor-specific variants:" >> $(REPORT)
	@bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' $(TUMOR_SPECIFIC) | head -10 >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "----------------------------------------" >> $(REPORT)
	@echo "3. GOLD STANDARD COMPARISON" >> $(REPORT)
	@echo "----------------------------------------" >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo -n "Gold standard variants in region: " >> $(REPORT)
	@bcftools view -H $(GOLD_REGION) | wc -l >> $(REPORT)
	@echo "" >> $(REPORT)
	@echo "========================================" >> $(REPORT)
	@echo "" >> $(REPORT)
	@cat $(REPORT)
	@echo ""
	@echo "Report saved to: $(REPORT)"

clean:
	rm -rf vcf/isec $(TUMOR_SPECIFIC) $(GOLD_REGION) $(REPORT)
