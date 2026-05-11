CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate chromcomp

###
ASSEMBLY='formica_hq'
	
# Detecting runs of homozygosity (RoH)
bcftools roh -G 30 -Orz -o bcftoolsROH.${ASSEMBLY}.raw.txt cohort.${ASSEMBLY}.final.recode.vcf.gz

cat bcftoolsROH.${ASSEMBLY}.raw.txt | tail -n+4 | sed 's/# //g' | sed -E 's/\[[0-9]\]//g' | sed 's/ (bp)//g'  | sed 's/ (average fwd-bwd phred score)//g' | tr ' ' '_'> bcftoolsROH.${ASSEMBLY}.cleaned.txt