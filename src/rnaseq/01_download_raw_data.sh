#!/usr/bin/env bash

# Accept file with accession numbers and output directory from the command line
# input_file=$1
# reads_dir=$2

# File containing list of accession numbers
input_file="/home/projects/22126_NGS/projects/group8/data/rnaseq/rnaseq_acc_list.txt"

# Function to process each line
process_line() {
    # Output folder for downloaded reads
    reads_dir="/home/projects/22126_NGS/projects/group8/data/rnaseq/_raw"

    line="$1"
    echo "Processing line: $line"
    
    # Download reads with fasterq-dump
    nice -n 19 fasterq-dump -p -e 1 -O "$reads_dir" "$line"

    # Gzip the downloaded files and remove the original
    for file in "${reads_dir}/${line}"*.fastq; do
        echo "Compressing and removing original file: $file"
        gzip -f "$file"
    done
}

# Export the function for parallel to use
export -f process_line

# Use parallel to process lines concurrently
cat "$input_file" | parallel -j 4 process_line
