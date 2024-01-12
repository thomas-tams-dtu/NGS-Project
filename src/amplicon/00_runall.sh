# Step 01: Download 16S-rRNA FASTQ raw reads from SRA
( time ./src/preprocess/01_download_raw_data.sh\
 -f data/amplicon/amplicon_acc_list.txt\ 
 -d data/amplicon/_raw\ 
 -t paired ) 2>&1 | tee logs/amplicon/download/download_fastq_time.log

# Step 02: Run FASTQC on raw reads
( time ./src/preprocess/02_fastqc.sh\
  -i data/amplicon/_raw/\
  -o results/amplicon/fastqc/raw/\
  -l logs/rnaseq/fastqc/fastqc_raw.log ) 2>&1 | tee logs/rnaseq/fastqc/fastqc_raw_time.log

