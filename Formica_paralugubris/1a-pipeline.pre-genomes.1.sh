

python /Users/linoometto/miniforge3/share/RepeatMasker/famdb.py -i /Users/linoometto/miniforge3/share/RepeatMasker/Libraries/famdb families --format fasta_name --ancestors --descendants "Hymenoptera" > hymenoptera_repeats.fasta

ASSEMBLY='formica_hq'
#ASSEMBLY='formica_2022mod'

RepeatMasker -lib hymenoptera_repeats.fasta -pa 11 -gff -xsmall -dir assemblies/ assemblies/${ASSEMBLY}.original.fasta

# conda activate chromcomp

cp assemblies/${ASSEMBLY}.original.fasta.masked assemblies/${ASSEMBLY}.soft.fasta

bwa index assemblies/${ASSEMBLY}.soft.fasta


# conda install -c bioconda seqkit
seqkit stats -a assemblies/${ASSEMBLY}.original.fasta > ${ASSEMBLY}.original.stats.txt
seqkit fx2tab -n -l assemblies/${ASSEMBLY}.original.fasta > ${ASSEMBLY}.original.stats2.txt

