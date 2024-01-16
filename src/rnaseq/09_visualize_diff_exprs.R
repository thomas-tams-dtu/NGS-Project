# Load libaries
library("tidyverse")
library("ggrepel")

# Load DESeq2 results
deseq_results <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_deseqres.RDS")
deseq_results <- deseq_results %>% 
  as.data.frame() %>%
  rownames_to_column("id") %>%
  as_tibble()
sum(deseq_results$padj <= 0.05, na.rm = TRUE )# / nrow(deseq_results)

# Load DEXSeq results
dexseq_results <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_dexseqres.RDS")
dexseq_results <- dexseq_results %>% 
  as.data.frame() %>%
  rownames_to_column("id") %>%
  as_tibble()
sum(dexseq_results$padj <= 0.05, na.rm = TRUE ) #/ nrow(dexseq_results)

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
      lfc_deseq > 2 ~ "up",
      lfc_deseq < -2 ~ "down"
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
    size = 6,
    max.overlaps = 25,
    force = 2
  ) +
  geom_hline(yintercept = 0) +
  geom_hline(yintercept = -log(0.05, base = 10), linetype = "dashed", color = "red") +
  geom_vline(xintercept = 2, linetype = "dashed", color = "red") +
  geom_vline(xintercept = -2, linetype = "dashed", color = "red") +
  #theme_minimal(base_size = 16) +
  theme_bw() +
  theme(
    legend.position = "none",
    text = element_text(size = 20)
  ) +
  labs(
    x = bquote(log[2]("fold change")),
    y = bquote(-log[10]("adj. p-value")),
    #title = "Genes Associated with ileal Crohn's disease",
    #subtitle = str_c("Trancripts highlighted"),
    caption = "Data from DOI: https://doi.org/10.1172/JCI75436"
  ) +
  scale_color_manual(values = c("red", "blue", "black")) +
  coord_cartesian(
    xlim = c(-10, 10)
  )
ggsave("results/rnaseq/diff_exprs/vulcano_plot_deseq.png", pl1, height = 13, width = 12)


# Heatmap
library("DESeq2")
library("tidyverse")
library("ggplot2")

dds_deseq <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_dds.RDS")

top_genes <- aggregate_pvalues %>%
  filter(padj_deseq <= 0.05 & abs(lfc_deseq) > 2) %>%
  arrange(desc(lfc_deseq))

top_genes_deseq <- deseq_results %>%
  filter(padj < 0.3, str_detect(string = id, pattern = paste(top_genes$gene, collapse = "|"))) %>%
  separate(col = "id", into = c("gene", "transcript_id"), sep = "\\:") %>%
  group_by(gene) %>%
  arrange(padj) %>%
  dplyr::slice(n = 1) %>%
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
base_mean <- rowMeans(mat)
mat_scaled <- t(apply(mat, 1, scale))
colnames(mat_scaled) <- colData(dds_deseq)$sample_id

# Log2 fold change and baseMean columns
num_keep <- 25
rows_keep <- c(seq(1:num_keep), seq((nrow(mat_scaled) - num_keep), nrow(mat_scaled)))

# Log2FC
l2_val <- as.matrix(top_genes[rows_keep, ]$lfc_deseq)
colnames(l2_val) <- "log2FC"

# BaseMean
base_mean_val <- as.matrix(top_genes_deseq[rows_keep, ]$baseMean)
colnames(base_mean_val) <- "AveExpr"

library("ComplexHeatmap")
library("RColorBrewer")
library("circlize")

# Heatmap
ha <- HeatmapAnnotation(summary = anno_summary(gp = gpar(fill = 2), 
                                               height = unit(2, "cm")))

h1 <- Heatmap(mat_scaled[rows_keep,], cluster_rows = FALSE, 
            column_labels = colnames(mat_scaled), name="Z-score",
            cluster_columns = TRUE)
h2 <- Heatmap(l2_val, row_labels = df.top$symbol[rows_keep], 
            cluster_rows = F, name="logFC", top_annotation = ha, col = col_logFC,
            cell_fun = function(j, i, x, y, w, h, col) { # add text to each grid
              grid.text(round(l2_val[i, j],2), x, y)
            })
h3 <- Heatmap(mean, row_labels = df.top$symbol[rows_keep], 
            cluster_rows = F, name = "AveExpr", col=col_AveExpr,
            cell_fun = function(j, i, x, y, w, h, col) { # add text to each grid
              grid.text(round(mean[i, j],2), x, y)
            })

h <- h1 #+ h2 + h3

png("results/rnaseq/diff_exprs/heatmap_v1.png", res = 300)
print(h)
dev.off()
