#!/bin/bash

#SBATCH --job-name=mtg_bwaindex
#SBATCH --account=project_2002674
#SBATCH --time=16:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=5
#SBATCH --partition=small
#SBATCH --output=MtG_index_%j.txt
#SBATCH --error=MtG_index_%j.txt
#SBATCH --mail-type=END

#variables
refdir=/scratch/project_2002674/ZSOFIA/Mind_the_Gap/GENOMES/Reference/

#modules
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#Run
for i in $refdir/*genomic.masked.fa; do
    bwa index $i;
done
