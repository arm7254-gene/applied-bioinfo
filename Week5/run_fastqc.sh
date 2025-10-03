#!/bin/bash
echo "Running FASTQC quality control analysis..."

# Set sample name (same as in download script)
SAMPLE="SRR21835896"

echo "Analyzing sample: $SAMPLE"

# Create output directory for FASTQC reports
mkdir -p fastqc_reports

# Check if the fastq files exist
if [ ! -f "rnaseq_data/${SAMPLE}_1.fastq.gz" ]; then
    echo "ERROR: FASTQ files not found!"
    echo "Make sure you've run the download script first"
    exit 1
fi

# Run FASTQC on both paired-end files
echo "Running FASTQC on paired-end reads..."
fastqc rnaseq_data/${SAMPLE}_1.fastq.gz rnaseq_data/${SAMPLE}_2.fastq.gz --outdir fastqc_reports

# Check if FASTQC completed successfully
if [ -f "fastqc_reports/${SAMPLE}_1_fastqc.html" ]; then
    echo ""
    echo "FASTQC analysis completed successfully!"
    echo ""
    echo "Quality reports generated:"
    echo "- Read 1 report: fastqc_reports/${SAMPLE}_1_fastqc.html" 
    echo "- Read 2 report: fastqc_reports/${SAMPLE}_2_fastqc.html"
    echo ""
    echo "Files also created:"
    ls fastqc_reports/
    echo ""
    echo "To view quality reports:"
    echo "1. Open the .html files in a web browser"
    echo "2. Or use: open fastqc_reports/${SAMPLE}_1_fastqc.html (on Mac)"
else
    echo "ERROR: FASTQC analysis failed"
    echo "Check that fastqc is installed and fastq files exist"
    exit 1
fi

echo "FASTQC analysis complete!"
