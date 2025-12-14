# ============================================================
# Batch Processing - Reads samples from design.csv
# ============================================================
# Usage:
#   make -f Batch.mk all-align
#   make -f Batch.mk all-counts
#   make -f Batch.mk matrix
# ============================================================

# Read sample names from design.csv (skip header)
SAMPLES := $(shell tail -n +2 design.csv | cut -d',' -f1)

# Align all samples from design.csv
all-align:
	@echo "Samples to process: $(SAMPLES)"
	@for sample in $(SAMPLES); do \
		echo ""; \
		echo "=== Aligning $$sample ==="; \
		make align SAMPLE=$$sample || exit 1; \
		make bw SAMPLE=$$sample || exit 1; \
	done
	@echo ""
	@echo "All alignments complete!"

# Count all samples from design.csv
all-counts:
	@echo "Samples to process: $(SAMPLES)"
	@for sample in $(SAMPLES); do \
		echo ""; \
		echo "=== Counting $$sample ==="; \
		make count SAMPLE=$$sample || exit 1; \
	done
	@echo ""
	@echo "All counts complete!"

# Create count matrix
matrix: all-counts
	@echo "Creating count matrix..."
	@bash merge_counts.sh

# Stats for all samples
all-stats:
	@for sample in $(SAMPLES); do \
		echo ""; \
		echo "=== Stats for $$sample ==="; \
		make stats SAMPLE=$$sample; \
	done

help:
	@echo "Batch Processing Makefile"
	@echo "========================="
	@echo ""
	@echo "Reads samples from design.csv"
	@echo "Current samples: $(SAMPLES)"
	@echo ""
	@echo "Targets:"
	@echo "  show-samples - Display samples from design.csv"
	@echo "  all-align    - Align all samples in design.csv"
	@echo "  all-counts   - Count all samples"
	@echo "  matrix       - Create count matrix"
	@echo "  all-stats    - Show stats for all samples"

# Show samples from design file
show-samples:
	@echo "Samples in design.csv:"
	@tail -n +2 design.csv | cut -d',' -f1,2,3
	@echo ""
	@echo "Will process: $(SAMPLES)"
