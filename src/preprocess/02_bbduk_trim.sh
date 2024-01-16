#!/usr/bin/env bash

# Default values
reads_dir=""
trimmed_dir=""
adapters_path=""
read_type=""
log_path=""
threads=10
k=25
kmin=11
ktrim="r"
qtrim="r"
trimq=20
minlength=50
overwrite="t"
ziplevel=6

# Function to show usage
usage() {
    echo "Usage: $0 -r <reads_dir> -t <trimmed_dir> -a <adapters_path> -T <read_type> -l <log_path> [-p <threads> -k <k> -K <kmin> -R <ktrim> -Q <qtrim> -q <trimq> -m <minlength> -o <overwrite> -z <ziplevel>]"
    echo "  -r  Directory containing raw FASTQ files"
    echo "  -t  Directory to store trimmed reads"
    echo "  -a  Path to adapters file"
    echo "  -T  Type of reads (single or paired)"
    echo "  -l  Path to save the log file"
    echo "  -p  Number of threads (default 10)"
    # Include other options in the usage message
    exit 1
}

# Parse command-line options
while getopts 'r:t:a:T:l:p:k:K:R:Q:q:m:o:z:' flag; do
    case "${flag}" in
        r) reads_dir=${OPTARG} ;;
        t) trimmed_dir=${OPTARG} ;;
        a) adapters_path=${OPTARG} ;;
        T) read_type=${OPTARG} ;;
        l) log_path=${OPTARG} ;;
        p) threads=${OPTARG} ;;
        # Include other options here
        *) usage ;;
    esac
done

# Check if required options are provided
if [ -z "$reads_dir" ] || [ -z "$trimmed_dir" ] || [ -z "$adapters_path" ] || [ -z "$read_type" ] || [ -z "$log_path" ]; then
    usage
fi

# Check if the read type is valid
if [ "$read_type" != "single" ] && [ "$read_type" != "paired" ]; then
    echo "Error: Read type must be either 'single' or 'paired'"
    exit 1
fi


# Export variables for use in the exported function
export reads_dir trimmed_dir adapters_path read_type threads k kmin ktrim qtrim trimq minlength overwrite ziplevel

# Create the trimmed directory if it doesn't exist
mkdir -p "$trimmed_dir"

# Create or clear the log file
mkdir -p $(dirname "$log_path") # Ensure the log directory exists
: > "$log_path"

# Parallel command for trimming
trim_command() {
    base=$(basename $1)
    if [ "$read_type" == "paired" ]; then
        read2=$(echo $1 | sed "s/_1/_2/")
        trim1=$(echo $base | sed "s/.fastq.gz//")_trimmed_1.fastq.gz
        trim2=$(echo $base | sed "s/.fastq.gz//")_trimmed_2.fastq.gz
        st=$(echo $base | sed "s/.fastq.gz//")_trimmed_singleton.fastq.gz
        nice -n 19 bbduk.sh -Xmx4g in1=$1 in2=$read2 out1="$trimmed_dir"$trim1 out2="$trimmed_dir"$trim2 outs="$trimmed_dir"$st threads=$threads k=$k kmin=$kmin ktrim=$ktrim qtrim=$qtrim trimq=$trimq minlength=$minlength overwrite=$overwrite ziplevel=$ziplevel ref=$adapters_path tbo tpe
    else
        trim1=$(echo $base | sed "s/.fastq.gz//")_trimmed.fastq.gz
        nice -n 19 bbduk.sh -Xmx4g in1=$1 out1="$trimmed_dir"$trim1 threads=$threads k=$k kmin=$kmin ktrim=$ktrim qtrim=$qtrim trimq=$trimq minlength=$minlength overwrite=$overwrite ziplevel=$ziplevel ref=$adapters_path
    fi
}

export -f trim_command

# Run the trimming process and log the output
if [ "$read_type" == "paired" ]; then
    ls "$reads_dir"*_1.fastq.gz | \
    head -n 2 | \
    parallel -j $threads trim_command 2>&1 | tee -a "$log_path"

    # Rename files if run for paired reads
    paired_end_reads=($(ls ${trimmed_dir}*_1_trimmed_*.fastq.gz))
    for file in "${paired_end_reads[@]}"; do
        mv "$file" "$(echo "$file" | sed 's/_1_trimmed_/_trimmed_/')"
    done
else
    ls "$reads_dir"*.fastq.gz | parallel -j $threads trim_command 2>&1 | tee -a "$log_path"
fi

