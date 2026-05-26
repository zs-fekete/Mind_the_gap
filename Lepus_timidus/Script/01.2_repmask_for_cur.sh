#!/bin/bash

#SBATCH --job-name=MtG_CurMask
#SBATCH --account=project_2002674
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=16
#SBATCH --partition=small
#SBATCH --mail-type=END

#SBATCH --output=MtG_Curmask_output_%j.txt
#SBATCH --error=MtG_Curmask_error_%j.txt

#Paths and binds
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#Variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Unmasked/

RepeatMasker \
    -pa 16 \
    -xsmall \
    -gff \
    -dir=$refdir \
    -lib=/scratch/project_2002674/zsofia/Mind_the_Gap/00_Data/repeatdb/Lepus-dfam.fa \
    $refdir/mLepTim1.pri.cur.20240427.fasta;
	
#	-libdir="/scratch/project_2002674/zsofia/Mind_the_Gap/00_Data/repeatdb/dfam39_full.7.h5" \
