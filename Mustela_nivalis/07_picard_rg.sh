#!/usr/bin/env bash

#SBATCH --job-name=picard_rg
#SBATCH --nodes=1
#SBATCH -n 4
#SBATCH --partition=normal
#SBATCH --output=picard_rg.out
#SBATCH --error=picard_rg.error
#SBATCH --mem=10GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

chrom_in="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/Chr-level"

draft_in="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/Draft"

chrom_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/06.Read-groups/Chr-level"

draft_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/06.Read-groups/Draft"

rg_file="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/06.Read-groups/MtG_dataset_fastq_files_samples_flowcell_lane.txt"


###### ADD READ GROUPS WITH PICARD  ######

# Run Picard for RG assignment:

echo "*** Add read groups to sample files..."


echo "*** ... mapped to chromosome level genome"

cat $rg_file | xargs -n 4 -P 4 sh -c 'picard AddOrReplaceReadGroups -I /storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/Chr-level/$0.chrom.bam -O /tmp/$0.rg.chrom.bam --RGID $1-$2-L$3 --RGLB $1-lib1 --RGPL illumina --RGSM $1 --RGPU $2-L$3'


echo "*** ... mapped to draft genome"

cat $rg_file | xargs -n 4 -P 2 sh -c 'picard AddOrReplaceReadGroups -I /storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/Draft/$0.draft.bam -O /tmp/$0.rg.draft.bam --RGID $1-$2-L$3 --RGLB $1-lib1 --RGPL illumina --RGSM $1 --RGPU $2-L$3' 



# Moving files to permanent storage:

echo "*** Moving files to permanent storage"

mv /tmp/*.chrom.bam $chrom_out

mv /tmp/*.draft.bam $draft_out

mv /tmp/* ./

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
