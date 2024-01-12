#!/bin/bash

output_dir="../../data/amplicon/multiqc/"
log_path="../../logs/amplicon/multiqc_raw.log"

multiqc -o $output_dir --title "Raw reads multiqc" ../../data/amplicon/fastqc_raw/*  > $log_path
