#!/usr/bin/env Rscript
# Functional Enrichment Analysis Using GFF Annotations

library(ggplot2)

cat("=== Functional Enrichment Analysis ===\n\n")

# Read GFF - look at CDS features which have product info
gff <- read.table("genome/S_aureus_USA300.gff", 
                  sep="\t", quote="", comment.char="#", 
                  stringsAsFactors=FALSE, fill=TRUE)
colnames(gff) <- c("seqid", "source", "type", "start", "end", 
                   "score", "strand", "phase", "attributes")

# Use CDS instead of gene for product annotations
cds_gff <- gff[gff$type == "CDS", ]

cat(sprintf("Found %d CDS features with annotations\n", nrow(cds_gff)))

# Parse attributes
parse_attr <- function(attr_string, tag) {
  pattern <- paste0(tag, "=([^;]+)")
  match <- regexpr(pattern, attr_string, perl=TRUE)
  if (match[1] > 0) {
    start <- attr(match, "capture.start")
    length <- attr(match, "capture.length")
    result <- substring(attr_string, start, start + length - 1)
    return(gsub("%2C", ",", result))  # Decode URL encoding
  }
  return(NA)
}

cds_gff$locus_tag <- sapply(cds_gff$attributes, parse_attr, tag="locus_tag")
cds_gff$product <- sapply(cds_gff$attributes, parse_attr, tag="product")

# Check how many have products
cat(sprintf("CDS with product annotations: %d\n", sum(!is.na(cds_gff$product))))
cat(sprintf("CDS without product: %d\n\n", sum(is.na(cds_gff$product))))

# Read significant genes
sig_genes <- read.csv("results/deseq2_significant_genes.csv", row.names=1)
up_ids <- gsub("gene-", "", rownames(sig_genes)[sig_genes$log2FoldChange > 1])
down_ids <- gsub("gene-", "", rownames(sig_genes)[sig_genes$log2FoldChange < -1])

cat(sprintf("Upregulated: %d genes\n", length(up_ids)))
cat(sprintf("Downregulated: %d genes\n\n", length(down_ids)))

# Categorize genes
categorize <- function(product) {
  if (is.na(product) || product == "") return("Unknown/Hypothetical")
  product <- tolower(product)
  
  if (grepl("hypothetical|uncharacterized|putative", product)) return("Unknown/Hypothetical")
  if (grepl("ribosom|50s|30s|translation", product)) return("Translation/Ribosome")
  if (grepl("transcri|rna polymer|sigma", product)) return("Transcription")
  if (grepl("dna|replic|topoisom|gyrase|helicase", product)) return("DNA Replication/Repair")
  if (grepl("dehydrogenase|synthase|reductase|kinase|transferase", product)) return("Metabolism")
  if (grepl("transport|permease|abc|channel", product)) return("Transport")
  if (grepl("cell wall|peptidoglycan|murein", product)) return("Cell Wall")
  if (grepl("membrane|lipoprot", product)) return("Membrane")
  if (grepl("regulator|repressor|activator", product)) return("Regulation")
  if (grepl("stress|chaperone|heat shock|clp", product)) return("Stress Response")
  
  return("Other Functions")
}

# Map locus tags to products
all_products <- cds_gff$product
names(all_products) <- cds_gff$locus_tag

# Categorize
up_cats <- table(sapply(all_products[up_ids], categorize))
down_cats <- table(sapply(all_products[down_ids], categorize))

# Get all category names
all_cat_names <- sort(unique(c(names(up_cats), names(down_cats))))

# Create complete data frame
enrichment_summary <- data.frame(
  Category = all_cat_names,
  Upregulated = sapply(all_cat_names, function(x) ifelse(x %in% names(up_cats), up_cats[x], 0)),
  Downregulated = sapply(all_cat_names, function(x) ifelse(x %in% names(down_cats), down_cats[x], 0))
)
enrichment_summary$Total <- enrichment_summary$Upregulated + enrichment_summary$Downregulated
enrichment_summary <- enrichment_summary[order(-enrichment_summary$Total), ]

cat("=== Functional Categories ===\n")
print(enrichment_summary)

write.csv(enrichment_summary, "results/functional_enrichment.csv", row.names=FALSE)

# Prepare data for plotting (exclude Unknown if it's too dominant)
plot_data <- enrichment_summary
if (plot_data$Total[plot_data$Category == "Unknown/Hypothetical"][1] > 100) {
  cat("\nNote: Excluding 'Unknown/Hypothetical' from plot due to large number\n")
  plot_data <- plot_data[plot_data$Category != "Unknown/Hypothetical", ]
}

# Reshape for ggplot
comp_data <- data.frame(
  Category = rep(plot_data$Category, 2),
  Count = c(plot_data$Upregulated, plot_data$Downregulated),
  Direction = rep(c("Upregulated", "Downregulated"), each=nrow(plot_data))
)

# Plot
png("results/functional_categories.png", width=1000, height=600)
ggplot(comp_data, aes(x=reorder(Category, Count), y=Count, fill=Direction)) +
  geom_bar(stat="identity", position="dodge") +
  scale_fill_manual(values=c("Upregulated"="red", "Downregulated"="blue")) +
  coord_flip() +
  theme_bw() +
  ggtitle("Functional Categories in Differentially Expressed Genes") +
  xlab("Functional Category") +
  ylab("Number of Genes") +
  theme(legend.position="top", text=element_text(size=12))
dev.off()

cat("\n=== Files Created ===\n")
cat("  - results/functional_enrichment.csv\n")
cat("  - results/functional_categories.png\n")

cat("\n=== Top Categories ===\n")
for(i in 1:min(5, nrow(enrichment_summary))) {
  cat(sprintf("%d. %s: %d genes (%d up, %d down)\n", 
              i, 
              enrichment_summary$Category[i], 
              enrichment_summary$Total[i],
              enrichment_summary$Upregulated[i],
              enrichment_summary$Downregulated[i]))
}

cat("\n=== Analysis Complete ===\n")
