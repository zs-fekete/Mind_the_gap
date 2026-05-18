CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate chromcomp


###### to be done only once before mapping etc

SAMPLES=('GIOV1C' 'GIOV3C' 'GIOV4B' 'GIOV6C' 'GIOV9B' 'SUB3A' 'SUB5C' 'SUB7A' 'SUB8A' 'SUB14A')

# per-sample fastQC
cd reads/
mkdir -p ../qc/fastqc
fastqc -t 16 *.fq.gz -o ../qc/fastqc
# Multi QC aggregation
multiqc ../qc/fastqc -o ../qc
cd ..

# Loop through each sample --> Quality trimming with fastp
for SAMPLE in "${SAMPLES[@]}"; do
    fastp -i reads/${SAMPLE}_1.fq.gz -I reads/${SAMPLE}_2.fq.gz \
          -o reads/${SAMPLE}_R1.trim.fq.gz -O reads/${SAMPLE}_R2.trim.fq.gz \
          --adapter_fasta my_adapters.fasta -q 20 -u 30 -l 50 -g \
          -h qc/${SAMPLE}.fastp.html -j qc/${SAMPLE}.fastp.json
done


# per-sample fastQC on trimmed reads
cd reads/
mkdir -p ../qc_trim
mkdir -p ../qc_trim/fastqc
fastqc -t 16 *.trim.fq.gz -o ../qc_trim/fastqc
# Multi QC aggregation
multiqc ../qc_trim/fastqc -o ../qc_trim
cd ..
