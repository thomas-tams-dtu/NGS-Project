# Step 01: Download RNA-seq FASTQ raw reads from SRA
( time ./src/preprocess/01_download_raw_data.sh \
  -f data/rnaseq/rnaseq_acc_list_test.txt \
  -d data/rnaseq/_raw/ \
  -t single ) 2>&1 | tee logs/download_time_rnaseq.log

# Step 02: Run FASTQC on raw reads
