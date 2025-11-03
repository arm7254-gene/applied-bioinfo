# Week 10 Assignment: Variant Calling Pipeline

# Week 10 Command Log for Makefile

Datasets:
| Source                  | Sample Description    | Sample ID     | SRR Accession |
| :---------------------- | :-------------------- | :------------ | :------------ |
| BioProject PRJNA887926  | Control Replicate 1   |  SRS15348645  | SRR21835898   |
|                         | Control Replicate 2   |  SRS15348646  | SRR21835897   |
|                         | Control Replicate 3   |  SRS15348647  | SRR21835896   |
|                         | Treatment Replicate 1 |  SRS15348642  | SRR21835901   |
|                         | Treatment Replicate 2 |  SRS15348643  | SRR21835900   |
|                         | Treatment Replicate 3 |  SRS15348644  | SRR21835899   |

## File Structure

* Makefile - Single-sample processing (parameterized for one sample at a time)
* Looper.mk - Batch processing wrapper (loops over all samples in design.csv)
* design.csv - User-created file listing samples to process (format: Run,Sample)
* metadata/design.csv - Auto-generated from SRA metadata download

## Initial Setup

## Step 1: Download reference genome and create index (once)
```bash
# Downloads S. aureus USA300 genome and annotation
make genome

# Creates BWA index and chromosome sizes
make index
```

## Step 2: Get sample metadata (once)
```bash
# Downloads SRA metadata to metadata/design.csv
make metadata
```

## Step 3: Create your design file

Note: Create design.csv in the project root (same directory as the Makefile) with the samples you want to process.

### Option A: Copy from metadata (recommended)
After running make metadata, you can copy the entire metadata/design.csv to your project root:
```bash
cp metadata/design.csv design.csv
```
Or copy just specific samples you want:
```bash
# Copy header and first 3 samples
head -n 4 metadata/design.csv > design.csv
```
### Option B: Create manually
Create a new file called design.csv with this format:

```bash
cat > design.csv <<EOF
Run,Sample
SRR21835896,SRS15348647
SRR21835897,SRS15348648
SRR21835898,SRS15348649
EOF
```
## Single Sample Processing
Process one sample at a time by specifying variables:

```bash
# Download FASTQ for one sample
make fastq SAMPLE=SRS15348647 SRR=SRR21835896

# Run quality control
make fastqc SAMPLE=SRS15348647

# Align to reference genome
make align SAMPLE=SRS15348647

# Generate alignment statistics
make stats SAMPLE=SRS15348647

# Create coverage track
make bigwig SAMPLE=SRS15348647

# Call variants
make vcf SAMPLE=SRS15348647
```

## Batch Processing (All Samples)

### Option 1: Using Looper.mk (Recommended)
Use Looper.mk to process all samples in design.csv:

```bash
# Run complete pipeline on all samples (including variant calling)
make -f Looper.mk all

# Or run individual stages on all samples:
make -f Looper.mk fastq      # Download all FASTQ files
make -f Looper.mk fastqc     # QC all samples
make -f Looper.mk align      # Align all samples
make -f Looper.mk stats      # Stats for all samples
make -f Looper.mk bigwig     # Coverage for all samples
make -f Looper.mk vcf        # Call variants for all samples
```
By default, 4 samples are processed in parallel. Adjust in Looper.mk by changing JOBS = 4.

### Option 2: Direct parallel processing from command line
You can also process multiple samples directly using GNU parallel with your design.csv:

```bash
# Download FASTQ for all samples (4 jobs in parallel)
cat design.csv | parallel --colsep , --header : -j 4 \
    make fastq SRR={Run} SAMPLE={Sample}

# Align all samples
cat design.csv | parallel --colsep , --header : -j 4 \
    make align SAMPLE={Sample}

# Run FASTQC on all samples
cat design.csv | parallel --colsep , --header : -j 4 \
    make fastqc SAMPLE={Sample}

# Generate stats for all samples
cat design.csv | parallel --colsep , --header : -j 4 \
    make stats SAMPLE={Sample}

# Create bigWig tracks for all samples
cat design.csv | parallel --colsep , --header : -j 4 \
    make bigwig SAMPLE={Sample}

# Call variants for all samples
cat design.csv | parallel --colsep , --header : -j 4 \
    make vcf SAMPLE={Sample}
```
Note: Adjust -j 4 to control the number of parallel jobs based on your system resources.

# Output Structure
```bash
.
├── genome/                    # Reference genome and annotation
├── reads/                     # FASTQ files (named by Sample ID)
├── alignments/                # BAM files, stats, and bigWig tracks
├── fastqc_reports/            # Quality control reports
└── metadata/                  # Downloaded SRA metadata
```
## Step 4: Variant Calling

## Single Sample Processing
```bash
# Call variants for one sample (requires existing BAM file)
make vcf SAMPLE=SRS15348647
```
This will generate:
* variants/SAMPLE.raw.vcf.gz - Raw variant calls
* variants/SAMPLE.vcf.gz - Filtered variants (QUAL≥20, DP≥10)
* variants/SAMPLE.vcf.gz.tbi - VCF index file
* variants/SAMPLE.vcf.stats.txt - Variant statistics

## Step 5: Visualizing Variants
To visualize variants alongside alignments, you can use IGV (Integrative Genomics Viewer):
```bash
# Load these files into IGV:
# 1. Reference genome: genome/S_aureus_USA300.fna
# 2. Gene annotation: genome/S_aureus_USA300.gff
# 3. BAM alignment: alignments/SAMPLE.sorted.bam
# 4. Coverage track: alignments/SAMPLE.bw
# 5. Variants: variants/SAMPLE.vcf.gz
```
Or use command-line tools:
```bash
# View variants in a specific region
bcftools view variants/SRS15348647.vcf.gz NC_007793.1:100000-110000

# Count total variants
bcftools view -H variants/SRS15348647.vcf.gz | wc -l

# Extract only SNPs
bcftools view -v snps variants/SRS15348647.vcf.gz -Oz -o variants/SRS15348647.snps.vcf.gz

# Extract only indels
bcftools view -v indels variants/SRS15348647.vcf.gz -Oz -o variants/SRS15348647.indels.vcf.gz
```

## Cleanup
```bash
make clean              # Remove all generated files
make clean-align        # Remove only alignment files
make clean-vcf          # Remove only variant files
```

## Example Workflow
```bash
# 1. Initial setup (once)
make genome
make index
make metadata

# 2. Create your design.csv with samples to process

# 3. Test with one sample
make fastq SAMPLE=SRS15348647 SRR=SRR21835896
make align SAMPLE=SRS15348647
make stats SAMPLE=SRS15348647
make vcf SAMPLE=SRS15348647

# 4. View variant results
cat variants/SRS15348647.vcf.stats.txt

# 5. If everything works, process all samples
make -f Looper.mk all
```




