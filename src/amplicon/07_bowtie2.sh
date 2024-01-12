#!/bin/bash

# Variables
input_dir="data/amplicon/trimmed_reads"
output_dir="data/amplicon/bowtie2/"
log_path="logs/amplicon/bowtie2.log"

# Loop through all trimmed reads
ls ${input_dir}/*_1.fastq.gz | \
    parallel 'base=$(basename {}); \
    read1={}; \
    read2=$(echo {} | sed "s/_1/_2/"); \
    st=$(echo {} | sed "s/_1/_singleton/"); \
    out=$(echo {} | sed "s/trimmed_reads/bowtie2/" | sed "s/_trimmed_1.fastq.gz/_host_removed/"); \
    out_sam=$(echo {} | sed "s/trimmed_reads/bowtie2/" | sed "s/_trimmed_1.fastq.gz/_mapped_and_unmapped.sam/"); \
    nice -19 bowtie2 -p 10 -x data/references/GRCh38_noalt_as/GRCh38_noalt_as \
    -1 $read1 \
    -2 $read2 \
    --very-sensitive-local \
    --un-conc-gz $out \
    > $out_sam'

# Rename host_removed files to .fasta.gz
host_removed_files=($(ls data/amplicon/bowtie2/*_host_removed.1))
nice -19 for file in "${host_removed_files[@]}"
do
    # Move forward
    new_name_1=$(echo $file | sed 's/_host_removed.1/_host_removed_1.fastq.gz/')
    mv "$file" "$new_name_1"

    # Move reverse
    file_2=$(echo $file | sed 's/removed.1/removed.2/')
    new_name_2=$(echo $file_2 | sed 's/_host_removed.2/_host_removed_2.fastq.gz/')
    mv "$file_2" "$new_name_2"
done

# Sam to bam
sam_files=($(ls data/amplicon/bowtie2/*.sam))
nice -19 for sam_name in "${sam_files[@]}"
do
    bam_name=$(echo $sam_name | sed 's/.sam/.bam/')
    samtools view --threads 10 -bS $sam_name > $bam_name
done

# Remove the sam files
sleep 2
nice -19 rm data/amplicon/bowtie2/*.sam