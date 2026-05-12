#!/usr/bin/env bash

#SBATCH --job-name=gvcf_calls
#SBATCH --nodes=1
#SBATCH -n 5
#SBATCH --partition=normal
#SBATCH --array=0-9
#SBATCH --output=gvcf_calls_%a.out
#SBATCH --error=gvcf_calls_%a.error
#SBATCH --mem=20GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

chrom_genome="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Chr-level/mustelidae/GCA_964662115.1_mMusNiv2.hap1.1_genomic.fna.masked.fa"

draft_genome="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Draft/mustelidae/GCA_019141155.1_MusNiv_Pri1.0_genomic.fna.masked.fa"

chrom_in="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/08.Deduplicate-bams/Chr-level"

draft_in="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/08.Deduplicate-bams/Draft"

chrom_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls/gvcf_chrom_lvel"

draft_out="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls/gvcf_draft"

sample_file="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls/MtG_dataset_sample_list.txt"


# Get file path for job array:

file=(`awk '{print $1}' ${sample_file}`)


###### HAPLOTYPE CALLING PER SAMPLE  ######

# Run GATK haplotype caller using both assemblies:

echo "*** Haplotype calling for sample ${file[$SLURM_ARRAY_TASK_ID]}"

echo "*** ... mapped to chromosome level genome"

gatk HaplotypeCaller -R $chrom_genome -I $chrom_in/${file[$SLURM_ARRAY_TASK_ID]}.chrom.dedup.bam -ERC GVCF -O /tmp/${file[$SLURM_ARRAY_TASK_ID]}.chrom.g.vcf.gz

echo "*** ... mapped to draft genome"

gatk HaplotypeCaller -R $draft_genome -I $draft_in/${file[$SLURM_ARRAY_TASK_ID]}.draft.dedup.bam -ERC GVCF -O /tmp/${file[$SLURM_ARRAY_TASK_ID]}.draft.g.vcf.gz

echo "*** Finished haplotype calling for sample ${file[$SLURM_ARRAY_TASK_ID]}"


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/*.chrom.g.vcf.gz $chrom_out

mv /tmp/*.draft.g.vcf.gz $draft_out

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
