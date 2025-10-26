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
# ============================================================

DESIGN_FILE = design.csv
JOBS = 4

# ========== Batch targets ==========

all: fastq fastqc align stats bigwig
	@echo "=== Pipeline complete for all samples ==="

# Download FASTQ files for all samples
fastq:
	@echo "=== Downloading FASTQ files for all samples ==="
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j $(JOBS) \
		make fastq SAMPLE={Sample} SRR={Run}

# Run FASTQC on all samples
fastqc:
	@echo "=== Running FASTQC on all samples ==="
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j $(JOBS) \
		make fastqc SAMPLE={Sample}

# Align all samples
align:
	@echo "=== Aligning all samples ==="
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j $(JOBS) \
		make align SAMPLE={Sample}

# Generate stats for all samples
stats:
	@echo "=== Generating alignment statistics for all samples ==="
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j $(JOBS) \
		make stats SAMPLE={Sample}

# Generate bigWig files for all samples
bigwig:
	@echo "=== Generating bigWig files for all samples ==="
	cat $(DESIGN_FILE) | \
	parallel --colsep , --header : --lb -j $(JOBS) \
		make bigwig SAMPLE={Sample}

.PHONY: all fastq fastqc align stats bigwig
