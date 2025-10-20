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

## Step 8: Clean Up
Remove all generated files:
```bash
make clean
```
Or remove only alignment files but keep genome and reads:
```bash
make clean-align
```
## Example of a Dry-Run Test
To verify that GNU parallel is reading the design file correctly:
```bash
cat design.csv | \
parallel --colsep , --header : --lb -j 4 \
         echo "Would process sample {Sample} from SRR {Run}"
```
Example output:
```bash
Would process sample SRS15348643 from SRR SRR21835900
Would process sample SRS15348644 from SRR SRR21835899
Would process sample SRS15348645 from SRR SRR21835898
Would process sample SRS15348646 from SRR SRR21835897
Would process sample SRS15348647 from SRR SRR21835896
Would process sample SRS15348642 from SRR SRR21835901
```
* Confirms that each row in design.csv will be processed in parallel.
  


