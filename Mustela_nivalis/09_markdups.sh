#!/usr/bin/env bash

#SBATCH --job-name=markdups
#SBATCH --nodes=1
#SBATCH -n 5
#SBATCH --partition=short
#SBATCH --array=0-9
#SBATCH --output=markdups_%a.out
#SBATCH --error=markdups_%a.error
#SBATCH --mem=20GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

sample_file="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/08.Deduplicate-bams/MtG_dataset_sample_list.txt"

chrom_in="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/07.Merge-bams/Chr-level"

draft_in="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/07.Merge-bams/Draft/"

out_chr="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/08.Deduplicate-bams/Chr-level"

out_draft="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/08.Deduplicate-bams/Draft"

qc_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/08.Deduplicate-bams/qc_dedups"


# Get file path for job array:

file=(`awk '{print $1}' ${sample_file}`)


###### MARK DUPLICATE READS WITH GATK  ######

# Run GATK duplicate marking using both assemblies:

echo "*** Marking duplicates for sample ${file[$SLURM_ARRAY_TASK_ID]}"

echo "*** ... mapped to chromosome level genome"

gatk MarkDuplicates -I $chrom_in/${file[$SLURM_ARRAY_TASK_ID]}.merge.chrom.bam -O /tmp/${file[$SLURM_ARRAY_TASK_ID]}.chrom.dedup.bam -M ${file[$SLURM_ARRAY_TASK_ID]}.chrom.dup.txt

echo "*** ... mapped to draft genome"

gatk MarkDuplicates -I $draft_in/${file[$SLURM_ARRAY_TASK_ID]}.merge.draft.bam -O /tmp/${file[$SLURM_ARRAY_TASK_ID]}.draft.dedup.bam -M ${file[$SLURM_ARRAY_TASK_ID]}.draft.dup.txt

echo "*** Finished duplicate marking for sample ${file[$SLURM_ARRAY_TASK_ID]}"


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/*.chrom.dedup.bam $out_chr

mv /tmp/*.draft.dedup.bam $out_draft

echo "***Finished moving files to storage"


# Index duplicate-marked BAM files:

echo "*** Indexing dedup BAM file for sample ${file[$SLURM_ARRAY_TASK_ID]}"

echo "*** ... mapped to chromosome level genome"

samtools index $out_chr/${file[$SLURM_ARRAY_TASK_ID]}.chrom.dedup.bam

echo "*** ... mapped to draft genome"

samtools index $out_draft/${file[$SLURM_ARRAY_TASK_ID]}.draft.dedup.bam

echo "*** Finished indexing bams for sample ${file[$SLURM_ARRAY_TASK_ID]}"


# Deactivate conda:
conda deactivate
