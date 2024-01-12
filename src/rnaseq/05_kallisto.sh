#!/bin/bash

# Define kallisto as path
kallisto="/home/ctools/kallisto/build/src/kallisto"

# Default values for command-line arguments
REFERENCE_TRANSCRIPTOME="data/references/GRCh38_latest_rna.fna.gz"
READ_DIR=""
OUTPUT_DIR_ROOT=""
NUM_THREADS=4  # Default number of threads

# Function to show usage
usage() {
    echo "Usage: $0 -f <reference_transcriptome> -r <read_dir> -o <output_dir_root> -t <num_threads>"
    echo "  -f  Path to the reference transcriptome"
    echo "  -r  Directory containing trimmed read files"
    echo "  -o  Root directory for Kallisto output"
    echo "  -t  Number of threads for Kallisto (default: 4)"
    exit 1
}

# Parse command-line options
while getopts 'f:r:o:t:' flag; do
    case "${flag}" in
        f) REFERENCE_TRANSCRIPTOME=${OPTARG} ;;
        r) READ_DIR=${OPTARG} ;;
        o) OUTPUT_DIR_ROOT=${OPTARG} ;;
        t) NUM_THREADS=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if all required options are provided
if [ -z "$REFERENCE_TRANSCRIPTOME" ] || [ -z "$READ_DIR" ] || [ -z "$OUTPUT_DIR_ROOT" ]; then
    usage
fi

# Create Kallisto index (only needs to be done once)
$kallisto index -i "${OUTPUT_DIR_ROOT}/kallisto_human_index.idx" "$REFERENCE_TRANSCRIPTOME"

# Export variables for use in the exported function
export OUTPUT_DIR_ROOT kallisto

# Kallisto quant command function
kallisto_quant() {
    local read_file=$1
    local base_name=$(basename "$read_file" .fastq.gz)
    local output_dir="${OUTPUT_DIR_ROOT}/${base_name}"

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Run Kallisto quant
    nice -n 19 $kallisto quant -i "${OUTPUT_DIR_ROOT}/kallisto_human_index.idx" -o "$output_dir" -b 100 --single -l 50 -s 5 -t "$NUM_THREADS" "$read_file"
}

# Export the function for parallel to use
export -f kallisto_quant

# Find all fastq.gz files and run them in parallel
find "$READ_DIR" -name '*.fastq.gz' | parallel -j "$NUM_THREADS" kallisto_quant {}
