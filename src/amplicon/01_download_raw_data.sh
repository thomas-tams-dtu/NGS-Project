#!/bin/bash

input_file="/net/pupil1/home/projects/22126_NGS/projects/group8/data/amplicon/amplicon_acc_list.txt"

# Function to process each line
process_line() {
    # Output folder for downloaded reads
    reads_dir="/net/pupil1/home/projects/22126_NGS/projects/group8/data/amplicon/_raw"

    line="$1"
    echo "Processing line: $line"
    
    # Add your processing logic here
    fasterq-dump -p -O $reads_dir $line
}

# Export the function for parallel to use
export -f process_line

# Use parallel to process lines concurrently
cat "$input_file" | parallel -j4 process_line

