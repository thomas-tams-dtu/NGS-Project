import pandas as pd
import os

def create_count_matrix(read_dir):
    for subdir, dirs, files in os.walk(read_dir):
        for file in files:
            if file.endswith("abundance.tsv"):
                file_path = os.path.join(subdir, file)
                df = pd.read_csv(file_path, sep='\t')
                count_matrix = df[['target_id', 'est_counts']]
                count_matrix.to_csv(os.path.join(subdir, 'count_matrix.csv'), index=False)

# Call the function with your directory containing Kallisto output folders
create_count_matrix('/home/projects/22126_NGS/projects/group8/data/rnaseq/kallisto')
