#!/usr/bin/env Rscript
# Super simple count matrix visualization
# Usage: Rscript visualize_counts.R

# Load library
library(gplots)

# Read count matrix
counts <- read.csv("counts/count_matrix.txt", row.names=1)

# Get top 30 most highly expressed genes
top_genes <- head(counts[order(-rowSums(counts)),], 30)

# Create heatmap
png("counts/heatmap_top30.png", width=800, height=1000)
heatmap.2(as.matrix(top_genes), 
          trace="none",
          col=colorpanel(100, "blue", "white", "red"),
          margins=c(10,15),
          main="Top 30 Most Expressed Genes\nControl vs Treatment",
          cexRow=0.8,
          cexCol=1.2)
dev.off()

cat("\n=== Heatmap created: counts/heatmap_top30.png ===\n\n")

# Print summary
cat("Top 5 genes by total expression:\n")
print(head(top_genes, 5))

cat("\n\nControl samples (first 3 columns) vs Treatment samples (last 3 columns)\n")
cat("Red = high expression, Blue = low expression\n")
