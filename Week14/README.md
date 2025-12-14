# Week 14 Assignment: Perform an RNA-Seq differential gene expression study  

#### **Methicillin-Resistant Staphylococcus aureus: Control vs Treatment** <br> BioProject: PRJNA887926 <br> Organism: Staphylococcus aureus subsp. aureus USA300

## Overview
**MRSA RNA-seq Differential Expression Study**:
This pipeline processes RNA-seq data from MRSA to generate a count matrix showing gene expression levels. The workflow aligns reads to the S. aureus genome, quantifies gene expression using featureCounts, and produces IGV-compatible visualization files.

## Samples:

In Im et al.(2022), they investigated the regulatory mechanism responsible for the inhibitory effect of NaP on MRSA using RNA-Seq analysis

| Source                  | Sample Description    | Sample ID     | SRR Accession |
| :---------------------- | :-------------------- | :------------ | :------------ |
| BioProject PRJNA887926  | Control Replicate 1   |  SRS15348645  | SRR21835898   |
|                         | Control Replicate 2   |  SRS15348646  | SRR21835897   |
|                         | Control Replicate 3   |  SRS15348647  | SRR21835896   |
|                         | Treatment Replicate 1 |  SRS15348642  | SRR21835901   |
|                         | Treatment Replicate 2 |  SRS15348643  | SRR21835900   |
|                         | Treatment Replicate 3 |  SRS15348644  | SRR21835899   |

## Setup 

### Environment Requirements

This pipeline uses two conda environments:
* bioinfo - For data download, alignment, and counting
  ```bash
  micromamba activate bioinfo
  ```
* stats - For statistical analysis of the count matrix
  ```bash
  micromamba activate stats
  ```

## Computational Pipeline
### Read Alignment (bioinfo environment)
```bash
make design          # Create experimental design file
make genome          # Download reference genome and GFF annotation
make index           # Index genome with BWA
make -f Looper.mk fastq    # Download FASTQ files from SRA
make -f Looper.mk align    # Align reads with BWA
make -f Looper.mk bigwig   # Generate coverage tracks
```

### Quantification (bioinfo environment)
```bash
make -f Looper.mk count    # Count reads per gene with featureCounts
make matrix                 # Merge counts into matrix
```

### Differential Expression (stats environment)
```bash
make deseq2                 # DESeq2 analysis with PCA and heatmaps
make enrichment             # Functional enrichment analysis
```

#### Statistical Analysis
* Normalization: DESeq2 median-of-ratios
* Differential Expression: DESeq2 (v1.x)
* Significance Thresholds: padj < 0.05, |log2 fold-change| > 1
* Visualization: PCA, heatmaps, volcano plots, MA plots

### Results

#### Principal Component Analysis
<img width="800" height="600" alt="pca_plot" src="https://github.com/user-attachments/assets/b0ff8dc1-134c-4842-80fc-e7c83a074869" />

#### Visualization Files:

##### **Heatmap: Top 50 differentially expressed genes**
<img width="900" height="1200" alt="heatmap_significant" src="https://github.com/user-attachments/assets/8527774c-5076-4413-b9c9-8eacc0a02780" />

##### **Volcano plot: Significance vs fold-change**
<img width="900" height="700" alt="volcano_plot" src="https://github.com/user-attachments/assets/72204ea7-b46e-4d82-841d-eee142899109" />

##### **MA plot: Mean expression vs log fold-change**
<img width="800" height="600" alt="ma_plot" src="https://github.com/user-attachments/assets/0856bb19-76ea-4c84-8bcf-7e5095432384" />

#### Functional Enrichment

##### All significant genes:
  ```bash
  wc -l results/*gene_ids.txt
  ```
  * 182 results/downregulated_gene_ids.txt
  * 321 results/significant_gene_ids.txt
  * 139 results/upregulated_gene_ids.txt
  * 642 total

<img width="1000" height="600" alt="functional_categories" src="https://github.com/user-attachments/assets/b0f97d4e-c263-4709-ac89-0b5fe34f1deb" />

## Discussion

The differential expression analysis reveals transcriptional reprogramming in response to treatment. The clear separation in PCA and the number of differentially expressed genes indicate a robust biological response. Genes showing the strongest downregulation (e.g., SAOUHSC_01121, SAOUHSC_00233) may represent treatment-sensitive pathways, while upregulated genes (e.g., SAOUHSC_00799) could indicate compensatory mechanisms or stress responses.

## Files and Data

### Input Data
* design.csv - Experimental design (6 samples, conditions labeled)
* genome/S_aureus_USA300.fna - Reference genome
* genome/S_aureus_USA300.gff - Gene annotations
* reads/ - FASTQ files (6 samples, paired-end)

### Intermediate Files
* alignments/ - BAM files and BigWig coverage tracks
* counts/ - Per-sample gene counts and count matrix

### Results
* results/deseq2_all_genes.csv - All genes with statistics
* results/deseq2_significant_genes.csv - Significant genes only
* results/pca_plot.png - Principal component analysis
* results/heatmap_significant.png - Expression heatmap
* results/volcano_plot.png - Volcano plot
* results/ma_plot.png - MA plot
* results/enrichment_summary.csv - Enrichment analysis summary
* results/functional_enrichment.csv
* results/functional_categories.png - Functional Categories in Differentially Expressed Genes

### Scripts
* Makefile - Automated pipeline (bioinfo steps)
* Looper.mk - Batch processing
* deseq2_analysis.R - Differential expression analysis
* functional_enrichment.R - Functional enrichment
* merge_counts.sh - Count matrix creation
