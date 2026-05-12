#!/usr/bin/env bash

#SBATCH --job-name=bwa_mapping
#SBATCH --nodes=1
#SBATCH -n 8
#SBATCH --partition=normal
#SBATCH --array=0-23
#SBATCH --output=bwa_mapping.out
#SBATCH --error=bwa_mapping.error
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

reads_folder="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/04.trim"

fastq_list="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/02.Reads/MtG_dataset_fastq_files_list.txt"

out_chr="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/Chr-level"

out_draft="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/Draft"

out_stats="/storage/archive2/groups/evochange/members/inesmiranda/MindTheGap/05.Mapping/qc_flagstat"


# Get file path for job array:

file=(`awk '{print $1}' ${fastq_list}`)


###### TRIMMMED READ MAPPING WITH BWA  ######

# Run BWA mapping using both assemblies:

echo "*** Mapping sample file ${file[$SLURM_ARRAY_TASK_ID]}"

echo "*** ... to chromosome level genome"

bwa mem -M -t 8 $chr_genome $reads_folder/${file[$SLURM_ARRAY_TASK_ID]}_R1.trim.fq.gz $reads_folder/${file[$SLURM_ARRAY_TASK_ID]}_R2.trim.fq.gz | samtools sort -@8 -o /tmp/${file[$SLURM_ARRAY_TASK_ID]}.chrom.bam

echo "*** ... to draft genome"

bwa mem -M -t 8 $draft_genome $reads_folder/${file[$SLURM_ARRAY_TASK_ID]}_R1.trim.fq.gz $reads_folder/${file[$SLURM_ARRAY_TASK_ID]}_R2.trim.fq.gz | samtools sort -@8 -o /tmp/${file[$SLURM_ARRAY_TASK_ID]}.draft.bam

echo "*** Finished mapping sample file ${file[$SLURM_ARRAY_TASK_ID]}"


# Get SAMtools stats on the mapped BAM files:

echo "*** Getting mapping stats for sample file ${file[$SLURM_ARRAY_TASK_ID]}"

echo "*** ... for chromosome level mapping"

samtools flagstat /tmp/${file[$SLURM_ARRAY_TASK_ID]}.chrom.bam > /tmp/${file[$SLURM_ARRAY_TASK_ID]}.chrom.flagstat.txt

echo "*** ... for draft mapping"

samtools flagstat /tmp/${file[$SLURM_ARRAY_TASK_ID]}.draft.bam > /tmp/${file[$SLURM_ARRAY_TASK_ID]}.draft.flagstat.txt

echo "*** Finished stats for sample file ${file[$SLURM_ARRAY_TASK_ID]}"


# Move outputs to permanent storage:

echo "***Moving files to storage folder"

mv /tmp/*.chrom.bam $out_chr

mv /tmp/*.draft.bam $out_draft

mv /tmp/*flagstat.txt $out_stats

mv /tmp/* ./

echo "***Finished moving files to storage"


# Deactivate conda:
conda deactivate
