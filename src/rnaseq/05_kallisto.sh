#!/bin/bash

# Define kallisto as path
kallisto="/home/ctools/kallisto/build/src/kallisto"

# Default values for command-line arguments
REFERENCE_TRANSCRIPTOME="data/references/GRCh38_latest_rna.fna.gz"
READ_DIR=""
OUTPUT_DIR_ROOT=""
LOG_PATH=""
NUM_THREADS=4  # Default number of threads

# Function to show usage
usage() {
    echo "Usage: $0 -f <reference_transcriptome> -r <read_dir> -o <output_dir_root> -l <log_path> -t <num_threads>"
    echo "  -f  Path to the reference transcriptome"
    echo "  -r  Directory containing trimmed read files"
    echo "  -o  Root directory for Kallisto output"
    echo "  -l  Log file path for Kallisto output"
    echo "  -t  Number of threads for Kallisto (default: 4)"
    exit 1
}

# Parse command-line options
while getopts 'f:r:o:l:t:' flag; do
    case "${flag}" in
        f) REFERENCE_TRANSCRIPTOME=${OPTARG} ;;
        r) READ_DIR=${OPTARG} ;;
        o) OUTPUT_DIR_ROOT=${OPTARG} ;;
        l) LOG_PATH=${OPTARG} ;;
        t) NUM_THREADS=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if all required options are provided
if [ -z "$REFERENCE_TRANSCRIPTOME" ] || [ -z "$READ_DIR" ] || [ -z "$OUTPUT_DIR_ROOT" ] || [ -z "$LOG_PATH" ]; then
    usage
fi

# Create Kallisto index (only needs to be done once)
$kallisto index -i "${OUTPUT_DIR_ROOT}/kallisto_human_index.idx" "$REFERENCE_TRANSCRIPTOME"

# Export variables for use in the exported function
export OUTPUT_DIR_ROOT NUM_THREADS kallisto


# Kallisto quant command function
kallisto_quant() {
    local read_file=$1
    local base_name=$(basename "$read_file" .fastq.gz)
    local output_dir="${OUTPUT_DIR_ROOT}/$(echo $base_name | sed "s/_trimmed//" )"

    # Create the output directory if it doesn't exist
    mkdir -p "$output_dir"

    # Run Kallisto quant and redirect output to log file
    $kallisto quant -i "${OUTPUT_DIR_ROOT}/kallisto_human_index.idx" -o "$output_dir" --single -l 200 -s 20 -t "$NUM_THREADS" "$read_file"
}

# Export the function for parallel to use
export -f kallisto_quant

# Find all fastq.gz files and run them in parallel
find "$READ_DIR" -name '*.fastq.gz' | parallel -j "$NUM_THREADS" kallisto_quant {} 2>&1 | tee -a "$LOG_PATH"