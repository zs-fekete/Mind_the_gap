#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 2
#SBATCH --mem=200G
##SBATCH -C zen4
#SBATCH -t 2-00:00:00
#SBATCH -J busco
#SBATCH --output=mind_the_gaps/reports/sbatch/busco/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/busco/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

run_list=(draft chrom)
asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})
species=$1

echo ${species}
echo ${asm}

busco -i  data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa \
  --mode genome \
  -f \
  --cpu 2 \
  --lineage_dataset mind_the_gaps/data/busco_db/viridiplantae_odb12 \
  -o data/${species}/annotation/busco/${asm}/${asm}_busco
