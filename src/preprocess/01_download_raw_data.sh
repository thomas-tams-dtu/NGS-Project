#!/usr/bin/env bash

# Default values
input_file=""
reads_dir=""
read_type=""

# Function to show usage
usage() {
    echo "Usage: $0 -f <input_file> -d <reads_dir> -t <read_type>"
    echo "  -f  File containing list of accession numbers"
    echo "  -d  Directory for downloaded reads"
    echo "  -t  Type of reads (single or paired)"
    exit 1
}

# Parse command-line options
while getopts 'f:d:t:' flag; do
    case "${flag}" in
        f) input_file=${OPTARG} ;;
        d) reads_dir=${OPTARG} ;;
        t) read_type=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if all options are provided
if [ -z "$input_file" ] || [ -z "$reads_dir" ] || [ -z "$read_type" ]; then
    usage
fi

# Check if the read type is valid
if [ "$read_type" != "single" ] && [ "$read_type" != "paired" ]; then
    echo "Error: Read type must be either 'single' or 'paired'"
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$reads_dir"

# Function to process each line
process_line() {
    line="$1"
    echo "Processing line: $line"

    # Check if the read type is paired and set the appropriate fastq-dump flags
    if [ "$read_type" == "paired" ]; then
        fastq_dump_options="--split-files"
    else
        fastq_dump_options=""
    fi

    # Download reads with fastq-dump and gzip the output
    nice -n 19 fastq-dump $fastq_dump_options --gzip -O "$reads_dir" "$line"
}

# Export the function for parallel to use
export -f process_line

# Use parallel to process lines concurrently
cat "$input_file" | parallel -j 4 process_line
