#!/usr/bin/env bash

#SBATCH --job-name=repeatmasker_chr_mustelidae
#SBATCH --nodes=1
#SBATCH -n 16
#SBATCH --partition=normal
#SBATCH --output=repeatmasker_chr_mustelidae.out
#SBATCH --error=repeatmasker_chr_mustelidae.error
#SBATCH --mem=25GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

chr_genome="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/00.Reference-genomes/Chr-level/GCA_964662115.1_mMusNiv2.hap1.1_genomic.fna"

out_chr="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Chr-level/mustelidae"


###### REPEAT MASKING FOR CHR LEVEL GENOME ######

echo "***Running Repeat Masker for the chromossome level genome"

RepeatMasker -pa 16 -species mustelidae -xsmall -gff -dir /tmp $chr_genome

echo "***Finished Repeat Masker run"


# Move outputs to permanent storage:

echo "Moving files to storage folder"

mv /tmp/* $out_chr

echo "Finished moving files to storage"


# Deactivate conda:
conda deactivate
