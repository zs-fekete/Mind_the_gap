#!/bin/bash

#SBATCH --job-name=MtG_Mask
#SBATCH --account=project_2002674
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=16
#SBATCH --partition=small
#SBATCH --mail-type=END

#SBATCH --output=MtG_mask_output_%j.txt
#SBATCH --error=MtG_mask_error_%j.txt

#Paths and binds
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#Variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Unmasked/

for i in LepEur.pri LepEur.draft LepTim.pri LepTim.draft; do
    RepeatMasker \
	-pa 16 \
	-xsmall \
	-gff \
	-dir=$refdir \
        -lib=/scratch/project_2002674/zsofia/Mind_the_Gap/00_Data/repeatdb/Lepus-dfam.fa \
	$refdir/${i}_genomic.unmasked.fa;
done
	
#	-libdir="/scratch/project_2002674/zsofia/Mind_the_Gap/00_Data/repeatdb/dfam39_full.7.h5" \
