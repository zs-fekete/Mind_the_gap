#!/usr/bin/env bash

#SBATCH --job-name=popstats_vcftools
#SBATCH --nodes=1
#SBATCH -n 3
#SBATCH --partition=short
#SBATCH --output=popstats_vcftools.out
#SBATCH --error=popstats_vcftools.error
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

out_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/10.Population-genomics/stats-2pops-10indv"

prune_chrom="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/10.Population-genomics/pca-2pops-10indv/pruned_2pops_10indv_chrom.prune.in"

prune_draft="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/10.Population-genomics/pca-2pops-10indv/pruned_2pops_10indv_draft.prune.in"

Fin_list="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/10.Population-genomics/stats-2pops-10indv/MtG_Finland_sample_list.txt"

Swi_list="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/10.Population-genomics/stats-2pops-10indv/MtG_Switzerland_sample_list.txt"


###### FIX VCF FILE TO INCLUDE SNP IDS ######

echo "*** Fixing VCF files to include SNP IDs..."


# Chr-level VCF file:

echo "*** ... for chromosome-level VCF"

bcftools query -f '%CHROM %POS\n' $in_folder/$dataset.chrom.final.recode.vcf.gz > $in_folder/$dataset.chrom.final.recode.snps

awk '{print $1"\t"$2"\t"$1":"$2}' $in_folder/$dataset.chrom.final.recode.snps > $in_folder/$dataset.chrom.final.recode.snps.tab

bgzip $in_folder/$dataset.chrom.final.recode.snps.tab

tabix -f -s1 -b2 -e2 $in_folder/$dataset.chrom.final.recode.snps.tab.gz

bcftools annotate -a $in_folder/$dataset.chrom.final.recode.snps.tab.gz -c CHROM,POS,ID -Oz -o $in_folder/$dataset.chrom.final.recode.ano.vcf.gz $in_folder/$dataset.chrom.final.recode.vcf.gz


# Draft genome VCF file:

echo "*** ... for draft VCF"

bcftools query -f '%CHROM %POS\n' $in_folder/$dataset.draft.final.recode.vcf.gz > $in_folder/$dataset.draft.final.recode.snps

awk '{print $1"\t"$2"\t"$1":"$2}' $in_folder/$dataset.draft.final.recode.snps > $in_folder/$dataset.draft.final.recode.snps.tab

bgzip $in_folder/$dataset.draft.final.recode.snps.tab

tabix -f -s1 -b2 -e2 $in_folder/$dataset.draft.final.recode.snps.tab.gz

bcftools annotate -a $in_folder/$dataset.draft.final.recode.snps.tab.gz -c CHROM,POS,ID -Oz -o $in_folder/$dataset.draft.final.recode.ano.vcf.gz $in_folder/$dataset.draft.final.recode.vcf.gz


###### POPULATION GENOMICS STATISTICS  ######

# Calculating genomic stats - with VCFtools:


# Chr-level VCF file:

echo "*** Calculating population genomic stats for chromosome-level VCF..."

echo "*** ... Nucleotide diversity"

vcftools --gzvcf $in_folder/$dataset.chrom.final.recode.ano.vcf.gz --snps $prune_chrom --site-pi --out $out_folder/pi_2pops_10indv_chrom

echo "*** ... Heterozygosity"

vcftools --gzvcf $in_folder/$dataset.chrom.final.recode.ano.vcf.gz --snps $prune_chrom --het --out $out_folder/het_2pops_10indv_chrom

echo "*** ... Pairwise Fst"

vcftools --gzvcf $in_folder/$dataset.chrom.final.recode.ano.vcf.gz --snps $prune_chrom --weir-fst-pop $Fin_list --weir-fst-pop $Swi_list --out $out_folder/fst_2pops_10indv_chrom

echo "*** Finished population genomic stats for chromosome-level VCF"


# Draft genome VCF file:

echo "*** Calculating population genomic stats for draft genome VCF ..."

echo "*** ... Nucleotide diversity"

vcftools --gzvcf $in_folder/$dataset.draft.final.recode.ano.vcf.gz --snps $prune_draft --site-pi --out $out_folder/pi_2pops_10indv_draft

echo "*** ... Heterozygosity"

vcftools --gzvcf $in_folder/$dataset.draft.final.recode.ano.vcf.gz --snps $prune_draft --het --out $out_folder/het_2pops_10indv_draft

echo "*** ... Pairwise Fst"

vcftools --gzvcf $in_folder/$dataset.draft.final.recode.ano.vcf.gz --snps $prune_draft --weir-fst-pop $Fin_list --weir-fst-pop $Swi_list --out $out_folder/fst_2pops_10indv_draft

echo "*** Finished population genomic stats for draft genome VCF"


# Deactivate conda:
conda deactivate
