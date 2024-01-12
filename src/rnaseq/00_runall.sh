# Step 01: Download RNA-seq FASTQ raw reads from SRA
( time ./src/preprocess/01_download_raw_data.sh\
 -f data/rnaseq/rnaseq_acc_list.txt\ 
 -d data/rnaseq/_raw/\ 
 -t single ) 2>&1 | tee logs/rnaseq/download/download_fastq_time.log

# Step 02: Run FASTQC on raw reads
( time ./src/preprocess/02_fastqc.sh\
  -i data/rnaseq/_raw/\
  -o results/rnaseq/fastqc/raw/\
  -l logs/rnaseq/fastqc/fastqc_raw.log ) 2>&1 | tee logs/rnaseq/fastqc/fastqc_raw_time.log

# Step 03: Trim reads with BBDduk
