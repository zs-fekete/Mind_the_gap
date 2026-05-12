#!/usr/bin/env bash

#SBATCH --job-name=combine_calls
#SBATCH --nodes=1
#SBATCH -n 5
#SBATCH --partition=short
#SBATCH --output=combine_calls.out
#SBATCH --error=combine_calls.error
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

chrom_gcvf_list="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls/chrom_level_2pops_10INDV.gvcfs.list"

draft_gcvf_list="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls/draft_2pops_10INDV.gvcfs.list"

out_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls"


###### COMBINE SAMPLE-LEVEL GVCFs  ######

# Run GATK GVCF combiner for both assemblies:

echo "*** Combining GVCF sample-level files for samples..."

echo "*** ... mapped to chromosome level genome"

gatk CombineGVCFs -R $chrom_genome -V $chrom_gcvf_list -O /tmp/cohort_2pops_10indv.chrom.g.vcf.gz

echo "*** ... mapped to draft genome"

gatk CombineGVCFs -R $draft_genome -V $draft_gcvf_list -O /tmp/cohort_2pops_10indv.draft.g.vcf.gz

echo "*** Finished combining GVCF files"


###### VARIANT GENOTYPING FROM COMBINED GVCFs  ######

#Run GATK genotype caller for both assemblies:

echo "*** Genotyping combined GVCF file for..."

echo "*** ... chromosome level genome"

gatk GenotypeGVCFs -R $chrom_genome -V /tmp/cohort_2pops_10indv.chrom.g.vcf.gz -O /tmp/cohort_2pops_10indv.chrom.raw.vcf.gz

echo "*** ... draft genome"

gatk GenotypeGVCFs -R $draft_genome -V /tmp/cohort_2pops_10indv.draft.g.vcf.gz -O /tmp/cohort_2pops_10indv.draft.raw.vcf.gz


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/* $out_folder

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
