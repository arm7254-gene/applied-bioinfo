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

