#!/usr/bin/env bash

#SBATCH --job-name=fastqc_raw_reads
#SBATCH --nodes=1
#SBATCH -n 8
#SBATCH --partition=short
#SBATCH --output=fastqc_raw_reads.out
#SBATCH --error=fastqc_raw_reads.error
#SBATCH --mem=10GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

reads_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/02.Reads/"

out_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/03.QC/fastqc"


###### RAW-READ QUALITY ASSESSMENT WITH FASTQC  ######

echo "***Running FastQC analysis for the complete dataset"

fastqc -t 8 $reads_folder/*.fq.gz -o /tmp

echo "***Finished FastQC run"


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/* $out_folder

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
