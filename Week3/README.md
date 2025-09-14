# Week 3 Assignment

# Week 3: Command Log

```bash
#make directory for bacterial genomes
mkdir IGV

#change directories
cd IGV/

#activate environment
micromamba activate bioinfo

#download bacterial genome (FASTA)
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/bacteria/current/fasta/bacteria_0_collection/borreliella_burgdorferi_b31_gca_000008685/dna/Borreliella_burgdorferi_b31_gca_000008685.ASM868v2.dna.toplevel.fa.gz

#confirm file has been downloaded
ls

#unzip file
gunzip Borreliella_burgdorferi_b31_gca_000008685.ASM868v2.dna.toplevel.fa.gz

#make file name simpler
mv Borreliella_burgdorferi_b31_gca_000008685.ASM868v2.dna.toplevel.fa burg.fa

#see what is in this file
seqkit stats burg.fa

#extract file name IDs
cat burg.fa | grep ">"

#download bacterial genome (GFF)
wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/bacteria/current/gff3/bacteria_0_collection/borreliella_burgdorferi_b31_gca_000008685/Borreliella_burgdorferi_b31_gca_000008685.ASM868v2.62.gff3.gz

#unzip file
gunzip Borreliella_burgdorferi_b31_gca_000008685.ASM868v2.62.gff3.gz

#make file name simpler
mv Borreliella_burgdorferi_b31_gca_000008685.ASM868v2.62.gff3 burg.gff

# Calculate total genome size
grep -v "^#" burg.gff | grep region | awk '{sum += $5} END {print "Total genome size:", sum " bp"}'

# See what types of features are present and their counts
grep -v "^#" burg.gff | cut -f3 | sort | uniq -c | sort -nr

```
# Week 3: Assignment Prompts

## 1. How big is the genome, and how many features of each type does the GFF file contain?

Total genome size: 646320 bp

* 1340 exon
* 1340 CDS
* 1339 mRNA
* 1339 gene
* 21 region
* 1 chromosome
  

