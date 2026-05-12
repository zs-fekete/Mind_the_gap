#!/usr/bin/env bash

#SBATCH --job-name=repeatmasker_draft_mustelidae
#SBATCH --nodes=1
#SBATCH -n 16
#SBATCH --partition=normal
#SBATCH --output=repeatmasker_draft_mustelidae.out
#SBATCH --error=repeatmasker_draft_mustelidae.error
#SBATCH --mem=25GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

draft_genome="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/00.Reference-genomes/Draft/GCA_019141155.1_MusNiv_Pri1.0_genomic.fna"

out_draft="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Draft/mustelidae"


###### REPEAT MASKING FOR DRAFT GENOME ######

echo "***Running Repeat Masker for the draft genome"

RepeatMasker -pa 16 -species mustelidae -xsmall -gff -dir /tmp $draft_genome

echo "***Finished Repeat Masker run"


# Move outputs to permanent storage:

echo "Moving files to storage folder"

mv /tmp/* $out_draft

echo "Finished moving files to storage"


# Deactivate conda:
conda deactivate
