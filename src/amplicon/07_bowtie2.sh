#!/bin/bash

input_dir="data/amplicon/trimmed_reads"
output_dir="data/amplicon/bowtie2/"
log_path="logs/amplicon/bowtie2.log"


ls ${input_dir}/*_1.fastq.gz | \
    grep "SRR1210649_trimmed_1.fastq.gz" | \
    parallel 'base=$(basename {}); \
    read1={}; \
    read2=$(echo {} | sed "s/_1/_2/"); \
    st=$(echo {} | sed "s/_1/_singleton/"); \
    out=$(echo {} | sed "s/trimmed_reads/bowtie2/" | sed "s/_trimmed_1.fastq.gz/_bowtie.sam/"); \
    bowtie2 -p 10 -x data/amplicon/_raw/GRCh38_noalt_as \
    -1 $read1 \
    -2 $read2 \
    --very-sensitive-local \
    --un-conc-gz \
    -S  $out\'

#ls ../_raw/*_1.fastq | parallel 'base=$(basename {}); read2=$(echo {} | sed "s/_1/_2/"); trim1=${base%????????}_trimmed_1.fastq; trim2=${base%????????}_trimmed_2.fastq; st=${base%????????}_trimmed_singleton.fastq; bbduk.sh in1={} in2=$read2 out1=$trim1 out2=$trim2 outs=$st threads=10 k=25 kmin=11 ktrim=r qtrim=r trimq=20 minlength=50 overwrite=t ziplevel=6 ref=../adapters/adapters.fa'

# SRR1210649_trimmed_1.fastq.gz
# SRR1210649_trimmed_2.fastq.gz
# SRR1210649_singleton.fastq.gz