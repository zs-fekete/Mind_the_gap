#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=50G
#SBATCH -t 1-00:00:00
#SBATCH -J mappig
#SBATCH --output=mind_the_gaps/reports/sbatch/mapping/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/mapping/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-1

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

run_list=(draft chrom)
asm=$(echo ${run_list[$SLURM_ARRAY_TASK_ID]})

species=$1
sample_id=$2

echo ${asm}
echo ${species}
echo ${sample_id}

# Extract metadata (flowcell ID, lane) for read‑group tags; 
# helps when multiple libraries per sample need merging or when checking platform‑specific biases.
name=${sample_id} 
flowcell=$(zcat data/${species}/reads/trimmed/${sample_id}_R1.trim.fq.gz | head -n 1 | cut -d ':' -f3) 
lane=$(zcat data/${species}/reads/trimmed/${sample_id}_R1.trim.fq.gz | head -n 1 | cut -d ':' -f4) 

# Align and sort 
echo "MAPPING WITH BWA MEM"
bwa mem -M -t 8 \
  -R "@RG\tID:${sample_id}\tSM:${sample_id}\tPL:NovaSeq\tPI:269" \
  data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa \
  data/${species}/reads/trimmed/${sample_id}_R1.trim.fq.gz \
  data/${species}/reads/trimmed/${sample_id}_R2.trim.fq.gz |  \
samtools sort -@8 -o data/${species}/bam/${asm}/${sample_id}.${asm}.bam


# Basic alignment QC (flagstat) for later analysis.
echo "SAMTOOLS FLAGSTATS"
samtools flagstat -O tsv data/${species}/bam/${asm}/${sample_id}.${asm}.bam > data/${species}/qc/flagstat/${sample_id}.${asm}.flagstat.txt

# Duplicate marking & mapping
echo "GATK MARK DUPLICATES"
gatk MarkDuplicates \
  -I data/${species}/bam/${asm}/${sample_id}.${asm}.bam \
  -O data/${species}/bam/${asm}/${sample_id}.${asm}.dedup.bam \
  -M data/${species}/qc/dedup/${sample_id}.${asm}.dup.txt

# Lastly, index the bam file
echo "INDEX"
samtools index data/${species}/bam/${asm}/${sample_id}.${asm}.dedup.bam