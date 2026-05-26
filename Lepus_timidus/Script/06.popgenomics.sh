#!/bin/bash

#SBATCH --job-name=mtg_popgen
#SBATCH --account=project_2002674
#SBATCH --time=15:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=2
#SBATCH --partition=test
#SBATCH --output=MtG_Testpop_out_%j.txt
#SBATCH --error=MtG_Testpop_err_%j.txt
#SBATCH --mail-type=END

#modules
export PATH="/projappl/project_2002674/chromcomp_env//bin:$PATH"

#variables
refdir=/scratch/project_2002674/zsofia/Mind_the_Gap/GENOMES/Reference/
gendir=/scratch/project_2002674/zsofia/Mind_the_Gap/04_Genotype/
outdir=/scratch/project_2002674/zsofia/Mind_the_Gap/05_asm_stats/

if [ ! -d $outdir ]; then
    mkdir -p $outdir;
fi

#../04_Genotype/final.LepTim_draft.vcf.gz
for i in LepTim_draft LepTim_pri LepEur_draft LepEur_pri; do
    
    plink2 --vcf $gendir/final.$i.vcf \
	   --indep-pairwise 50 10 0.2 \
	   --out $outdir/pruned_$ref \
	   --allow-extra-chr
    plink2 --vcf $gendir/final.$i.vcf \
	   --pca 20 \
	   --out $outdir/pca_$ref \
	   --allow-extra-chr

    # vcftools --gzvcf $i \
    # 	     --site-pi \
    # 	     --out $outdir/pi_$ref
    # vcftools --gzvcf $i \
    # 	     --het \
    # 	     --out $outdir/het_$ref;
done
