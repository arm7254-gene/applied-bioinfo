#!/bin/bash
# Merge count files into a count matrix
# Reads samples from design.csv

echo "Creating count matrix from individual count files..."

# Read samples from design.csv (column 2 = Sample)
SAMPLES=$(tail -n +2 design.csv | cut -d',' -f2 | tr '\n' ' ')

if [ -z "$SAMPLES" ]; then
    echo "ERROR: No samples found in design.csv"
    exit 1
fi

echo "Samples: $SAMPLES"

# Check if count files exist
for sample in $SAMPLES; do
    if [ ! -f "counts/${sample}.counts.txt" ]; then
        echo "ERROR: counts/${sample}.counts.txt not found!"
        echo "Run: make -f Looper.mk count"
        exit 1
    fi
done

# Get first sample for gene IDs
FIRST_SAMPLE=$(echo $SAMPLES | awk '{print $1}')

# Create header
echo -n "Geneid" > counts/count_matrix.txt
for sample in $SAMPLES; do
    echo -n ",$sample" >> counts/count_matrix.txt
done
echo "" >> counts/count_matrix.txt

# Extract gene IDs from first sample (skip comment lines and header)
tail -n +3 counts/${FIRST_SAMPLE}.counts.txt | cut -f1 > counts/genes.tmp

# Extract counts from each sample (last column has counts)
for sample in $SAMPLES; do
    tail -n +3 counts/${sample}.counts.txt | cut -f7 > counts/${sample}.tmp
done

# Paste all columns together (genes + all sample counts)
TEMP_FILES="counts/genes.tmp"
for sample in $SAMPLES; do
    TEMP_FILES="$TEMP_FILES counts/${sample}.tmp"
done

paste -d',' $TEMP_FILES >> counts/count_matrix.txt

# Clean up temp files
rm counts/*.tmp

echo ""
echo "Count matrix created: counts/count_matrix.txt"
echo "Dimensions:"
echo "  Genes: $(tail -n +2 counts/count_matrix.txt | wc -l)"
echo "  Samples: $(echo $SAMPLES | wc -w)"
echo ""
echo "First few lines:"
head -10 counts/count_matrix.txt
