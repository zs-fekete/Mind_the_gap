#!/usr/bin/env bash

#SBATCH --job-name=fastp_raw_reads
#SBATCH --nodes=1
#SBATCH -n 3
#SBATCH --partition=short
#SBATCH --output=fastp_raw_reads.out
#SBATCH --error=fastp_raw_reads.error
#SBATCH --mem=10GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

reads_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/02.Reads"

fastq_list="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/02.Reads/MtG_dataset_fastq_files_list.txt"

out_folder1="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/04.trim"

out_folder2="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/04.trim/qc_reports"


# Get file path for job array:

file=(`awk '{print $1}' ${fastq_list}`)


###### RAW READS ADAPTER AND QUALITY TRIMMING WITH FASTP  ######

echo "***Running fastp analysis for the complete dataset"

echo "*** Trimming sample file ${file[$SLURM_ARRAY_TASK_ID]}"

fastp -i $reads_folder/${file[$SLURM_ARRAY_TASK_ID]}_1.fq.gz -I $reads_folder/${file[$SLURM_ARRAY_TASK_ID]}_2.fq.gz -o /tmp/${file[$SLURM_ARRAY_TASK_ID]}_R1.trim.fq.gz -O /tmp/${file[$SLURM_ARRAY_TASK_ID]}_R2.trim.fq.gz -q 20 -u 30 -l 50 -g -h /tmp/${file[$SLURM_ARRAY_TASK_ID]}.fastp.html -j /tmp/${file[$SLURM_ARRAY_TASK_ID]}.fastp.json

echo "***Finished fastp run"


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/*fq.gz $out_folder1

mv /tmp/*html $out_folder2

mv /tmp/*json $out_folder2

mv /tmp/* ./

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
