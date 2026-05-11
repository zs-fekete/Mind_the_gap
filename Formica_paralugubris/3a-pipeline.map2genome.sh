CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate chromcomp

###
###### map and SNP call to GENOME ASSEMBLY ######
###
ASSEMBLY='formica_2022'
#ASSEMBLY='formica_draft'

# my samples
#SAMPLES=('GIOV1C')
SAMPLES=('GIOV1C' 'GIOV3C' 'GIOV4B' 'GIOV6C' 'GIOV9B' 'SUB3A' 'SUB5C' 'SUB7A' 'SUB8A' 'SUB14A')

# Variant discovery workflow (GVCF to joint genotyping)
# HaplotypeCaller per sample (GVCF mode)

for SAMPLE in "${SAMPLES[@]}"; do    
# Alignment and sorting
    bwa mem -M -t 12 -R "@RG\tID:$SAMPLE\tSM:$SAMPLE\tPL:illumina" \
		assemblies/${ASSEMBLY}.soft.fasta reads/${SAMPLE}_R1.trim.fq.gz reads/${SAMPLE}_R2.trim.fq.gz | \
		samtools sort -@12 -o bam/${SAMPLE}.${ASSEMBLY}.bam
    
    # Basic alignment QC (flagstat) for later analysis
    samtools flagstat bam/${SAMPLE}.${ASSEMBLY}.bam > qc/${SAMPLE}.${ASSEMBLY}.flagstat.txt
    
    # Mark duplicates
    gatk MarkDuplicates -I bam/${SAMPLE}.${ASSEMBLY}.bam \
                        -O bam/${SAMPLE}.${ASSEMBLY}.dedup.bam \
                        -M qc/${SAMPLE}.${ASSEMBLY}.dup.txt
    
    # Index deduplicated BAM
    samtools index bam/${SAMPLE}.${ASSEMBLY}.dedup.bam
    
    # Variant calling
    gatk HaplotypeCaller -R assemblies/${ASSEMBLY}.soft.fasta \
                         -I bam/${SAMPLE}.${ASSEMBLY}.dedup.bam \
                         -ERC GVCF \
                         -O gvcf/${SAMPLE}.${ASSEMBLY}.g.vcf.gz
done

