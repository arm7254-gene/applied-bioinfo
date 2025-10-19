# Week 8 Assignment: Automate a large scale analysis

# Week 8 Command Log for Makefile

Datasets:
| Source                  | Sample Description    | Sample ID     | SRR Accession |
| :---------------------- | :-------------------- | :------------ | :------------ |
| BioProject PRJNA887926  | Control Replicate 1   |  SRS15348645  | SRR21835898   |
|                         | Control Replicate 2   |  SRS15348646  | SRR21835897   |
|                         | Control Replicate 3   |  SRS15348647  | SRR21835896   |
|                         | Treatment Replicate 1 |  SRS15348642  | SRR21835901   |
|                         | Treatment Replicate 2 |  SRS15348643  | SRR21835900   |
|                         | Treatment Replicate 3 |  SRS15348644  | SRR21835899   |

## Step 1: Download and Prepare Genome
```bash
# Download genome and annotation
make genome

# Index the genome for BWA and samtools
make index
```

## Step 2: Download Metadata / Design File
```bash
make metadata
```

## Step 3: Download FASTQ Reads (renamed by Sample)
```bash
make fastq
```

## Step 4: Run FASTQC for Quality Control
```bash
make fastqc
```

## Step 5: Align Reads to Reference Genome
```bash
make align
```

## Step 6: Generate Alignment Statistics
```bash
make stats
```

## Step 7: Generate Coverage Tracks (bigWig)
```bash
make bigwig
```

