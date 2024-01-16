#!/bin/bash

## Download amplicon metadata
#amplicon_meta_file="data/amplicon/_raw/amplicon_metadata.csv"
#if [ -f "$amplicon_meta_file" ] ; then
#  echo "$amplicon_meta_file already downloaded"  
#else
#  echo "Downloading PRJNA237362 metadata > data/amplicon/_raw/amplicon_metadata.csv"
#  esearch -db sra -query PRJNA237362 | \
#   efetch -format runinfo > data/amplicon/_raw/amplicon_metadata.csv &
#fi

## Download rna-seq metadata
#rnaseq_meta_file="data/rnaseq/_raw/PRJNA248469_metadata.csv"
#if [ -f "$rnaseq_meta_file" ] ; then
#  echo "$rnaseq_meta_file already downloaded"
#else
#  echo "Downloading PRJNA248469 metadata > data/rnaseq/_raw/rnaseq_meta.csv"
#  esearch -db sra -query PRJNA248469 | \
#    efetch -format runinfo > data/rnaseq/_raw/rnaseq_meta.csv &
#fi

# Download hg38 reference
hg38_file="data/references/hg38.fa.gz"
if [ -f "$hg38_file" ] ; then
  echo "$hg38_file already downloaded"
else
  wget -P data/references http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz &
fi

# Download bowtie index hg38 and unzip
bowtie_dir="data/references/GRCh38_noalt_as"
if [ -d "$bowtie_dir" ]; then
  echo "$bowtie_dir already downloaded"  
else
  echo "Downloading GRCh38_noalt_as"
  wget -P data/references https://genome-idx.s3.amazonaws.com/bt/GRCh38_noalt_as.zip && \
  echo "unzipping GRCh38_noalt_as.zip" && \
  unzip data/references/GRCh38_noalt_as.zip -d ./data/references && \
  echo "removing GRCh38_noalt_as.zip" && \
  rm data/_raw/GRCh38_noalt_as.zip
fi


# Download silva dada2 indexed database
dada2_index_dir="data/references/silva_nr99_v138.1_train_set"
if [ -d "dada2_index_dir" ]; then
  echo "$dada2_index_dir already downloaded"
else
  echo "Downloading silva_nr99_v138.1_train_set"
  wget -P data/references https://zenodo.org/api/records/4587955/files-archive && \
  echo "unzipping silva_nr99_v138.1_train_set" && \
  unzip data/references/files-archive -d data/references/silva_nr99_v138.1_train_set
fi
