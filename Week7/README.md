# Week  Assignment: Write a reusable alignment Makefile

# Week 7 Command Log for Makefile

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

## IGV Screenshots

⚠️ IGV Troubleshooting Notice

Notice: I am currently troubleshooting loading the S. aureus USA300 reference genome and aligned BAM files in IGV. Some genome or BAM files may not display correctly until this issue is resolved. Please refer back later for updated instructions and fully visualizable data.

# Week 7 Assignment Questions

1. Briefly describe the differences between the alignment in both files.
2. Briefly compare the statistics for the two BAM files.

| Metric                       |  **SRR34850871**  |  **SRR21835896**  | **Interpretation**                                                            |
| :--------------------------- | :---------------: | :---------------: | :---------------------------------------------------------------------------- |
| **Total reads**              |      281,631      |      280,163      | Nearly identical total input reads.                                           |
| **Primary alignments**       |      280,000      |      280,000      | Both are paired-end, 140k read pairs each.                                    |
| **Supplementary alignments** |       1,631       |        163        | SRR34850871 has ~10× more supplementary alignments (chimeric or split reads). |
| **Duplicates**               |         0         |         0         | No PCR duplication detected — good.                                           |
| **Mapped reads**             | 274,696 (97.54 %) | 277,401 (99.01 %) | Slightly higher mapping rate for SRR21835896.                                 |
| **Properly paired**          | 270,290 (96.53 %) | 276,312 (98.68 %) | SRR21835896 has better pairing consistency.                                   |
| **Singletons**               |    603 (0.22 %)   |    122 (0.04 %)   | Fewer unpaired reads in SRR21835896.                                          |
| **Cross-chromosomal mates**  |         0         |         0         | No evidence of mis-mapped pairs.                                              |

3. How many primary alignments does each of your BAM files contain?
   - Both BAM files contain 280,000 primary alignments, corresponding to 140,000 read pairs each (since these are paired-end RNA-seq reads).
4. What coordinate has the largest observed coverage (hint samtools depth)

- **SRR21835896**
```bash
samtools depth alignments/SRR21835896.sorted.bam | sort -k3,3nr | head -1
```
- **SRR34850871**
```bash
samtools depth alignments/SRR34850871.sorted.bam | sort -k3,3nr | head -1
```

- **Results**
  
| Sample          |  Chromosome |  Position | Max Coverage |
| :-------------- | :---------: | :-------: | :----------: |
| **SRR21835896** | NC_007795.1 | 2,447,431 |  **27,688×** |
| **SRR34850871** | NC_007795.1 |  788,475  |  **20,752×** |

6. Select a gene of interest. How many alignments on a forward strand cover the gene?
