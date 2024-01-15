#!/bin/bash

# Define kallisto as path
kallisto="/home/ctools/kallisto/build/src/kallisto"

# Default values for command-line arguments
REFERENCE_TRANSCRIPTOME="data/references/gencode.v45.transcripts.fa.gz"
GENE_ANNOTATION="data/references/gencode.v45.annotation.gtf.gz"
OUTPUT_DIR_ROOT=""
LOG_PATH=""

# Function to show usage
usage() {
    echo "Usage: $0 -f <reference_transcriptome> -a <gene_annotation> -o <output_dir_root> -l <log_path>"
    echo "  -f  Path to the reference transcriptome"
    echo "  -a  Path to the gene annotation file"
    echo "  -o  Root directory for Kallisto index output"
    echo "  -l  Log file path for Kallisto output"
    exit 1
}

# Parse command-line options
while getopts 'f:a:o:l:' flag; do
    case "${flag}" in
        f) REFERENCE_TRANSCRIPTOME=${OPTARG} ;;
        a) GENE_ANNOTATION=${OPTARG} ;;
        o) OUTPUT_DIR_ROOT=${OPTARG} ;;
        l) LOG_PATH=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if all required options are provided
if [ -z "$REFERENCE_TRANSCRIPTOME" ] || [ -z "$GENE_ANNOTATION" ] || [ -z "$OUTPUT_DIR_ROOT" ] || [ -z "$LOG_PATH" ]; then
    usage
fi

# Create Kallisto index (only needs to be done once)
nice -n 19 $kallisto index -i "${OUTPUT_DIR_ROOT}/GRCh38.p13_index" "$REFERENCE_TRANSCRIPTOME" "$GENE_ANNOTATION"
