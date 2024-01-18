# Load libaries
library("tidyverse")
library("ggrepel")

# Load DESeq2 results
deseq_results <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_deseqres.RDS")
deseq_results <- deseq_results %>%
  as.data.frame() %>%
  rownames_to_column("id") %>%
  as_tibble()
sum(deseq_results$padj <= 0.05, na.rm = TRUE) # / nrow(deseq_results)

# Load DEXSeq results
dexseq_results <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_dexseqres.RDS")
dexseq_results <- dexseq_results %>%
  as.data.frame() %>%
  rownames_to_column("id") %>%
  as_tibble()
sum(dexseq_results$padj <= 0.05, na.rm = TRUE) # / nrow(dexseq_results)

# Load aggregated results
aggregate_pvalues <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_aggregated_pvals.RDS")
aggregate_pvalues

sum(aggregate_pvalues$padj_deseq <= 0.05, na.rm = TRUE)
sum(aggregate_pvalues$padj_dexseq <= 0.05, na.rm = TRUE)
aggregate_pvalues %>%
  filter(padj_dexseq <= 0.05) %>%
  arrange(padj_dexseq)

# Vulcano plot
aggregate_pvalues <- aggregate_pvalues |>
  mutate(
    is_significant = case_when(
      padj_deseq <= 0.05 ~ "yes",
      padj_deseq > 0.05 ~ "no"
    ),
    regulated = case_when(
      is_significant == "yes" & lfc_deseq > 2 ~ "up",
      is_significant == "yes" & lfc_deseq < -2 ~ "down"
    )
  )

pl1 <- aggregate_pvalues |>
  mutate(
    lbl = case_when(
      is_significant == "yes" ~ gene,
      is_significant == "no" ~ ""
    )
  ) |>
  ggplot(aes(
    x = lfc_deseq,
    y = -log10(padj_deseq),
    colour = regulated,
    label = lbl
  )) +
  geom_point(
    size = 0.5,
    alpha = 0.5
  ) +
  geom_text_repel(
    size = 4,
    max.overlaps = 25,
    force = 2.5
  ) +
  geom_hline(yintercept = 0) +
  geom_hline(yintercept = -log(0.05, base = 10), linetype = "dashed", color = "red") +
  geom_vline(xintercept = 2, linetype = "dashed", color = "red") +
  geom_vline(xintercept = -2, linetype = "dashed", color = "red") +
  # theme_minimal(base_size = 16) +
  theme_bw() +
  theme(
    legend.position = "none",
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20),
    axis.text = element_text(size = 16)
  ) +
  labs(
    x = bquote(log[2]("fold change")),
    y = bquote(-log[10]("adj. p-value")),
    # title = "Genes Associated with ileal Crohn's disease",
    # subtitle = str_c("Trancripts highlighted"),
    caption = "Data from DOI: https://doi.org/10.1172/JCI75436"
  ) +
  scale_color_manual(values = c("blue", "red", "black")) +
  coord_cartesian(
    xlim = c(-7, 10)
  )
ggsave("results/rnaseq/diff_exprs/vulcano_plot_deseq.png", pl1, height = 8, width = 6)


# Heatmap
library("DESeq2")
library("tidyverse")
library("ggplot2")

dds_deseq <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_dds.RDS")

top_genes <- aggregate_pvalues %>%
  filter(padj_deseq <= 0.05 & abs(lfc_deseq) > 2) %>%
  arrange(desc(lfc_deseq))

top_genes_deseq <- deseq_results %>%
  filter(
    padj < 0.3,
    str_detect(string = id, pattern = paste(top_genes$gene, collapse = "|"))
  ) %>%
  separate(col = "id", into = c("gene", "transcript_id"), sep = "\\:") %>%
  group_by(gene) %>%
  arrange(padj) %>%
  slice_head(n = 1) %>%
  unite(col = "id", c("gene", "transcript_id"), sep = ":") %>%
  arrange(desc(log2FoldChange))

# Step 1: Prepare the Data
# Extract normalized counts data by using rlog
norm_data <- rlog(dds_deseq, blind = FALSE)
mat <- assay(norm_data) %>%
  as.data.frame() %>%
  rownames_to_column("id") %>%
  filter(id %in% top_genes_deseq$id) %>%
  column_to_rownames("id")
mat <- mat[top_genes_deseq$id, ]
base_mean <- rowMeans(mat)
mat_scaled <- t(apply(mat, 1, scale))
colnames(mat_scaled) <- colData(dds_deseq)$sample_id

# Log2 fold change and baseMean columns
num_keep <- 66
rows_keep <- c(seq(1:num_keep)) # , seq((nrow(mat_scaled) - 2), nrow(mat_scaled)))

# Log2FC
l2_val <- as.matrix(top_genes[rows_keep, ]$lfc_deseq)
colnames(l2_val) <- "log2FC"

# BaseMean
base_mean_val <- as.matrix(top_genes_deseq[rows_keep, ]$baseMean)
colnames(base_mean_val) <- "AveExpr"

library("ComplexHeatmap")
library("RColorBrewer")
library("circlize")

top_genes_deseq <- top_genes_deseq %>%
  separate(col = "id", into = c("gene", "transcript_id"), sep = "\\:")

# maps values between b/w/r for min and max l2 values
col_logFC <- colorRamp2(
  c(min(l2_val), 0, max(l2_val)), c("white", "lightblue", "blue")
)

# maps between 0% quantile, and 75% quantile of mean values --- 0, 25, 50, 75, 100
col_AveExpr <- colorRamp2(
  c(quantile(base_mean_val)[1], quantile(base_mean_val)[4]), c("white", "red")
)

# Extract condition information
sample_conditions <- colData(dds_deseq)$condition
sample_ids <- colData(dds_deseq)$sample_id

# Create a data frame for annotation
sample_annotation <- data.frame(
  Condition = factor(sample_conditions,
    levels = unique(sample_conditions)
  )
)
rownames(sample_annotation) <- sample_ids

# Extract unique conditions
unique_conditions <- unique(sample_annotation$Condition)

# Assign colors to each unique condition
# Modify this to match the number of unique conditions you have
condition_colors <- setNames(c("purple", "yellow"), unique_conditions)

# Create the annotation object with the named color vector
ha_samples <- HeatmapAnnotation(
  df = sample_annotation,
  col = list(Condition = condition_colors),
  show_annotation_name = FALSE,
  annotation_legend_param = list(
    Condition = list(
      nrow = 1,
      title_gp = gpar(fontsize = 18),
      labels_gp = gpar(fontsize = 16)
    )
  )
)

# Adjust font size for column labels
column_label_size <- gpar(fontsize = 16) # Change 12 to your desired size

# Adjust font size for row labels
row_label_size <- gpar(fontsize = 16) # Change 12 to your desired size


# Heatmap
ha <- HeatmapAnnotation(summary = anno_summary(
  gp = gpar(fill = 2),
  height = unit(3, "cm")
))

# Add the annotation to the heatmap
h1 <- Heatmap(
  mat_scaled[rows_keep, ],
  cluster_rows = FALSE,
  column_labels = colnames(mat_scaled),
  name = "Z-score",
  cluster_columns = TRUE,
  height = unit(30, "cm"),
  top_annotation = ha_samples, # Add this line
  column_names_gp = column_label_size,
  heatmap_legend_param = list(
    title_gp = gpar(fontsize = 16),
    labels_gp = gpar(fontsize = 14)
  ), # Adjust legend font size
  column_names_rot = 40
)
h2 <- Heatmap(l2_val,
  row_labels = top_genes_deseq$gene[rows_keep],
  cluster_rows = FALSE, name = "log2FC", top_annotation = ha, col = col_logFC,
  row_names_gp = row_label_size, # Apply adjusted font size
  heatmap_legend_param = list(
    title_gp = gpar(fontsize = 16),
    labels_gp = gpar(fontsize = 14)
  ),
  column_names_rot = 40,
  cell_fun = function(j, i, x, y, w, h, col) { # add text to each grid
    grid.text(round(l2_val[i, j], 2), x, y)
  }
)
h3 <- Heatmap(base_mean_val,
  row_labels = top_genes_deseq$gene[rows_keep],
  cluster_rows = FALSE, name = "AveExpr", col = col_AveExpr,
  row_names_gp = row_label_size, # Apply adjusted font size
  heatmap_legend_param = list(
    title_gp = gpar(fontsize = 16),
    labels_gp = gpar(fontsize = 14)
  ),
  column_names_rot = 40,
  cell_fun = function(j, i, x, y, w, h, col) { # add text to each grid
    grid.text(round(base_mean_val[i, j], 2), x, y)
  }
)

h <- h1 + h2 + h3
h <- draw(h,
  heatmap_legend_side = "right", annotation_legend_side = "top",
  legend_grouping = "original"
)

png("results/rnaseq/diff_exprs/heatmap_v3.png", res = 400, width = 7500, height = 6500)
print(h)
dev.off()
