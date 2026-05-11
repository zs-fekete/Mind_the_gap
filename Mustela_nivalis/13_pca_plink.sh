#!/usr/bin/env bash

#SBATCH --job-name=pca_plink
#SBATCH --nodes=1
#SBATCH -n 3
#SBATCH --partition=short
#SBATCH --output=pca_plink.out
#SBATCH --error=pca_plink.error
#SBATCH --mem=20GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

dataset="cohort_2pops_10indv"

in_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls"

out_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/10.Population-genomics/pca-2pops-10indv/"


###### LD-PRUNNING SNPs WITH PLINK ######

echo "*** Prunning SNPs for LD..."


# Chr-level VCF file:

echo "*** ... for chromosome-level VCF"

plink2 --vcf $in_folder/$dataset.chrom.final.recode.vcf.gz --indep-pairwise 50 10 0.2 --out $out_folder/pruned_2pops_10indv_chrom --allow-extra-chr --bad-ld --set-all-var-ids @:#


# Draft genome VCF file:

echo "*** ... for draft VCF"

plink2 --vcf $in_folder/$dataset.draft.final.recode.vcf.gz --indep-pairwise 50 10 0.2 --out $out_folder/pruned_2pops_10indv_draft --allow-extra-chr --bad-ld --set-all-var-ids @:#


## NOTE: running the PCA analyis resulted in the following error:
## Error: This run requires decent allele frequencies, but they aren't being loaded with --read-freq, and less than 50 samples are available to impute them from.
## You should generate (with --freq) or obtain an allele frequency file based on a larger similar-population reference dataset, and load it with --read-freq.
##
## Therefore, added a step to calculate allele frequencies with Plink2.


###### CALCULATING ALLELE FREQUENCIES WITH PLINK ######

echo "*** Calculating allele frequencies..."


# Chr-level VCF file:

echo "*** ... for chromosome-level VCF"

plink2 --vcf $in_folder/$dataset.chrom.final.recode.vcf.gz --allow-extra-chr --set-all-var-ids @:# --extract $out_folder/pruned_2pops_10indv_chrom.prune.in --freq --out $out_folder/freq_2pops_10indv_chrom


# Draft genome VCF file:

echo "*** ... for draft VCF"

plink2 --vcf $in_folder/$dataset.draft.final.recode.vcf.gz --allow-extra-chr --set-all-var-ids @:# --extract $out_folder/pruned_2pops_10indv_draft.prune.in --freq --out $out_folder/freq_2pops_10indv_draft


###### RUNNING PCA WITH PLINK ######

echo "*** Running PCA..."


# Chr-level VCF file:

echo "*** ... for chromosome-level VCF"

plink2 --vcf $in_folder/$dataset.chrom.final.recode.vcf.gz --extract $out_folder/pruned_2pops_10indv_chrom.prune.in --pca 10 --allow-extra-chr --set-all-var-ids @:# --read-freq $out_folder/freq_2pops_10indv_chrom.afreq --out $out_folder/pca_2pops_10indv_chrom


# Draft genome VCF file:

echo "*** ... for draft VCF"

plink2 --vcf $in_folder/$dataset.draft.final.recode.vcf.gz --extract $out_folder/pruned_2pops_10indv_draft.prune.in --pca 10 --allow-extra-chr --set-all-var-ids @:# --read-freq $out_folder/freq_2pops_10indv_draft.afreq --out $out_folder/pca_2pops_10indv_draft


# Deactivate conda:
conda deactivate
