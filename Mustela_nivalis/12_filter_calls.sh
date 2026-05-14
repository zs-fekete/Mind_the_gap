#!/usr/bin/env bash

#SBATCH --job-name=filter_calls
#SBATCH --nodes=1
#SBATCH -n 5
#SBATCH --partition=short
#SBATCH --output=filter_calls.out
#SBATCH --error=filter_calls.error
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

data_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/09.Variant_calls"


###### HARD-FILTERING VCF CALLS  ######

# Basic SNP filtering based on INFO fields - with GATK:

echo "*** Filtering VCFs for basic SNP filter..."

echo "*** ... for chromosome level genome VCF"

gatk VariantFiltration -R $chrom_genome -V $data_folder/cohort_2pops_10indv.chrom.raw.vcf.gz --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" --filter-name "basic_snp_filter" -O /tmp/cohort_2pops_10indv.chrom.flt.vcf.gz

echo "*** ... for draft genome VCF"

gatk VariantFiltration -R $draft_genome -V $data_folder/cohort_2pops_10indv.draft.raw.vcf.gz --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" --filter-name "basic_snp_filter" -O /tmp/cohort_2pops_10indv.draft.flt.vcf.gz

echo "*** Finished first filtering step for VCFs"


# Population level filtering for biallelic SNPs - with BCFtools/VCFtools:

echo "*** Filtering VCFs at population level ..."

echo "*** ... for chromosome level genome VCF"

bcftools view -f PASS -m2 -M2 -v snps /tmp/cohort_2pops_10indv.chrom.flt.vcf.gz | vcftools --vcf - --max-missing 0.8 --maf 0.05 --min-alleles 2 --max-alleles 2 --recode --recode-INFO-all --out /tmp/cohort_2pops_10indv.chrom.final

bgzip -c /tmp/cohort_2pops_10indv.chrom.final.recode.vcf > /tmp/cohort_2pops_10indv.chrom.final.recode.vcf.gz

echo "*** ... for draft genome VCF"

bcftools view -f PASS -m2 -M2 -v snps /tmp/cohort_2pops_10indv.draft.flt.vcf.gz | vcftools --vcf - --max-missing 0.8 --maf 0.05 --min-alleles 2 --max-alleles 2 --recode --recode-INFO-all --out /tmp/cohort_2pops_10indv.draft.final

bgzip -c /tmp/cohort_2pops_10indv.draft.final.recode.vcf > /tmp/cohort_2pops_10indv.draft.final.recode.vcf.gz

echo "*** Finished second filtering step for VCFs"


# Move outputs to permanent storage:

echo "*** Moving files to storage folder"

mv /tmp/* $data_folder

echo "*** Finished moving files to storage"


# Deactivate conda:
conda deactivate
