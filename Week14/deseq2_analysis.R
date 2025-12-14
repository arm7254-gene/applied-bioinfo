#!/usr/bin/env Rscript
# Differential Expression Analysis with DESeq2
# Usage: Rscript deseq2_analysis.R

library(DESeq2)
library(gplots)
library(ggplot2)

cat("=== Reading count matrix ===\n")
# Read count matrix
counts <- read.csv("counts/count_matrix.txt", row.names=1)

# Read design file
design <- read.csv("design.csv")

# Create output directory
dir.create("results", showWarnings=FALSE)

cat("\n=== Setting up DESeq2 ===\n")
# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = design,
  design = ~ Condition
)

# Run DESeq2
dds <- DESeq(dds)

# Get results
res <- results(dds, contrast=c("Condition", "Treatment", "Control"))

# Order by p-value
res_ordered <- res[order(res$pvalue),]

cat("\n=== Summary of Results ===\n")
summary(res)

# Save all results
write.csv(as.data.frame(res_ordered), "results/deseq2_all_genes.csv")

# Get significant genes (padj < 0.05, |log2FC| > 1)
sig_genes <- subset(res_ordered, padj < 0.05 & abs(log2FoldChange) > 1)
write.csv(as.data.frame(sig_genes), "results/deseq2_significant_genes.csv")

cat(sprintf("\nTotal genes tested: %d\n", nrow(res)))
cat(sprintf("Significant genes (padj < 0.05, |log2FC| > 1): %d\n", nrow(sig_genes)))
cat(sprintf("  - Upregulated in Treatment: %d\n", sum(sig_genes$log2FoldChange > 1)))
cat(sprintf("  - Downregulated in Treatment: %d\n", sum(sig_genes$log2FoldChange < -1)))

cat("\n=== Top 10 Differentially Expressed Genes ===\n")
print(head(sig_genes[,c("log2FoldChange", "padj")], 10))

cat("\n=== Creating Visualizations ===\n")

# 1. PCA Plot
cat("Creating PCA plot...\n")
rld <- rlog(dds)
png("results/pca_plot.png", width=800, height=600)
pcaData <- plotPCA(rld, intgroup="Condition", returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
ggplot(pcaData, aes(x=PC1, y=PC2, color=Condition)) +
  geom_point(size=3) +
  xlab(paste0("PC1: ", percentVar[1], "% variance")) +
  ylab(paste0("PC2: ", percentVar[2], "% variance")) +
  ggtitle("PCA: Control vs Treatment") +
  theme_bw()
dev.off()

# 2. Heatmap of top 50 significant genes
cat("Creating heatmap...\n")
if(nrow(sig_genes) >= 50) {
  top_genes <- head(sig_genes, 50)
} else {
  top_genes <- sig_genes
}

if(nrow(top_genes) > 0) {
  top_counts <- counts(dds, normalized=TRUE)[rownames(top_genes),]
  
  # Get gene annotations for row labels
  gff <- read.table("genome/S_aureus_USA300.gff", 
                    sep="\t", quote="", comment.char="#", 
                    stringsAsFactors=FALSE, fill=TRUE)
  colnames(gff) <- c("seqid", "source", "type", "start", "end", 
                     "score", "strand", "phase", "attributes")
  cds_gff <- gff[gff$type == "CDS", ]
  
  parse_attr <- function(attr_string, tag) {
    pattern <- paste0(tag, "=([^;]+)")
    match <- regexpr(pattern, attr_string, perl=TRUE)
    if (match[1] > 0) {
      start <- attr(match, "capture.start")
      length <- attr(match, "capture.length")
      return(substring(attr_string, start, start + length - 1))
    }
    return(NA)
  }
  
  cds_gff$locus_tag <- sapply(cds_gff$attributes, parse_attr, tag="locus_tag")
  cds_gff$gene_name <- sapply(cds_gff$attributes, parse_attr, tag="gene")
  cds_gff$product <- sapply(cds_gff$attributes, parse_attr, tag="product")
  
  make_label <- function(locus, gene_name, product) {
    if (!is.na(gene_name) && gene_name != "") {
      return(gene_name)
    }
    if (!is.na(product) && product != "") {
      words <- strsplit(product, " ")[[1]]
      skip_words <- c("putative", "hypothetical", "probable", "possible")
      for (word in words) {
        if (!(tolower(word) %in% skip_words) && nchar(word) > 3) {
          return(paste0(substr(word, 1, 15), "..."))  # Truncate long names
        }
      }
    }
    return(substr(locus, 1, 12))  # Shorten locus tag
  }
  
  label_lookup <- mapply(make_label, 
                         cds_gff$locus_tag, 
                         cds_gff$gene_name, 
                         cds_gff$product)
  names(label_lookup) <- cds_gff$locus_tag
  
  # Create row labels
  row_loci <- gsub("gene-", "", rownames(top_genes))
  row_labels <- sapply(row_loci, function(x) {
    if (x %in% names(label_lookup)) {
      return(label_lookup[x])
    } else {
      return(x)
    }
  })
  
  png("results/heatmap_significant.png", width=900, height=1200)
  heatmap.2(as.matrix(top_counts),
            scale="row",
            trace="none",
            col=colorpanel(100, "blue", "white", "red"),
            margins=c(12,18),
            main=sprintf("Top %d Significant Genes\n(normalized counts, row-scaled)", nrow(top_genes)),
            cexRow=0.7,
            cexCol=1.2,
            labRow=row_labels,
            labCol=paste(design$Condition, design$Sample, sep="_"))
  dev.off()
}

# 3. Volcano Plot with Gene Names
cat("Creating volcano plot...\n")

# Get gene annotations from GFF
gff <- read.table("genome/S_aureus_USA300.gff", 
                  sep="\t", quote="", comment.char="#", 
                  stringsAsFactors=FALSE, fill=TRUE)
colnames(gff) <- c("seqid", "source", "type", "start", "end", 
                   "score", "strand", "phase", "attributes")
cds_gff <- gff[gff$type == "CDS", ]

parse_attr <- function(attr_string, tag) {
  pattern <- paste0(tag, "=([^;]+)")
  match <- regexpr(pattern, attr_string, perl=TRUE)
  if (match[1] > 0) {
    start <- attr(match, "capture.start")
    length <- attr(match, "capture.length")
    return(substring(attr_string, start, start + length - 1))
  }
  return(NA)
}

cds_gff$locus_tag <- sapply(cds_gff$attributes, parse_attr, tag="locus_tag")
cds_gff$gene_name <- sapply(cds_gff$attributes, parse_attr, tag="gene")
cds_gff$product <- sapply(cds_gff$attributes, parse_attr, tag="product")

# Create display name: gene name > short product > locus tag
make_label <- function(locus, gene_name, product) {
  if (!is.na(gene_name) && gene_name != "") {
    return(gene_name)
  }
  if (!is.na(product) && product != "") {
    # Extract first meaningful word from product
    words <- strsplit(product, " ")[[1]]
    # Skip common words
    skip_words <- c("putative", "hypothetical", "probable", "possible")
    for (word in words) {
      if (!(tolower(word) %in% skip_words) && nchar(word) > 3) {
        return(word)
      }
    }
  }
  return(locus)
}

# Create lookup table
label_lookup <- mapply(make_label, 
                       cds_gff$locus_tag, 
                       cds_gff$gene_name, 
                       cds_gff$product)
names(label_lookup) <- cds_gff$locus_tag

png("results/volcano_plot.png", width=900, height=700)

# Prepare data
volcano_data <- data.frame(
  Gene = rownames(res),
  log2FC = res$log2FoldChange,
  pvalue = res$pvalue,
  padj = res$padj
)

volcano_data <- volcano_data[!is.na(volcano_data$pvalue), ]
volcano_data$neglog10p <- -log10(volcano_data$pvalue)

# Get top genes to label
top_genes_to_label <- head(volcano_data[order(volcano_data$pvalue), ], 10)
top_genes_to_label$locus <- gsub("gene-", "", top_genes_to_label$Gene)
top_genes_to_label$display_name <- sapply(top_genes_to_label$locus, 
                                           function(x) label_lookup[x])

# Plot
with(volcano_data, plot(log2FC, neglog10p, 
               pch=20, main="Volcano Plot: Differentially Expressed Genes", 
               xlab="log2 Fold Change (Treatment vs Control)", 
               ylab="-log10 p-value",
               col="gray"))

# Highlight significant genes
with(subset(volcano_data, padj<0.05 & abs(log2FC)>1), 
     points(log2FC, neglog10p, pch=20, col="red"))

# Add threshold lines
abline(h=-log10(0.05), col="blue", lty=2)
abline(v=c(-1,1), col="blue", lty=2)

# Add gene labels
with(top_genes_to_label, 
     text(log2FC, neglog10p, 
          labels=display_name, 
          cex=0.7, pos=4, offset=0.3, font=2))

legend("topright", 
       legend=c("Significant (padj<0.05, |log2FC|>1)", "Not significant"),
       col=c("red", "gray"), 
       pch=20,
       cex=0.8)

dev.off()

# 4. MA Plot
cat("Creating MA plot...\n")
png("results/ma_plot.png", width=800, height=600)
plotMA(res, main="MA Plot", ylim=c(-5,5))
dev.off()

cat("\n=== Analysis Complete! ===\n")
cat("\nResults saved to:\n")
cat("  - results/deseq2_all_genes.csv (all genes)\n")
cat("  - results/deseq2_significant_genes.csv (significant genes only)\n")
cat("\nVisualizations saved to:\n")
cat("  - results/pca_plot.png\n")
cat("  - results/heatmap_significant.png\n")
cat("  - results/volcano_plot.png\n")
cat("  - results/ma_plot.png\n")
cat("\nNext step: Run functional enrichment analysis\n")