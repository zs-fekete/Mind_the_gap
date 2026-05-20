#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --mem=21G
#SBATCH -t 4-00:00:00
#SBATCH -J genotype_vcf
#SBATCH --output=mind_the_gaps/reports/sbatch/genotype_vcf/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/genotype_vcf/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-19

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

species=$1
asm=$2

echo ${species}
echo ${asm}

bed_list=($(ls data/${species}/bedfiles/${asm}/*.bed))
bed_file=$(echo ${bed_list[$SLURM_ARRAY_TASK_ID]})

run_id=$(basename ${bed_file/.bed//} | cut -d"_" -f2)

ref="mind_the_gaps/data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa"

cd data/${species}/gvcf/${asm}/genomicDB

# Cohort‑level genotyping
gatk --java-options "-Xmx20g" GenotypeGVCFs \
    -R ${ref} \
    -V gendb://range_${run_id} \
    -O cohort_${asm}_${run_id}_raw.vcf.gz