#!/usr/bin/env bash

#SBATCH --job-name=merge_bams
#SBATCH --nodes=1
#SBATCH -n 4
#SBATCH --partition=short
#SBATCH --output=merge_bams.out
#SBATCH --error=merge_bams.error
#SBATCH --mem=10GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

sample_file="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/07.Merge-bams/MtG_dataset_sample_list.txt"

chrom_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/07.Merge-bams/Chr-level"

draft_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/07.Merge-bams/Draft"


###### MERGE BAMS PER SAMPLE WITH SAMTOOLS  ######


# File merging with SAMtools:

echo "*** Merge BAMs from the same sample..."


echo "*** ... mapped to chromosome level genome"

cat $sample_file | xargs -n 1 -P 4 sh -c 'samtools merge /tmp/$0.merge.chrom.bam /storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/06.Read-groups/Chr-level/$0*.rg.chrom.bam'


echo "*** ... mapped to draft genome"

cat $sample_file | xargs -n 1 -P 4 sh -c 'samtools merge /tmp/$0.merge.draft.bam /storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/06.Read-groups/Draft/$0*.rg.draft.bam'



# Moving files to permanent storage:

echo "*** Moving files to permanent storage"

mv /tmp/*.chrom.bam $chrom_out

mv /tmp/*.draft.bam $draft_out

mv /tmp/* ./

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
