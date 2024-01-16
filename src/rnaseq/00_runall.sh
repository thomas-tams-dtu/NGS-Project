########## Step 01: Download RNA-seq FASTQ raw reads from SRA ##########
( time bash src/preprocess/01_download_raw_fastq.sh \
-f data/rnaseq/rnaseq_acc_list_3.txt \
-d data/rnaseq/_raw/ \
-t single \
-l logs/rnaseq/download/fastq-dump.log ) 2>&1 | tee logs/rnaseq/download/download_fastq_time.log

########## Step 02: Trim reads with BBDduk ##########
( time bash src/preprocess/02_bbduk_trim.sh \
-r data/rnaseq/_raw/ \
-t data/rnaseq/trimmed/ \
-a data/adapters/adapters.fa \
-T single \
-l logs/rnaseq/trim/bbduk.log \
-p 10 ) 2>&1 | tee logs/rnaseq/trim/trim_bbduk_time.log

########## Step 03a: Run FASTQC on raw reads ##########
( time bash src/preprocess/03_fastqc.sh \
-i data/rnaseq/_raw/ \
-o results/rnaseq/fastqc/raw/ \
-l logs/rnaseq/fastqc/fastqc_raw.log ) 2>&1 | tee logs/rnaseq/fastqc/fastqc_raw_time.log

########## Step 03b: Run FASTQC on trimmed reads ##########
( time bash src/preprocess/03_fastqc.sh \
-i data/rnaseq/trimmed/ \
-o results/rnaseq/fastqc/trimmed/ \
-l logs/rnaseq/fastqc/fastqc_trimmed.log ) 2>&1 | tee logs/rnaseq/fastqc/fastqc_trimmed_time.log

########## Step 04a: Run multiQC on raw reads ##########
( time bash src/preprocess/04_multiqc.sh \
-o results/rnaseq/multiqc/raw \
-l logs/rnaseq/multiqc/multiqc_raw.log \
-i results/rnaseq/fastqc/raw/ \
-t "Raw reads multiqc") 2>&1 | tee logs/rnaseq/multiqc/multiqc_raw_time.log

########## Step 04b: Run multiQC on trimmed reads ##########
( time bash src/preprocess/04_multiqc.sh \
-o results/rnaseq/multiqc/trimmed \
-l logs/rnaseq/multiqc/multiqc_trimmed.log \
-i results/rnaseq/fastqc/trimmed/ \
-t "Trimmed reads multiqc") 2>&1 | tee logs/rnaseq/multiqc/multiqc_trimmed_time.log

########## Step 05: Generate kallisto index ##########
( time bash src/rnaseq/05_kallisto_index.sh \
-f data/references/gencode.v45.transcripts.fa.gz \
-o data/rnaseq/kallisto/ \
-l logs/rnaseq/kallisto/kallisto_index.log) 2>&1 | tee logs/rnaseq/kallisto/kallisto_index_time.log

########## Step 06: Perform pseudo-alignment using kallisto ##########
( time bash src/rnaseq/06_kallisto_alignment.sh \
-r data/rnaseq/trimmed \
-o data/rnaseq/kallisto \
-t 10 \
-l logs/rnaseq/kallisto/kallisto_quant.log) 2>&1 | tee logs/rnaseq/kallisto/kallisto_quant_time.log




