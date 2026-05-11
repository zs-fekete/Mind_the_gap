#!/usr/bin/env bash

#SBATCH --job-name=index_genomes
#SBATCH --nodes=1
#SBATCH -n 1
#SBATCH --partition=short
#SBATCH --output=index_genomes.out
#SBATCH --error=index_genomes.error
#SBATCH --mem=10GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp

# Define variables:

chr_genome="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Chr-level/mustelidae/GCA_964662115.1_mMusNiv2.hap1.1_genomic.fna.masked"

draft_genome="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Draft/mustelidae/GCA_019141155.1_MusNiv_Pri1.0_genomic.fna.masked"

out_chr="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Chr-level/mustelidae/"

out_draft="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/01.Reference-masking/Draft/mustelidae/"


######## BWA INDEXING ########


echo "***Running BWA indexing..."

echo "*** ... for chromosome level genome"

bwa index $chr_genome

echo "*** ... for draft genome"

bwa index $draft_genome

echo "***Finished BWA indexing"



######## SAMTOOLS INDEXING ########


echo "***Running SAMtools indexing..."

echo "*** ... for chromosome level genome"

samtools faidx $chr_genome

echo "*** ... for draft genome"

samtools faidx $draft_genome

echo "***Finished SAMtools indexing"



######## GATK DICTIONARY ########


echo "***Running GATK dictionary..."

echo "*** ... for chromosome level genome"

gatk CreateSequenceDictionary -R $chr_genome

echo "*** ... for draft genome"

gatk CreateSequenceDictionary -R $draft_genome

echo "***Finished GATK dictionary"


# Deactivate conda:
conda deactivate
