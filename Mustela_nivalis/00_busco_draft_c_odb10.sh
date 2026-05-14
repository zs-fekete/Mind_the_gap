#!/usr/bin/env bash

#SBATCH --job-name=busco_draft_m_odb10
#SBATCH --nodes=1
#SBATCH -n 8
#SBATCH --partition=short
#SBATCH --output=busco_draft_c_odb10.out
#SBATCH --error=busco_draft_c_odb10.error
#SBATCH --mem=50GB

# The script starts below this line
# —----------------------------------------------------
# Activate the conda environment inside the batch file


## Activate conda environment:
CUR_SHELL=shell.$(basename -- "${SHELL}")
eval "$(conda "$CUR_SHELL" hook)"
conda activate chromcomp


# Run Busco:

echo "***Running BUSCO for the draft genome"

busco -i /storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/00.Reference-genomes/Draft/GCA_019141155.1_MusNiv_Pri1.0_genomic.fna -l carnivora_odb10 -m geno -o draft_assembly_carnivora_odb10 -c 8 --out_path /tmp

echo "***Finished BUSCO run"


# Move outputs to permanent storage:

echo "Moving output to storage"

mv /tmp/* /storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/00.Reference-genomes/Draft/busco

echo "Moving output completed"

# Deactivate conda:
conda deactivate
