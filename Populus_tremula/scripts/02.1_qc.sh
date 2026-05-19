#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=20G
#SBATCH -t 1-00:00:00
#SBATCH -J qc
#SBATCH --output=mind_the_gaps/reports/sbatch/qc/sbatch_R-%x_%j.out
#SBATCH --error=mind_the_gaps/reports/sbatch/qc/sbatch_R-%x_%j.err

species=$1
echo ${species}

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

fastqc -t 8 data/${species}/reads/raw/*.fq.gz -o data/${species}/qc/fastqc

multiqc data/${species}/qc/fastqc -o data/${species}/qc