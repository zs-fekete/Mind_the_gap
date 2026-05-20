#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --mem=10G
#SBATCH -t 1-00:00:00
#SBATCH -J vcftools_stats
#SBATCH --output=mind_the_gaps/reports/sbatch/vcftools_stats/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/vcftools_stats/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

run_list=(draft chrom)
asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})

species=$1

echo ${species}
echo ${asm}

# Nucleotide diversity (π)
vcftools --gzvcf data/${species}/gvcf/${asm}/cohort.${asm}.final.recoded.vcf.gz \
     	--site-pi \
     	--out data/${species}/stats/${asm}/pi_${asm}

# Observed heterozygosity
vcftools --gzvcf data/${species}/gvcf/${asm}/cohort.${asm}.final.recoded.vcf.gz \
     	--het \
     	--out data/${species}/stats/${asm}/het_${asm}

# Pairwise FST (two example populations)
vcftools --gzvcf data/${species}/gvcf/${asm}/cohort.${asm}.final.recoded.vcf.gz \
     	--weir-fst-pop data/${species}/pop1.txt \
     	--weir-fst-pop data/${species}/pop2.txt \
     	--out data/${species}/stats/${asm}/fst_${asm}