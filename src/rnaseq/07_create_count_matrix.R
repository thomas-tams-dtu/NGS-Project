library(tximport)
library(rhdf5)
library(rtracklayer)
library(tidyverse)
library(tidyr)

# Import GTF file and extract transcript-to-gene mapping
gtf <- rtracklayer::import("data/references/gencode.v45.chr_patch_hapl_scaff.annotation.gtf.gz")
gtf <- as.data.frame(gtf)
tx2gene <- gtf[, c("transcript_id", "gene_id", "gene_name")]

# Get list of sample directories
samples <- list.dirs("data/rnaseq/kallisto")
samples <- samples[2:length(samples)]

# Create file paths for abundance.h5 files
files <- file.path(paste0(samples, "/abundance.tsv"))
names(files) <- basename(samples)

# Import transcript-level data using tximport
txi <- tximport(
  files, 
  type = "kallisto", 
  txOut = TRUE, 
  tx2gene = tx2gene
)

# Define IDs for for splitting the kallisto output
id_columns <- c(
  "transcriptId", 
  "geneID", 
  "havanaGeneId",
  "havanaTranscriptId",
  "transcriptName",
  "geneName",
  "length",
  "geneType",
  "description"
)

# Split rownames into different columns and format correctly
counts <- txi$counts %>% 
  as.data.frame() %>%
  rownames_to_column("id") %>%
  separate(col = id, sep = "\\|", into = id_columns) %>%
  mutate(id = str_c(geneName, transcriptId, sep = ":")) %>%
  select(id, starts_with("SRR"))

# Save count matrix
write_tsv(
  x = counts,
  file = "data/rnaseq/deseq/count_matrix.tsv"
)