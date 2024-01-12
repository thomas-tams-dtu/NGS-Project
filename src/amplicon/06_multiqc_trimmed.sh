#!/bin/bash

output_dir="../../data/amplicon/multiqc/"
log_path="../../logs/amplicon/multiqc_trimmed.log"

multiqc -o $output_dir --title "Trimmed reads multiqc" ../../data/amplicon/fastqc_trimmed/*  > $log_path
