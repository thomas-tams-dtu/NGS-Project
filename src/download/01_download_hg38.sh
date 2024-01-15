#!/bin/bash

# Download amplicon metadata
esearch -db sra -query PRJNA237362 \
 | efetch -format runinfo > data/amplicon/_raw/PRJNA237362_metadata.csv

# Download hg38 reference
#wget -P ./data/references http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz &

# Download bowtie index hg38 and unzip
#wget -P ./data/references https://genome-idx.s3.amazonaws.com/bt/GRCh38_noalt_as.zip && \
#unzip ./data/references/GRCh38_noalt_as.zip -d ./data/references && \
#rm ./data/_raw/GRCh38_noalt_as.zip

