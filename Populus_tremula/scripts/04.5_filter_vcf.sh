#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --mem=20G
#SBATCH -t 1-00:00:00
#SBATCH -J filter_vcf
#SBATCH --output=mind_the_gaps/reports/sbatch/filter_vcf/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/filter_vcf/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

run_list=(draft chrom)
asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})

species=$1

echo ${species}
echo ${asm}

# add a hard filter
gatk VariantFiltration \
    -R data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa \
    -V data/${species}/gvcf/${asm}/cohort.${asm}.raw.vcf.gz \
    --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
    --filter-name "basic_snp_filter" \
    -O data/${species}/gvcf/${asm}/cohort.${asm}.flt.vcf.gz

# Final filtering and retaining only:
# - the encoded filter PASS (previous step)
# - biallelic SNPs 
# - MAF > 0.05 
# - maximum of 80% missing data
bcftools view \
    -m2 \
    -M2 \
    -v snps \
    data/${species}/gvcf/${asm}/cohort.${asm}.flt.vcf.gz | \
vcftools --vcf - \
    --max-missing 0.8 \
    --maf 0.05 \
    --min-alleles 2 \
    --max-alleles 2 \
    --recode \
    --recode-INFO-all \
    --stdout | \
bcftools view -Oz \
    -o data/${species}/gvcf/${asm}/cohort.${asm}.final.recoded.vcf.gz

tabix -p vcf data/${species}/gvcf/${asm}/cohort.${asm}.final.recoded.vcf.gz