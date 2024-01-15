#!/bin/bash

# Define kallisto as path
kallisto="/home/ctools/kallisto/build/src/kallisto"

# Default values for command-line arguments
READ_DIR=""
OUTPUT_DIR_ROOT=""
LOG_PATH=""

# Function to show usage
usage() {
    echo "Usage: $0 -r <read_dir> -o <output_dir_root> -l <log_path>"
    echo "  -r  Directory containing trimmed read files"
    echo "  -o  Root directory for Kallisto output"
    echo "  -l  Log file path for Kallisto output"
    exit 1
}

# Parse command-line options
while getopts 'r:o:l:' flag; do
    case "${flag}" in
        r) READ_DIR=${OPTARG} ;;
        o) OUTPUT_DIR_ROOT=${OPTARG} ;;
        l) LOG_PATH=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if all required options are provided
if 
  [ -z "$READ_DIR" ] || [ -z "$OUTPUT_DIR_ROOT" ] || [ -z "$LOG_PATH" ]; then
  usage
fi

mkdir mapped
#dir="rawdata/F23A490000016_HOMfpvqR/CleanData"

# Define location of sample reads
FOLDERS=($(find "$READ_DIR" -type d))
FOLDERS=("${FOLDERS[@]:1}") # First element is just the $dir
echo $FOLDERS
# # Loop through the sample folders
# for folder in "${FOLDERS[@]}"
# do
#     # Find all files in the current folder and sort them
#     FILES=($(find "$folder" -type f | sort))

#     # Run Kallisto for all files in the current folder
#     if (( ${#FILES[@]} )); then # only run kallisto if there are files in the folder
#         BASENAME=$(basename "$folder")
#         base_name=$(basename "$folder" .fastq.gz)
#         output_dir="${folder}/$(echo $base_name | sed "s/_trimmed//" )"
#         echo "${FILES[@]}"
#         nice -n 19 $kallisto quant -i "${OUTPUT_DIR_ROOT}/GRCh38.p13_index" -o mapped/"$BASENAME" --single -l 200 -s 20 "${FILES[@]}"
#     fi
# done