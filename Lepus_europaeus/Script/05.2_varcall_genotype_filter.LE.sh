#!/bin/bash

#SBATCH --job-name=mtg_vargen
#SBATCH --account=project_2002674
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=8
#SBATCH --partition=small
#SBATCH --output=MtG_LEgt_out_%j.txt
#SBATCH --error=MtG_LEgt_err_%j.txt
#SBATCH --mail-type=END

#modules
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Reference/
indir=/scratch/project_2002674/zsofia/Mind_the_Gap/02_Align/
vardir=/scratch/project_2002674/zsofia/Mind_the_Gap/03_Varcall/
gendir=/scratch/project_2002674/zsofia/Mind_the_Gap/04_Genotype/

#Ref: LepEur.${i}_genomic.masked.fa
#Run
#LE
for g in pri draft; do
    ref=$refdir/LepEur.${g}_genomic.masked.fa
    
    while read sample_id; do
      	bamf=$indir/${sample_id}.LepEur_${g}.bam
	
      	gatk --java-options '-Xmx8G' HaplotypeCaller \
      	     -R $ref \
      	     -I $bamf \
      	     -ERC GVCF \
      	     -O $vardir/${sample_id}.LepEur_${g}.g.vcf.gz

    done < LE_select.list

    ls $vardir/*LepEur_${g}*gz > LE_select.vcf.list
    sed -i 's/^/-V /' LE_select.vcf.list

    gatk --java-options '-Xmx8G' CombineGVCFs -R $ref \
     	 --arguments_file LE_select.vcf.list \
     	 -O $gendir/combined.LepEur_${g}.g.vcf.gz

    gatk --java-options '-Xmx8G' GenotypeGVCFs \
	 -R $ref \
	 -V $gendir/combined.LepEur_${g}.g.vcf.gz \
	 -O $gendir/genotyped.LepEur_${g}.vcf.gz
    
    gatk --java-options '-Xmx8G' VariantFiltration \
	 -R $ref \
	 -V $gendir/genotyped.LepEur_${g}.vcf.gz \
	 --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
	 --filter-name "basic_snp_filter" \
	 -O $gendir/filtered.LepEur_${g}.vcf.gz
    
    bcftools view -f PASS -m2 -M2 -v snps $gendir/filtered.LepEur_${g}.vcf.gz | \
	vcftools --vcf - \
		 --max-missing 0.8 \
		 --maf 0.05 \
		 --min-alleles 2 --max-alleles 2 \
		 --recode --recode-INFO-all --stdout | \
	bgzip -c > $gendir/final.LepEur_${g}.vcf.gz
    tabix -p vcf $gendir/final.LepEur_${g}.vcf.gz

done
