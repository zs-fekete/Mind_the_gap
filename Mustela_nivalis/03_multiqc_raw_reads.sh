#!/usr/bin/env bash

#SBATCH --job-name=multiqc_raw_reads
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --partition=short
#SBATCH --output=multiqc_raw_reads.out
#SBATCH --error=multiqc_raw_reads.error
#SBATCH --mem=10GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

in_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/03.QC/fastqc"

out_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/03.QC"


###### RAW-READ QUALITY ASSESSMENT WITH FASTQC  ######

echo "***Running MultiQC for summarising FastQC results"

multiqc $in_folder -o /tmp

echo "***Finished MultiQC run"


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/* $out_folder

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
