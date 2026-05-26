#!/bin/bash

#SBATCH --job-name=mtg_vargen
#SBATCH --account=project_2002674
#SBATCH --time=4:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=8
#SBATCH --partition=small
#SBATCH --output=MtG_LTgt_out_%j.txt
#SBATCH --error=MtG_LTgt_err_%j.txt
#SBATCH --mail-type=END

#modules
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Reference/
indir=/scratch/project_2002674/zsofia/Mind_the_Gap/02_Align/
vardir=/scratch/project_2002674/zsofia/Mind_the_Gap/03_Varcall/
gendir=/scratch/project_2002674/zsofia/Mind_the_Gap/04_Genotype/

#Ref: LepTim.${i}_genomic.masked.fa
#Run
#LT
for g in pri draft; do
    ref=$refdir/LepTim.${g}_genomic.masked.fa
    
    # while read sample_id; do
    # 	bamf=$indir/${sample_id}.LepTim_${g}.bam
	
    # 	gatk --java-options '-Xmx8G' HaplotypeCaller \
    # 	     -R $ref \
    # 	     -I $bamf \
    # 	     -ERC GVCF \
    # 	     -O $vardir/${sample_id}.LepTim_${g}.g.vcf.gz

    # done < LT_select.list

    # ls $vardir/*LepTim_${g}*gz > LT_select.vcf.list
    # sed -i 's/^/-V /' LT_select.vcf.list

    # gatk --java-options '-Xmx8G' CombineGVCFs -R $ref \
    # 	     --arguments_file $gendir/LT_select.vcf.list \
    # 	     -O combined.LepTim_${g}.g.vcf.gz

    gatk --java-options '-Xmx8G' GenotypeGVCFs \
	 -R $ref \
	 -V $gendir/combined.LepTim_${g}.g.vcf.gz \
	 -O $gendir/genotyped.LepTim_${g}.vcf.gz
    
    gatk --java-options '-Xmx8G' VariantFiltration \
	 -R $ref \
	 -V $gendir/genotyped.LepTim_${g}.vcf.gz \
	 --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
	 --filter-name "basic_snp_filter" \
	 -O $gendir/filtered.LepTim_${g}.vcf.gz

    bcftools view -f PASS -m2 -M2 -v snps $gendir/filtered.LepTim_${g}.vcf.gz | \
	vcftools --vcf - \
		 --max-missing 0.8 \
		 --maf 0.05 \
		 --min-alleles 2 --max-alleles 2 \
		 --recode --recode-INFO-all --stdout | \
	bgzip -c > $gendir/final.LepTim_${g}.vcf.gz
    tabix -p vcf $gendir/final.LepTim_${g}.vcf.gz

done
