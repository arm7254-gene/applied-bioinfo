# Week 4 Assignment - Group 3 Methicillin-resistant Staphylococcus aureus

# Week 4 Command Log

Step 1: Download the Reference Genome and Annotations
```bash
# Create main project directory
mkdir project

#change directories
cd project/

# Create specific project directory
mkdir -p mrsa_analysis
cd mrsa_analysis

#activate environment
micromamba activate bioinfo

# Get the genome FASTA file
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna.gz"
wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.gff.gz"

# Unzip the files
gunzip *.gz

# Rename for easier use
mv GCF_000013425.1_ASM1342v1_genomic.fna S_aureus_USA300_genome.fna
mv GCF_000013425.1_ASM1342v1_genomic.gff S_aureus_USA300_annotation.gff

# Quick check of what we downloaded
echo "Genome file:"
ls -lh S_aureus_USA300_genome.fna
echo "First few lines of genome:"
head -3 S_aureus_USA300_genome.fna

echo -e "\nAnnotation file:"
ls -lh S_aureus_USA300_annotation.gff
echo "First few annotation lines:"
head -5 S_aureus_USA300_annotation.gff
```
Step 2: Basic Analysis Commands
```bash
# Calculate total genome size
grep -v "^#" S_aureus_USA300_annotation.gff | grep region | awk '{sum += $5} END {print "Total genome size:", sum " bp"}'

# See what types of features are present and their counts
grep -v "^#" S_aureus_USA300_annotation.gff | cut -f3 | sort | uniq -c | sort -nr

# Find longest genes and extract their attributes (including names)
grep -v "^#" S_aureus_USA300_annotation.gff | awk '$3=="gene"' | \
awk '{
    gene_length=$5-$4+1; 
    print gene_length, $1, $4, $5, $9
}' | sort -nr | head -10

# Look for genes with recognizable names (not just locus tags)
grep -v "^#" S_aureus_USA300_annotation.gff | grep "gene" | \
grep -E "Name=[a-zA-Z]{3,}" | head -10

# Get the size and location of recF
grep "SAOUHSC_00004" S_aureus_USA300_annotation.gff | awk '$3=="gene"' | \
awk '{print "Length:", $5-$4+1, "bp"; print "Location:", $1":"$4"-"$5}'

# Calculate genome size
genome_size=$(grep -v "^>" S_aureus_USA300_genome.fna | wc -c)
echo "Total genome size: $genome_size bp"

# Calculate total coding sequence length
total_cds=$(grep -v "^#" S_aureus_USA300_annotation.gff | awk '$3=="CDS"' | \
awk '{sum += $5-$4+1} END{print sum}')
echo "Total CDS length: $total_cds bp"

# Calculate coding percentage
echo "scale=2; $total_cds * 100 / $genome_size" | bc -l
echo "% of genome is protein-coding"

```
# Week 4 Assignment Questions

1. Identify the accession numbers for the genome
   * Reference genome: GCF_000013425.1 (or NC_007793.1)
   * Sample data: BioProject ID PRJNA887926
      * Control replicate 1 - SRR21835898
      * Control replicate 2 - SRR21835897
      * Control replicate 3 - SRR21835896
      * Treatment replicate 1 - SRR21835901	
      * Treatment replicate 2 - SRR21835900
      * Treatment replicate 3 - SRR21835899
        
2. How big is the genome
   - Total genome size: 17509287 bp
   
4. How many features of each type does the GFF file contain?
   - 2842 gene
   - 2767 CDS
   - 77 exon
   - 59 tRNA
   - 30 pseudogene
   - 16 rRNA
   - 2 pseudogenic_tRNA
   - 1 region
   
6. What is the longest gene?
   - Locus tag: SAOUHSC_01447
   - Length: 28,608 base pairs (28.6 kb)
   - Location: NC_007795.1:1376091-1404698
   - GeneID: 3920225
     
8. What is its name and function?
   - conserved hypothetical protein
   - Protein: Extracellular matrix-binding protein ebh
   - Function: Promotes bacterial attachment to both soluble and immobilized forms of         fibronectin (Fn), in a dose-dependent and saturable manner.
     
10. Pick another gene and describe its name and function.
    - recF
    - Length: 1113 bp
    - Location: NC_007795.1:3912-5024
    - Protein: DNA replication and repair protein RecF
    - Function: The RecF protein is involved in DNA metabolism; it is required for DNA replication and normal SOS inducibility. RecF binds preferentially to single-stranded, linear DNA. It also seems to bind ATP.
      
12. Look at the genomic features, are these closely packed, is there a lot of intragenomic space?
    - Total genome size:  2856629 bp
    - Total CDS length: 2352093 bp
    - ~82% coding
    - Gene density: 0.99 genes per kb
    - Yes, the genomic features appear to be very closely packed with relatively little intergenic space. The bacteria have evolved to be genomically efficient - almost every base pair serves a purpose!
      
14. Using IGV estimate how much of the genome is covered by coding sequences.
    - Had issues loading files. Kept getting "Unknown file type: /Users/annettemercedes/Documents/GitHub/applied-bioinfo/project/mrsa_analysis/S_aureus_USA300_genome.fastaCheck file extension"
      
16. Find alternative genome builds that could be used to perhaps answer a different question (find their accession numbers).
    - Staphylococcus aureus strain:MRSA107
    - GCF_002895385.1
