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

sum(aggregate_pvalues$padj_dexseq <= 0.05, na.rm = TRUE)
aggregate_pvalues %>%
  filter(padj_dexseq <= 0.05) %>%
  arrange(padj_dexseq)

# Load aggregated results
aggregate_pvalues <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_aggregated_pvals.RDS")
aggregate_pvalues

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

# Step 1: Prepare the Data
# Extract normalized counts or use rlog/vst
data <- assay(rlog(dds_deseq)) 

# Convert to tidy format
tidy_data <- as.data.frame(data) %>%
  rownames_to_column(var = "gene") %>%
  gather(key = "sample", value = "expression", -gene)

# Step 2: Data Wrangling
# Select genes of interest, for example, top 20 by variance
top_genes <- tidy_data %>%
  group_by(gene) %>%
  summarize(variance = var(expression)) %>%
  top_n(20, variance) %>%
  pull(gene)

filtered_data <- tidy_data %>%
  filter(gene %in% top_genes)

# Optionally, add sample clustering/ordering

# Step 3: Create the Heatmap
ggplot(filtered_data, aes(x = sample, y = gene, fill = expression)) +
  geom_tile() +
  scale_fill_gradientn(colors = c("blue", "white", "red")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
