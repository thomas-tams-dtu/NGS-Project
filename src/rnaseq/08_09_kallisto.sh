#!/bin/bash

# Define kallisto as path
kallisto="/home/ctools/kallisto/build/src/kallisto"

# Define path to the reference transcriptome
REFERENCE_TRANSCRIPTOME="/home/projects/22126_NGS/projects/group8/data/references/GRCh38_latest_rna.fna.gz"

# Create Kallisto index (only needs to be done once)
kallisto index -i /home/projects/22126_NGS/projects/group8/data/references/kallisto_human_index.idx $REFERENCE_TRANSCRIPTOME

# Directory containing your read files
READ_DIR="/home/projects/22126_NGS/projects/group8/data/rnaseq/trimmed"

# Create an array of all fastq.gz files in the specified directory
READ_FILES=($(ls $READ_DIR/*.fastq.gz))

# Loop over the array and run Kallisto quant for each file
for READ_FILE in "${READ_FILES[@]}"
do
    # Extract the base name of the file for output directory
    BASE_NAME=$(basename $READ_FILE .fastq.gz)
    OUTPUT_DIR="home/projects/22126_NGS/projects/group8/data/rnaseq/kallisto/output_dir_${BASE_NAME}"

    # Create the output directory if it doesn't exist
    mkdir -p $OUTPUT_DIR

    # Run Kallisto quant
    kallisto quant -i /home/projects/22126_NGS/projects/group8/data/references/kallisto_human_index.idx -o $OUTPUT_DIR --single -l 50 -s 5 $READ_FILE
    # Note: -l and -s are the estimated average fragment length and standard deviation, respectively.
    # Adjust these values based on your experimental setup.
done
