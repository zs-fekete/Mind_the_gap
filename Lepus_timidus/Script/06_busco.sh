#!/bin/bash

#SBATCH --job-name=MtG_ReBusco
#SBATCH --account=project_2002674
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=50G
#SBATCH --cpus-per-task=4
#SBATCH --partition=small
#SBATCH --mail-type=END

#SBATCH --output=MtG_Rebusco_output_%j.txt
#SBATCH --error=MtG_Rebusco_error_%j.txt

#Paths and binds
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#Variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Reference/
#../GENOMES/Reference/mLepTim1.pri.cur_genomic.masked.fa
i="mLepTim1.pri.cur"
busco \
	-i $refdir/${i}_genomic.masked.fa \
	-l glires_odb12 \
	-m genome \
	-c 4 \
	-f \
	--out_path /scratch/project_2002674/zsofia/Mind_the_Gap/06_Busco/glires12 \
	-o $i

: '
busco \
	-i $refdir/${i}_genomic.masked.fa \
	-l mammalia_odb10 \
	-m genome \
	-c 4 \
	-f \
	--out_path /scratch/project_2002674/zsofia/Mind_the_Gap/06_Busco/mamm10 \
	-o $i 

busco \
	-i $refdir/${i}_genomic.masked.fa \
	-l glires_odb10 \
	-m genome \
	-c 4 \
	-f \
	--out_path /scratch/project_2002674/zsofia/Mind_the_Gap/06_Busco/glires10 \
	-o $i 
'
