#!/bin/bash

#SBATCH --job-name=MtG_Busco
#SBATCH --account=project_2002674
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=50G
#SBATCH --cpus-per-task=4
#SBATCH --partition=small
#SBATCH --mail-type=END

#SBATCH --output=MtG_busco_output_%j.txt
#SBATCH --error=MtG_busco_error_%j.txt

#Paths and binds
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#Variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Reference/

for i in $refdir/*genomic.masked.fa; do
    busco \
	-i $refdir/${i}_genomic.masked.fa \
	-l glires_odb12 \
	-m genome \
	-c 4 \
	-f \
	--out_path /scratch/project_2002674/zsofia/Mind_the_Gap/07_Busco/glires12 \
	-o $i
done
