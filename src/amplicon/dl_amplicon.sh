#!/bin/bash

# File containing list of accession numbers
input_file="/net/pupil1/home/projects/22126_NGS/projects/group8/data/amplicon/amplicon_acc_list.txt"

# Output folder for downloaded reads
reads_dir='/net/pupil1/home/projects/22126_NGS/projects/group8/data/amplicon/_raw'

# Make sure the output directory exists
mkdir -p "$reads_dir"

# Read the file line by line and process each line
while IFS= read -r line; do
    # Use the line as an argument in your command
    echo fasterq-dump -O "$reads_dir" "$line"
done < "$input_file"
