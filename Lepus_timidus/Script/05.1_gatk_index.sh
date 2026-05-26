#!/bin/bash

#SBATCH --job-name=mtg_gatkindex
#SBATCH --account=project_2002674
#SBATCH --time=15:00
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=4
#SBATCH --partition=test
#SBATCH --output=MtG_gatkindex_out_%j.txt
#SBATCH --error=MtG_gatkindex_err_%j.txt
#SBATCH --mail-type=END

#variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Reference/

#modules
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#Run
for i in $refdir/*genomic.masked.fa; do
    gatk CreateSequenceDictionary --java-options "-Xmx8G" -R $i;
done
