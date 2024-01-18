# Load libraries
library("tidyverse")
library("pairedGSEA")

# Load DESeq2 and DEXSeq results
aggregate_results <- readRDS("data/rnaseq/diff_exprs/Pediatric_Crohn_disease_aggregated_pvals.RDS")
aggregate_results

# Load gene sets
gene_set_list <- readRDS("data/rnaseq/diff_exprs/gene_sets.RDS")
tibble(gene_set = names(gene_set_list)) %>%
  mutate(db = str_extract(gene_set, "^[^_]+(?=_)")) %>%
  dplyr::count(db)

# Run over-representation analysis
paired_ora <- paired_ora(
  paired_diff_result = aggregate_results,
  gene_sets = gene_set_list,
  experiment_title = "Pediatric_Crohn_disease"
)

### DGE:
dge_ora_sorted <- paired_ora %>%
  arrange(padj_deseq) %>%
  dplyr::select(pathway, padj_deseq, enrichment_score_deseq) %>%
  filter(padj_deseq <= 0.05)
print(dge_ora_sorted, n = 68)

### DGU ORA:
dgu_ora_sorted <- paired_ora %>%
  arrange(padj_dexseq) %>%
  dplyr::select(pathway, padj_dexseq, enrichment_score_dexseq)
head(dgu_ora_sorted, 15)


ora_plot <- plot_ora(
  ora = paired_ora,
  plotly = FALSE,
  pattern = "INTERFERON", # Identify all gene sets about XXXX
  cutoff = 0.1, # Only include significant gene sets
  lines = TRUE, # Guide lines
  colors = c("red", "blue", "black")
)
ggsave("results/ora_plot_interferon.png", ora_plot)

data(examplePathways)
data(exampleRanks)
## Not run:
example_ranks <- aggregate_results %>%
  drop_na(padj_deseq) %>%
  pull(padj_deseq)
names(example_ranks) <- aggregate_results %>%
  drop_na(padj_deseq) %>%
  pull(gene)

enrichment_plot <- plotEnrichment(gene_set_list[["REACTOME_INTERFERON_GAMMA_SIGNALING"]], example_ranks)
ggsave("results/enrichment_plot.png", enrichment_plot)
