# ============================================================
# Looper.mk - Batch processing for all samples
# Author: A. Mercedes
# ============================================================
# This makefile loops over all samples in design.csv
# and calls the single-sample Makefile for each
#
# Usage:
#   make -f Looper.mk all              # Run complete pipeline
#   make -f Looper.mk fastq            # Download all FASTQ files
#   make -f Looper.mk fastqc           # Run FASTQC on all samples
#   make -f Looper.mk align            # Align all samples
#   make -f Looper.mk stats            # Generate stats for all
#   make -f Looper.mk bigwig           # Generate bigWigs for all
#   make -f Looper.mk vcf              # Call variants for all
#   make -f Looper.mk merge-vcf        # Merge all VCFs into multisample VCF
#   make -f Looper.mk annotate         # Annotate multisample VCF
# ============================================================

DESIGN_FILE = design.csv
JOBS = 4

# ========== Batch targets ==========

all: fastq fastqc align stats bigwig vcf
	make merge-vcf
	@echo "=== Pipeline complete for all samples ==="

fastq:
	cat $(DESIGN_FILE) | parallel --colsep , --header : --lb -j $(JOBS) \
		make fastq SAMPLE={Sample} SRR={Run}

fastqc:
	cat $(DESIGN_FILE) | parallel --colsep , --header : --lb -j $(JOBS) \
		make fastqc SAMPLE={Sample}

align:
	cat $(DESIGN_FILE) | parallel --colsep , --header : --lb -j $(JOBS) \
		make align SAMPLE={Sample}

stats:
	cat $(DESIGN_FILE) | parallel --colsep , --header : --lb -j $(JOBS) \
		make stats SAMPLE={Sample}

bigwig:
	cat $(DESIGN_FILE) | parallel --colsep , --header : --lb -j $(JOBS) \
		make bigwig SAMPLE={Sample}

vcf:
	cat $(DESIGN_FILE) | parallel --colsep , --header : --lb -j $(JOBS) \
		make vcf SAMPLE={Sample}

merge-vcf:
	make merge-vcf

annotate:
	make annotate

.PHONY: all fastq fastqc align stats bigwig vcf merge-vcf