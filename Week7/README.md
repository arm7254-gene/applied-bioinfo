# Week  Assignment: Write a reusable alignment Makefile

# Week 7 Command Log for MakeFile

Datasets:
| Source                  | Platform              | SRR Accession |
| :---------------------- | :-------------------- | :------------ |
| BioProject PRJNA887926  | Illumina HiSeq 2500   | SRR21835896   |
| BioProject PRJNA1300840 | Illumina NovaSeq 6000 | SRR34850871   |

## Step 1: Download and Index Reference Genome (once)
```bash
# Download S. aureus USA300 reference genome
make genome

# Index the genome with BWA
make index
```
## Step 2: Process Dataset 1 (SRR21835896)
```bash
# Download reads
make fastq SRR=SRR21835896

# Align reads to reference
make align SRR=SRR21835896

# Generate alignment statistics
make stats SRR=SRR21835896

# Create bigWig coverage track
make bigwig SRR=SRR21835896
```
## Step 3: Process Dataset 2 (SRR34850871)
```bash
# Download reads
make fastq SRR=SRR34850871

# Align reads to reference
make align SRR=SRR34850871

# Generate alignment statistics
make stats SRR=SRR34850871

# Create bigWig coverage track
make bigwig SRR=SRR34850871
```
## Output Files
The Makefile generates the following organized directory structure:
```bash
.
├── genome/
│   ├── S_aureus_USA300.fna          # Reference genome
│   ├── S_aureus_USA300.fna.fai      # Genome index
│   ├── S_aureus_USA300.gff          # Gene annotations
│   └── S_aureus_USA300.fna.bwt      # BWA index files
├── reads/
│   ├── SRR21835896_1.fastq.gz       # Dataset 1 reads
│   ├── SRR21835896_2.fastq.gz
│   ├── SRR34850871_1.fastq.gz       # Dataset 2 reads
│   └── SRR34850871_2.fastq.gz
└── alignments/
    ├── SRR21835896.sorted.bam       # Dataset 1 BAM file
    ├── SRR21835896.sorted.bam.bai   # BAM index
    ├── SRR21835896.stats.txt        # Alignment statistics
    ├── SRR21835896.bw               # BigWig coverage track
    ├── SRR34850871.sorted.bam       # Dataset 2 BAM file
    ├── SRR34850871.sorted.bam.bai   # BAM index
    ├── SRR34850871.stats.txt        # Alignment statistics
    └── SRR34850871.bw               # BigWig coverage track
```

# Week 7 Assignment Questions

## IGV Screenshots

1. Briefly describe the differences between the alignment in both files.
2. Briefly compare the statistics for the two BAM files.
3. How many primary alignments does each of your BAM files contain?
4. What coordinate has the largest observed coverage (hint samtools depth)
5. Select a gene of interest. How many alignments on a forward strand cover the gene?
