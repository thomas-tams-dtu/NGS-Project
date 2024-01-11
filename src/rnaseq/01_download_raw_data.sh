#!/usr/bin/env bash

# Accept file with accession numbers and output directory from the command line
acc_list=$1
out_dir=$2

# Download all the raw FASTQ files from SRA in parallel
while read l; do
  echo $l
  fastq-dump --outdir $out_dir "$l"
done <$acc_list | head -n 1
