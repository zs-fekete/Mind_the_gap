#!/bin/bash

#SBATCH --job-name=mtg_bwalign
#SBATCH --account=project_2002674
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=16
#SBATCH --partition=small
#SBATCH --output=MtG_align_out_%j.txt
#SBATCH --error=MtG_align_err_%j.txt
#SBATCH --mail-type=END

#modules
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#variables
#refdir=/scratch/project_2002674/zsofia/Hybrid_rerun/GENOMES/
reffa=/scratch/project_2002674/zsofia/Hybrid_rerun/GENOMES/mLepEur1.pri_genomic.fa
datadir=/scratch/project_2002674/zsofia/Mind_the_Gap/08_Restacks/fastq/
outdir=/scratch/project_2002674/zsofia/Mind_the_Gap/02_Align/ALL/

#Run
#LE
#for g in pri draft; do
while read sample_id; do
    fq1=$datadir/${sample_id}.1.fq.gz
    fq2=$datadir/${sample_id}.2.fq.gz
    
    name=$(basename $fq1 | sed 's/.1.fq.gz//')
    flowcell=$(zcat $fq1 | head -n 1 | cut -d ':' -f3)
    lane=$(zcat $fq1 | head -n 1 | cut -d ':' -f4) 
    echo "${name}, ${flowcell}, ${lane}"
    
    bwa mem -M -t 16 -R "@RG\tID:${sample_id}\tSM:${sample_id}\tPL:illumina" $reffa $fq1 $fq2 |\
	samtools sort -@8 -o $outdir/${sample_id}.LepEur.bam
    samtools flagstat $outdir/${sample_id}.LepEur.bam > $outdir/${sample_id}.LepEur.flagstat.txt
	
done < fin_radseq.list
#done
    
#LT
'/// for g in pri draft; do
    while read sample_id; do
	fq1=$datadir/${sample_id}.1.fq.gz
	fq2=$datadir/${sample_id}.2.fq.gz
	
	name=$(basename $fq1 | sed 's/.1.fq.gz//')
	flowcell=$(zcat $fq1 | head -n 1 | cut -d ':' -f3)
	lane=$(zcat $fq1 | head -n 1 | cut -d ':' -f4) 
	echo "${name}, ${flowcell}, ${lane}"

	bwa mem -M -t 16 -R "@RG\tID:${sample_id}\tSM:${sample_id}\tPL:illumina" $refdir/LepTim.${g}_genomic.masked.fa $fq1 $fq2 |\
	    samtools sort -@8 -o $outdir/${sample_id}.LepTim_${g}.bam
	samtools flagstat $outdir/${sample_id}.LepTim_${g}.bam > $outdir/${sample_id}.LepTim_${g}.flagstat.txt
    done < LT_select.list
done
///'
