# Step 01: Download RNA-seq FASTQ raw reads from SRA
./src/preprocess/01_download_raw_data.sh \
  -f /home/projects/22126_NGS/projects/group8/mikkel/NGS-Project/data/rnaseq/rnaseq_acc_list.txt \
  -d data/rnaseq/_raw/ \
  -t single


# Step 02: Run FASTQC on raw reads
