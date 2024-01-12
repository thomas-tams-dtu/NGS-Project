#!/bin/bash

output_dir="/net/pupil1/home/projects/22126_NGS/projects/group8/data/amplicon/fastqc_trimmed"
log_path="../../logs/amplicon/fastqc_trimmed.log"

# Use parallel to process lines concurrently
ls ../../data/amplicon/trimmed_reads/*_1.fastq | parallel fastqc -q -o $output_dir {} > $log_path
ls ../../data/amplicon/trimmed_reads/*_2.fastq | parallel fastqc -q -o $output_dir {} >> $log_path
