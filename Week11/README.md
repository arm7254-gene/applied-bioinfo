# Week 11 Assignment: Establish the effects of variants

# Week 11 Command Log for Makefile

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
├── variants/                  # VCF files and variant statistics
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

## Creating a Multisample VCF
After calling variants for all samples, merge them into a single multisample VCF:
```bash
# First, call variants for all samples
make -f Looper.mk vcf

# Then merge into multisample VCF
make merge-vcf
```
This creates:
* variants/all_samples.vcf.gz - Multisample VCF with all samples
* variants/all_samples.vcf.gz.tbi - Index file
* variants/all_samples.vcf.stats.txt - Combined statistics

## Step 5: Annotating Variants
Annotate variants to predict their biological effects using snpEff:
```bash
# Annotate the multisample VCF
make annotate
```
This will:
1. Build a snpEff database from your reference genome and GFF
2. Annotate all variants in the multisample VCF
3. Generate an HTML summary report with charts
4. Show examples of variants by impact level

Output files:
* variants/all_samples.annotated.vcf - Annotated VCF with effect predictions
* variants/snpEff_summary.html - Interactive HTML report (open in browser)
* snpEff_db/ - Database directory (can be deleted after annotation)

Variant Effects:
1. HIGH impact: Stop gained/lost, frameshift, splice site disruption
2. MODERATE impact: Missense variants, in-frame indels
3. LOW impact: Synonymous variants, intron variants
4. MODIFIER: Intergenic, upstream/downstream variants

## Step 6: Exploring Variant Effects
After annotation, you can extract specific variant types:
```bash
# Find all HIGH impact variants (potentially damaging)
grep "HIGH" variants/all_samples.annotated.vcf

# Find missense variants (amino acid changes)
grep "missense_variant" variants/all_samples.annotated.vcf

# Find synonymous variants (silent mutations)
grep "synonymous_variant" variants/all_samples.annotated.vcf

# Find stop-gained variants (nonsense mutations)
grep "stop_gained" variants/all_samples.annotated.vcf

# Find frameshift variants
grep "frameshift" variants/all_samples.annotated.vcf

# Count variants by impact
grep -o "HIGH\|MODERATE\|LOW\|MODIFIER" variants/all_samples.annotated.vcf | sort | uniq -c
```
## Step 7: Visualizing Variants
To visualize variants alongside alignments, you can use IGV (Integrative Genomics Viewer):

### For single sample:
```bash
# Load these files into IGV:
# 1. Reference genome: genome/S_aureus_USA300.fna
# 2. Gene annotation: genome/S_aureus_USA300.gff
# 3. BAM alignment: alignments/SAMPLE.sorted.bam
# 4. Coverage track: alignments/SAMPLE.bw
# 5. Variants: variants/SAMPLE.vcf.gz
```
### For multisample VCF:
```bash
# Load these files into IGV:
# 1. Reference genome: genome/S_aureus_USA300.fna
# 2. Gene annotation: genome/S_aureus_USA300.gff
# 3. Multisample VCF: variants/all_samples.vcf.gz
# 4. BAM files for all samples (optional, to see coverage)
```

### Or use command-line tools:
```bash
# View variants in a specific region
bcftools view variants/all_samples.vcf.gz NC_007793.1:100000-110000

# Count total variants
bcftools view -H variants/all_samples.vcf.gz | wc -l

# View variants in a specific gene (requires bedtools)
# First, extract gene coordinates from GFF
grep "gene" genome/S_aureus_USA300.gff | head -1
# Then query that region in the VCF

# Extract only SNPs
bcftools view -v snps variants/all_samples.vcf.gz -Oz -o variants/all_samples.snps.vcf.gz

# Extract only indels
bcftools view -v indels variants/all_samples.vcf.gz -Oz -o variants/all_samples.indels.vcf.gz

# Find variants present in all samples
bcftools view -i 'AC==AN' variants/all_samples.vcf.gz

# Find sample-specific variants
bcftools view -i 'AC==2' variants/all_samples.vcf.gz  # Variants in one sample only
```
### Automated IGV visualization:
First, start IGV and enable the port:
1. Open IGV
2. Go to View > Preferences > Advanced
3. Check "Enable port" (default 60151)
4. Click OK
Then use the Makefile to automatically load your data:
```bash
# View all samples with genome, GFF, BAMs, and multisample VCF
make igv

# View a specific sample with BAM, bigWig, and individual VCF
make igv-sample SAMPLE=SRS15348647
```
The IGV targets will automatically:
* Load the reference genome
* Load gene annotations (GFF)
* Load alignment files (BAM)
* Load coverage tracks (bigWig)
* Load variant files (VCF)
* Navigate to the start of the genome
  
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

# 5. Process all samples
make -f Looper.mk all

# 6. Check sample quality (alignment stats and variant counts)
for sample in $(tail -n +2 design.csv | cut -d',' -f2); do
    echo "=== $sample ==="
    grep "mapped (" alignments/${sample}.stats.txt
    echo "Variants:" $(bcftools view -H variants/${sample}.vcf.gz | wc -l)
    echo ""
done

# 7. Create multisample VCF
make merge-vcf

# 8. Annotate variants to predict effects
make annotate

# 9. Open the HTML summary report
open variants/snpEff_summary.html

# 10. Find examples of different variant types
echo "=== HIGH impact variants ==="
grep "HIGH" variants/all_samples.annotated.vcf | head -3

echo "=== Missense variants ==="
grep "missense_variant" variants/all_samples.annotated.vcf | head -3

echo "=== Synonymous variants ==="
grep "synonymous_variant" variants/all_samples.annotated.vcf | head -3

# 11. Visualize in IGV with genome, GFF, BAMs, and annotated VCF
```
## Results:

```bash
=== SRS15348643 ===
277845 + 0 mapped (99.11% : N/A)
277510 + 0 primary mapped (99.11% : N/A)
Variants: 85

=== SRS15348644 ===
277379 + 0 mapped (99.03% : N/A)
277277 + 0 primary mapped (99.03% : N/A)
Variants: 106

=== SRS15348645 ===
277816 + 0 mapped (99.12% : N/A)
277539 + 0 primary mapped (99.12% : N/A)
Variants: 86

=== SRS15348646 ===
277861 + 0 mapped (99.13% : N/A)
277571 + 0 primary mapped (99.13% : N/A)
Variants: 80

=== SRS15348647 ===
277401 + 0 mapped (99.01% : N/A)
277238 + 0 primary mapped (99.01% : N/A)
Variants: 100

=== SRS15348642 ===
277054 + 0 mapped (98.92% : N/A)
276969 + 0 primary mapped (98.92% : N/A)
Variants: 102
```


