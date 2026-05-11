# Mustela nivalis

This folder contains the scripts used to analyse custom targeted-enrichment sequencing data from 10 individuals belonging to two populations of *Mustela nivalis* sampled in Switzerland and Finland for the Mind the Gap project.


## Author
Inês Miranda, CIBIO-InBIO/BIOPOLIS - University of Porto, Portugal


## Workflow
All analyses were run in a conda environment dedicated to the Mind the Gap project:

	
	conda activate chromcomp


Analyses were run following the shared comparative workflow, with a few additional processing steps to incorporate multiple sequencing runs per individual. 

Scripts uploaded to this folder include all steps used in data analysis for *M. nivalis*. Data was analysed in a SLURM environment with a job submission system.

Briefly, the following steps were taken:

### A. Reference genome preparation:
The following reference genomes were used for analyses:

Chromosome-level: [GCF_964662115.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_964662115.1/)

Draft: [GCA_019141155.1](https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_019141155.1/)

Each genome was processed as follows:

1. The level of completeness of the genome assemblies was assessed using BUSCO, under the carnivora_odb10 database, with the scripts <code>00_busco_chr-level_c_odb10.sh</code> and <code>00_busco_draft_c_odb10.sh</code> for the chromosome-level and draft genomes, respectively.

2. The reference genomes were soft-masked with RepeatMasker, using the scripts <code>01_repeatmasker_chr_mustelidae.sh</code> and <code>01_repeatmasker_draft_mustelidae.sh</code>.

### B. Raw data quality control:
Raw sequencing data for the dataset samples were copied to a dedicated Mind The Gap folder. The data is part of a larger sequencing project available on NCBI's [BioProject PRJNA1196891](https://www.ncbi.nlm.nih.gov/bioproject/1196891/).

The Mind The Gap data was pre-processed as follows:

3. The quality of raw reads was assessed per-sample using FastQC, with the script <code>02_fastqc_raw_reads.sh</code>, and then aggregated using MultiQC (script <code>03_multiqc_raw_reads.sh</code>).

4. Adapter sequences were removed, and reads were quality trimmed with fastp, using the script <code>04_fastp_raw_reads.sh</code>.

### C. Mapping and BAM post-processing:
Trimmed sequencing reads were mapped to each reference genome:

5. The reference genomes were indexed with BWA, SAMtools and GATK before mapping, using the script <code>05_index_genomes.sh</code>.

6. Reads were then mapped to each reference genome using BWA, with the script <code>06_bwa_mapping.sh</code>. FASTQ files from multiple sequencing runs per individual were independently mapped to each genome.

Here, two additional steps were introduced compared to the shared comparative workflow to allow merging of BAM files at the individual level, keeping a single BAM per individual.

7. First, read groups were added to each BAM file, with sample, lane, and flowcell information, to allow identifying reads originating from different sequencing runs in the same individual, using Picard (script <code>07_picard_rg.sh</code>).

8. Then, BAM files were merged at the sample-level, using SAMtools (script <code>08_merge_bams.sh</code>).

The next step resumed the shared comparative workflow:

9. Duplicated reads within each sample were marked with GATK, using the script <code>09_markdups.sh</code>.

### D. Variant calling and population genomic analyses:
Final BAM files were used for variant calling and subsequent population genomic analyses:

10. Haplotype calling was done per sample, using GATK, with the script <code>10_gvcf_calls.sh</code>.

11. Resulting GVCFs were combined across samples and then genotyped for variant calling, using GATK, with the script <code>11_combine_calls.sh</code>.

12. Resulting VCF files were then hard-filtered for high-quality SNPs, using a two-step approach with GATK and BCFtools/VCFtools, using the script <code>12_filter_calls.sh</code>.

13. SNPs were LD-pruned, and a Principal Component Analysis (PCA) was conducted on the filtered SNP-set using Plink, with the script <code>13_pca_plink.sh</code>.

14. Finally, population-level summary statistics were inferred using VCFtools, with the script <code>14_popstats_vcftools.sh</code>.
