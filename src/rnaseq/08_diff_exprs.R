# Load libraries
library("pairedGSEA")
library("tidyverse")

# Load count matrix
counts <- read_tsv("data/rnaseq/diff_exprs/count_matrix.tsv") %>% 
  column_to_rownames("id") %>%
  as.matrix() %>%
  round()
ids <- colnames(counts)

# Load metadata
meta <- read_delim("data/rnaseq/_raw/rnaseq_meta.txt", delim = ",") %>%
  filter(Run %in% ids) %>%
  filter(!(Run %in% c("SRR1782694", "SRR1782695"))) %>%
  dplyr::select(Run, diagnosis)

# Create a condition column and rename sample column
meta <- meta %>% 
  mutate(
    condition = case_when(
      diagnosis == "Not IBD" ~ "Control", 
      diagnosis == "not IBD" ~ "Control",
      diagnosis == "CD" ~ "CD"
    )
  ) %>%
  dplyr::rename(sample_id = Run) %>%
  dplyr::select(sample_id, condition, deep_ulcer)

# Select only the specified samples from count matrix
counts <- counts[, meta$sample_id]

# Check that the rownames of the count matrix is aligned with the metadata
all(colnames(counts) == meta$sample_id)

# Run paired DESeq2 and DEXSeq analyses 
diff_results <- paired_diff(
    object = counts,
    metadata = meta, # Use with count matrix or if you want to change it in
    # the input object
    group_col = 'condition',
    sample_col = 'sample_id',
    baseline = 'Control',
    case = 'CD',
    store_results = TRUE,
    experiment_title = "Pediatric_Crohn_disease",
)

