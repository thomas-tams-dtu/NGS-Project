#!/usr/bin/env bash

# Diretory containig the FASTQ files
fastq_dir="/home/projects/22126_NGS/projects/group8/data/rnaseq/_raw"

# Directory to store FASTQC reports
fastqc_dir="results/fastqc"

# Directory to store trimmed FASTQ files
export trimmed_dir="data/rnaseq/trimmed"

# Run FASTQC in parallel on raw reads
find "$fastq_dir" -name "*.fastq" | parallel -j 4 "nice -n 19 fastqc {} --outdir $fastqc_dir"

# Function to trim reads
trim_reads() {
  infile=$1
  # Extract filename without extension
  filename=$(basename "$infile" .fastq)
  # Construct the full path for the output file
  outfile="$trimmed_dir/${filename}_trimmed.fastq"
  echo $trimmed_dir
  echo $outfile
  adapter_seq="GATCNGAAGAGCACACGTCTGAACTCCAGTCACGCCAATATCTCGTATGC"

  # Trim read with cutadapt
  nice -n 19 cutadapt -a "$adapter_seq" -o "$outfile" "$infile"
}

# Export the function so that it can be used by parallel
export -f trim_reads

# Trim reads in parallel 
find "$fastq_dir" -name "*.fastq" | parallel -j 4 trim_reads {}

# Run FASTQC again on trimmed files with nice
find "$trimmed_dir" -name "*_trimmed.fastq" | parallel -j 4 "nice -n 19 fastqc {} --outdir $fastqc_dir"