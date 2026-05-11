CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate chromcomp

###
ASSEMBLY='formica_2022'
#ASSEMBLY='formica_draft'

# Combine all sample‑level GVCFs
gatk CombineGVCFs -R assemblies/${ASSEMBLY}.soft.fasta \
				  -V gvcf/GIOV1C.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/GIOV3C.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/GIOV4B.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/GIOV6C.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/GIOV9B.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/SUB3A.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/SUB5C.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/SUB7A.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/SUB8A.${ASSEMBLY}.g.vcf.gz \
				  -V gvcf/SUB14A.${ASSEMBLY}.g.vcf.gz \
				  -O cohort.${ASSEMBLY}.g.vcf.gz

# Cohort‑level genotyping
gatk GenotypeGVCFs -R assemblies/${ASSEMBLY}.soft.fasta \
                   -V cohort.${ASSEMBLY}.g.vcf.gz \
                   -O cohort.${ASSEMBLY}.raw.vcf.gz

# Hard‑filtering SNPs
# QD** (Quality by Depth)**: low values suggest weak evidence per read
# FS** (Fisher strand bias)**: high values flag strand‑specific errors
# MQ** (Mapping Quality)**: values <40 often mark paralogous or repetitive loci
gatk VariantFiltration -R assemblies/${ASSEMBLY}.soft.fasta \
                       -V cohort.${ASSEMBLY}.raw.vcf.gz \
                       --filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0" \
                       --filter-name "basic_snp_filter" \
                       -O cohort.${ASSEMBLY}.flt.vcf.gz

# retain only PASS biallelic SNPs present in ≥80 % samples and with minor‑allele frequency ≥5 %:
bcftools view -f PASS -m2 -M2 -v snps cohort.${ASSEMBLY}.flt.vcf.gz | \
vcftools --vcf - \
         --max-missing 0.8 \
         --maf 0.05 \
         --min-alleles 2 --max-alleles 2 \
         --recode --recode-INFO-all --out cohort.${ASSEMBLY}.final
bgzip -c cohort.${ASSEMBLY}.final.recode.vcf > cohort.${ASSEMBLY}.final.recode.vcf.gz
tabix -p vcf cohort.${ASSEMBLY}.final.recode.vcf.gz
