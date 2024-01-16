for file in *_1_trimmed_*.fastq.gz; do
  mv "$file" "$(echo "$file" | sed 's/_1_trimmed_/_trimmed_/')"
done
