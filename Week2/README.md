# Week 2 Assignment

# Week 2: Command Log

```bash
# Use wget to fetch the file
curl -O https://ftp.ensembl.org/pub/current_gff3/calidris_pygmaea/Calidris_pygmaea.ASM369795v1.115.abinitio.gff3.gz

# Uncompress it
gunzip Calidris_pygmaea.ASM369795v1.115.abinitio.gff3.gz

# Rename the file to something simple
mv Calidris_pygmaea.ASM369795v1.115.abinitio.gff3 spoon_bill.gff3

# Count unique sequence regions (column 1 of GFF)
grep -v "^#" spoon_bill.gff3 | cut -f1 | sort | uniq | wc -l

# Count all feature lines (excluding header/comment lines)
grep -v "^#" spoon_bill.gff3 | wc -l

# See what types of features are present and their counts
grep -v "^#" spoon_bill.gff3 | cut -f3 | sort | uniq -c | sort -nr

# Count mRNA features (these represent the genes/transcripts)
grep -v "^#" spoon_bill.gff3 | grep -w "mRNA" | wc -l

To find the top-ten most annotated feature types, use this command:
bash# Get the top 10 most common feature types
grep -v "^#" spoon_bill.gff3 | cut -f3 | sort | uniq -c | sort -nr | head -10

# Calculate total genome size
grep -v "^#" spoon_bill.gff3 | grep region | awk '{sum += $5} END {print "Total genome size:", sum " bp"}'

```

## 1. Tell us a bit about the organism.

Spoon-billed sandpiper
The **spoon-billed sandpiper** (Calidris pygmaea) is a small wader which breeds on the coasts of the Bering Sea and winters in Southeast Asia. his species is highly threatened, and it is said that since the 1970s the breeding population has decreased significantly. By 2000, the estimated breeding population of the species was 350–500

## 2. How many sequence regions (chromosomes) does the file contain? Does that match with the expectation for this organism?

29818

## 3. How many features does the file contain?

* 345146 exon
* 51938 mRNA
* 29818 region

## 4. How many genes are listed for this organism?

51938

## 5. Is there a feature type that you may have not heard about before? What is the feature and how is it defined? (If there is no such feature, pick a common feature.)

The region feature type is defined in the GFF3 specification as: A sequence feature with an extent greater than zero.

## 6. What are the top-ten most annotated feature types (column 3) across the genome?

* 345146 exon
* 51938 mRNA
* 29818 region

## 7. Having analyzed this GFF file, does it seem like a complete and well-annotated organism?

Compared to more comprehensive genome annotations, this file is missing:

* CDS (coding sequences)
* UTRs (untranslated regions)
* gene features (parent level)

This suggests it's a very basic gene structure prediction. The 29,818 regions tell us this genome assembly is quite fragmented, which makes sense for a non-model organism draft assembly.

## 8. Share any other insights you might note.

Total genome size: 1178350366 bp (1.178 Gb). According to Google, bird genomes typically range from 1.15 to 1.62 pg of DNA per haploid genome, which translates to roughly 1 Gb to 2.1 Gb. The spoon-billed sandpiper at 1.18 Gb sits right at the lower end of the typical bird range.