CONDA_BASE=$(conda info --base)
source ${CONDA_BASE}/etc/profile.d/conda.sh
conda activate chromcomp

# RepeatMasker run on minilino
samtools faidx assemblies/formica_draft.soft.fasta
gatk CreateSequenceDictionary -R assemblies/formica_draft.soft.fasta

