CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate chromcomp

###
#ASSEMBLY='formica_2022'
ASSEMBLY='formica_draft'

mkdir stats
mkdir stats/${ASSEMBLY}


#### Population‑genomic statistics

# Principal component analysis step A - LD‑prune at r² < 0.2, 50 kb windows, sliding 10 variants
# plink2 \
# 	--vcf cohort.${ASSEMBLY}.final.recode.vcf.gz \
# 	--indep-pairwise 50 10 0.2 \
# 	--out pruned_${ASSEMBLY}

# Principal component analysis step B - PCA on the pruned SNP subset
# plink2 \
# 	--vcf cohort.${ASSEMBLY}.final.recode.vcf.gz  \
# 	--extract pruned_${ASSEMBLY}.prune.in \
# 	--pca 10 \
# 	--allow-extra-chr  \
# 	--out pca_${ASSEMBLY}
	
plink2 \
	--vcf cohort.${ASSEMBLY}.final.recode.vcf.gz \
	--allow-extra-chr \
	--set-all-var-ids @:#:\$r:\$a \
	--make-pgen \
	--out cohort_${ASSEMBLY}_fixed_ids

plink2 \
	--pfile cohort_${ASSEMBLY}_fixed_ids \
	--allow-extra-chr \
	--bad-ld \
	--indep-pairwise 50 10 0.2 \
	--out pruned_${ASSEMBLY}

plink2 \
	--pfile cohort_${ASSEMBLY}_fixed_ids \
	--allow-extra-chr \
	--freq \
	--out cohort_${ASSEMBLY}_freq

plink2 \
	--pfile cohort_${ASSEMBLY}_fixed_ids \
	--extract pruned_${ASSEMBLY}.prune.in \
	--read-freq cohort_${ASSEMBLY}_freq.afreq \
	--allow-extra-chr \
	--pca 10 \
	--out pca_${ASSEMBLY}
	
# create files with chromosome ID and SNP positions:
awk -F ':' '{print $1"\t"$2}' pruned_${ASSEMBLY}.prune.out > exclude_snps_${ASSEMBLY}.txt 

# using --exclude-positions exclude_snps_${ASSEMBLY}.txt instead of --snps pruned_${ASSEMBLY}.prune.in \
# Nucleotide diversity (π)
vcftools --gzvcf cohort.${ASSEMBLY}.final.recode.vcf.gz \
		 --exclude-positions exclude_snps_${ASSEMBLY}.txt \
		 --site-pi \
		 --out pi_${ASSEMBLY}
		 
# Observed heterozygosity
vcftools --gzvcf cohort.${ASSEMBLY}.final.recode.vcf.gz \
		 --exclude-positions exclude_snps_${ASSEMBLY}.txt \
		 --het \
		 --out het_${ASSEMBLY}
		 
# Pairwise FST (two example populations)
vcftools --gzvcf cohort.${ASSEMBLY}.final.recode.vcf.gz \
		 --exclude-positions exclude_snps_${ASSEMBLY}.txt \
		 --weir-fst-pop formica.pop.subasio.txt \
		 --weir-fst-pop formica.pop.giovetto.txt \
		 --out fst_${ASSEMBLY}

##########
mv cohort_formica* stats/${ASSEMBLY}
mv exclude_snps_${ASSEMBLY}.txt stats/${ASSEMBLY}
mv pi_${ASSEMBLY}* stats/${ASSEMBLY}
mv fst_${ASSEMBLY}* stats/${ASSEMBLY}
mv het_${ASSEMBLY}* stats/${ASSEMBLY}
mv pruned* stats/${ASSEMBLY}
mv pca_formica* stats/${ASSEMBLY}

