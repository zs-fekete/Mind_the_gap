#!/bin/bash -l

#SBATCH -A hpc2n	
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --mem=8G
#SBATCH -t 1-00:00:00
#SBATCH -J haplocall
#SBATCH --output=mind_the_gaps/reports/sbatch/haplocall/sbatch_R-%x_%j-%a.out
#SBATCH --error=mind_the_gaps/reports/sbatch/haplocall/sbatch_R-%x_%j-%a.err
#SBATCH -a 0-19

eval "$(mamba shell hook --shell bash)"
mamba activate chromcomp

cd mind_the_gaps

species=$1
asm=$2
sample_id=$3

echo ${species}
echo ${asm}
echo ${sample_id}

bed_list=($(ls data/${species}/bedfiles/${asm}/*.bed))
bed_file=$(echo ${bed_list[$SLURM_ARRAY_TASK_ID]})

run_id=$(basename ${bed_file/.bed//} | cut -d"_" -f2)

# HaplotypeCaller per sample (GVCF mode)
gatk --java-options "-Xmx7g" HaplotypeCaller \
  -I data/${species}/bam/${asm}/${sample_id}.${asm}.dedup.bam \
  -R data/${species}/assemblies/${asm}/${asm}_round-2_masked.fa \
  --emit-ref-confidence GVCF \
  -L ${bed_file} \
  -O data/${species}/gvcf/${asm}/sample_calls/${sample_id}_${asm}_${run_id}.g.vcf.gz
