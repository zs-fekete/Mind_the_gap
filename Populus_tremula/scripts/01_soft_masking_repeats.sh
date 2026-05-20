#!/bin/bash -l

#SBATCH -A hpc2n
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 28
#SBATCH --mem=200G
#SBATCH -t 7-00:00:00
#SBATCH -J masking_repeats
#SBATCH --output=mind_the_gaps/reports/sbatch/masking_repeats/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/masking_repeats/sbatch_R-%x_%j-%a.err
##SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

species=$1
currated_lib=$2
# run_list=(draft chrom)
# asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})
asm="draft"

echo ${asm}
echo ${species}

### The masking of repeats was run in two steps
### 1. First masking using the standard `viridiplantae` database
# -pa parallel threads 
# -species "viridiplantae" repeat library hint (adjust to your clade)
# -xsmall  soft‑mask: convert repeats to lowercase
# -gff  emit annotation for downstream stats
# -dir output directory (writes *.masked.fa)
RepeatMasker \
	-pa 28 \
	-species "viridiplantae" \
	-xsmall \
	-gff \
	-dir data/${species}/assemblies/${asm}/ \
	data/${species}/assemblies/${asm}/${asm}.fa

### rename files produced in round one
mv data/${species}/assemblies/${asm}/${asm}.fa.out.gff data/${species}/assemblies/${asm}/${asm}_round-1.out.gff
mv data/${species}/assemblies/${asm}/${asm}.fa.cat.gz data/${species}/assemblies/${asm}/${asm}_round-1.cat.gz
mv data/${species}/assemblies/${asm}/${asm}.fa.masked data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa
mv data/${species}/assemblies/${asm}/${asm}.fa.out data/${species}/assemblies/${asm}/${asm}_round-1.out
mv data/${species}/assemblies/${asm}/${asm}.fa.tbl data/${species}/assemblies/${asm}/${asm}_round-1.tbl

### 2. Using the masked output from the 1st step masking with a species curated repeat database (`Repeats_Aspen_1.0.fna`). 
### After this step add `round-1` to all output files. 
RepeatMasker \
	-pa 28 \
	-engine ncbi \
	-lib ${currated_lib} \
	-xsmall \
	-gff \
	-dir data/${species}/assemblies/${asm}/ \
	data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa

### rename files produced in round one
mv data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa.out.gff data/${species}/assemblies/${asm}/${asm}_round-2.out.gff
mv data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa.cat.gz data/${species}/assemblies/${asm}/${asm}_round-2.cat.gz
mv data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa.masked data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa
mv data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa.out data/${species}/assemblies/${asm}/${asm}_round-2.out
mv data/${species}/assemblies/${asm}/${asm}_round-1_masked.fa.tbl data/${species}/assemblies/${asm}/${asm}_round-2.tbl
