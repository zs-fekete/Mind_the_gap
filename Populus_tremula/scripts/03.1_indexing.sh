#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -J indexing
#SBATCH --output=mind_the_gaps/reports/sbatch/indexing/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/indexing/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

species=$1

run_list=(draft chrom)
asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})

echo ${species}
echo ${asm}

# Build FM‑index for BWA MEM (necessary once per assembly).
bwa index data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa

# Generate FASTA index (.fai) so downstream tools know chromosome lengths.
samtools faidx data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa

# Create a sequence dictionary (.dict) required by GATK.
gatk CreateSequenceDictionary -R data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa
