#!/bin/bash

output_dir="/net/pupil1/home/projects/22126_NGS/projects/group8/data/amplicon/fastqc_raw"
log_path="../../logs/amplicon/fastqc_raw.log"

# Use parallel to process lines concurrently
ls ../../data/amplicon/_raw/*.fastq | parallel fastqc -q -o $output_dir {} > $log_path
