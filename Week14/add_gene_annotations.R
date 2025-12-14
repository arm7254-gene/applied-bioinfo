#!/usr/bin/env Rscript
# Add gene annotations to DESeq2 results

# Read GFF to get gene names and products
gff <- read.table("genome/S_aureus_USA300.gff", 
                  sep="\t", quote="", comment.char="#", 
                  stringsAsFactors=FALSE, fill=TRUE)
colnames(gff) <- c("seqid", "source", "type", "start", "end", 
                   "score", "strand", "phase", "attributes")

cds_gff <- gff[gff$type == "CDS", ]

# Parse attributes
parse_attr <- function(attr_string, tag) {
  pattern <- paste0(tag, "=([^;]+)")
  match <- regexpr(pattern, attr_string, perl=TRUE)
  if (match[1] > 0) {
    start <- attr(match, "capture.start")
    length <- attr(match, "capture.length")
    result <- substring(attr_string, start, start + length - 1)
    return(gsub("%2C", ",", result))
  }
  return(NA)
}

cds_gff$locus_tag <- sapply(cds_gff$attributes, parse_attr, tag="locus_tag")
cds_gff$gene_name <- sapply(cds_gff$attributes, parse_attr, tag="gene")
cds_gff$product <- sapply(cds_gff$attributes, parse_attr, tag="product")

# Create annotation lookup
annotations <- data.frame(
  locus_tag = cds_gff$locus_tag,
  gene_name = cds_gff$gene_name,
  product = cds_gff$product,
  stringsAsFactors = FALSE
)

# Read DESeq2 results
sig_genes <- read.csv("results/deseq2_significant_genes.csv", row.names=1)

# Add annotations
sig_genes$locus_tag <- gsub("gene-", "", rownames(sig_genes))
sig_genes <- merge(sig_genes, annotations, by="locus_tag", all.x=TRUE)

# Create display name: use gene name if available, otherwise locus_tag
sig_genes$display_name <- ifelse(!is.na(sig_genes$gene_name) & sig_genes$gene_name != "", 
                                  sig_genes$gene_name, 
                                  sig_genes$locus_tag)

# Reorder columns
sig_genes <- sig_genes[, c("locus_tag", "gene_name", "product", "display_name", 
                           "baseMean", "log2FoldChange", "lfcSE", "stat", "pvalue", "padj")]

# Save annotated results
write.csv(sig_genes, "results/deseq2_significant_genes_annotated.csv", row.names=FALSE)

cat("\n=== Top 10 Genes with Annotations ===\n")
print(head(sig_genes[order(sig_genes$pvalue), 
                     c("display_name", "product", "log2FoldChange", "padj")], 10))

cat("\n\nAnnotated results saved to: results/deseq2_significant_genes_annotated.csv\n")
