#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=12G
#SBATCH -t 1-00:00:00
#SBATCH -J concat_vcf
#SBATCH --output=mind_the_gaps/reports/sbatch/concat_vcf/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/concat_vcf/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

species=$1

run_list=(draft chrom)
asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})

echo ${species}
echo ${asm}

# list files
ls data/${species}/gvcf/${asm}/genomicDB/cohort_${asm}_*_raw.vcf.gz | \
    sort -V > data/${species}/gvcf/${asm}/genomicDB/list_vcf_to_concat.txt

# concat vcfs
bcftools concat \
    --threads 4 \
    --file-list data/${species}/gvcf/${asm}/genomicDB/list_vcf_to_concat.txt \
    --write-index \
    -Oz -o data/${species}/gvcf/${asm}/cohort.${asm}.raw.vcf.gz

# Adding a step to write the index with tabix to get `.tbi` index because bcftools writes 
# a `.csi` index which doesn't work with `gatk VariantFiltration` 
tabix \
    -p vcf \
    data/${species}/gvcf/${asm}/cohort.${asm}.raw.vcf.gz