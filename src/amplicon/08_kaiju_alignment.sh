#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 -i input_dir -o output_dir -l log_path -t n_threads"
  echo "  -i  Input directory containing trimmed and un-contaminated fowards and reverse reads"
  echo "  -o  Output directory for Kaiju results"
  echo "  -l  File path to log file output"
  echo "  -t  Number of threads per parallel instance"
  exit 1
}

# Parse command-line options
while getopts ":i:o:l:t:" opt; do
  case $opt in
    i) reads_dir="$OPTARG";;
    o) out_dir="$OPTARG";;
    l) log_path="$OPTARG";;
    t) threads="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG" >&2; usage;;
    :) echo "Option -$OPTARG requires an argument." >&2; usage;;
  esac
done

# Check if required options are provided
if [[ -z "$reads_dir" || -z "$out_dir" || -z "$log_path" || -z "$threads" ]]; then
  usage
fi

# Export variables for use in the exported function
export reads_dir out_dir index_file threads

# Create the trimmed directory if it doesn't exist
mkdir -p "$out_dir"

# Create or clear the log file
mkdir -p $(dirname "$log_path") # Ensure the log directory exists
: > "$log_path"

# Kaiju alignment and OTU generation function
run_kaiju() {
  read1=$1
  read2=$(echo $read1 | sed "s/_1/_2/")
  base=$(basename $1)
  out=$(echo ${out_dir}${base} | sed "s/_host_removed_1.fastq.gz/_db_nr_euk.kaiju/")
  #echo $read1
  #echo $read2
  #echo $base
  #echo $out
  kaiju -i $read1 -j $read2 -t /home/databases/databases/Kaiju/kaiju_db_nr_euk_nodes.dmp \
  -f /home/databases/databases/Kaiju/kaiju_db_nr_euk.fmi -v -z $threads -a greedy -o $out
}

# Export run_kaiju function for parallel runs
export -f run_kaiju

#kaiju -i $read1 -j $read2 -t /home/databases/databases/Kaiju/kaiju_db_nr_euk_nodes.dmp \
#-f /home/databases/databases/Kaiju/kaiju_db_nr_euk.fmi -v -z $threads -a mem -o SRR7610114_db_nr_euk.kaiju


# Loop parallelize kaiju across all reads in reads_dir
ls ${reads_dir}*_1.fastq.gz | \
  head -n 10 | \
  parallel -j 1 run_kaiju
#2>&1 | tee -a $log_path
