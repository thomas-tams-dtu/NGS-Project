#!/bin/bash

reads1="../../data/amplicon/_raw/SRR1567776_1.fastq"
reads2="../../data/amplicon/_raw/SRR1567776_2.fastq"
trimmed_reads1="../../data/amplicon/trimmed_reads/SRR1567776_trimmed_1.fastq"
trimmed_reads2="../../data/amplicon/trimmed_reads/SRR1567776_trimmed_2.fastq"
trimmed_singletons="../../data/amplicon/trimmed_reads/SRR1567776_trimmed_singleton.fastq"

#bbduk.sh in1=$reads1 in2=$reads2 out1=$trimmed_reads1 out2=$trimmed_reads2 outs=$trimmed_singletons


trimmed_dir="../../data/amplicon/trimmed_reads"
cd $trimmed_dir

ls ../_raw/*_1.fastq.gz | parallel 'base=$(basename {}); read2=$(echo {} | sed "s/_1/_2/"); trim1=${base%???????????}_trimmed_1.fastq.gz; trim2=${base%???????????}_trimmed_2.fastq.gz; st=${base%???????????}_trimmed_singleton.fastq.gz; bbduk.sh -Xmx4g in1={} in2=$read2 out1=$trim1 out2=$trim2 outs=$st threads=10 k=25 kmin=11 ktrim=r qtrim=r trimq=20 minlength=50 overwrite=t ziplevel=6 ref=../adapters/adapters.fa tbo'

#threads=10 k=25 kmin=11 ktrim=r qtrim=r trimq=20 minlength=50 overwrite=t ziplevel=6 ref=../adapters/adapters.fa"
