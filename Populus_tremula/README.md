# Populus tremula

This folder contains the scripts used to analyse whole-genome sequencing data from 10 individuals belonging to two populations of _Populus tremula_ sampled in Sweden and Norway for the Mind the Gap project. 


## Author
Mimmi C. Eriksson, Umeå Plant Science Centre (UPSC), Department of Plant Physiology, Umeå University, Umeå, Sweden

Kathryn M. Robinson, Umeå Plant Science Centre (UPSC), Department of Plant Physiology, Umeå University, Umeå, Sweden

Nathaniel R. Street, Umeå Plant Science Centre (UPSC), Department of Plant Physiology, Umeå University, Umeå, Sweden


# Notes: Mind the gaps - Populus tremula pipeline

## Build the environment
Miniforge3-Linux-x86_64 was used as conda/mamba manager

```
sbatch scripts/00_make_env.sh
```

## Soft masking repeats

```
sbatch scripts/01_soft_masking_repeats.sh
```

## Read quality, filtering and trimming

Read quality assessment
```
sbatch scripts/02.1_qc.sh
```

Quality and adapter trimming
```
sbatch scripts/02.2_fastp.sh
```

## Read mapping

Indexing
```
sbatch scripts/03.1_indexing.sh
```

Mapping
```
sbatch scripts/03.2_mapping.sh
```

## Haplotype calling
Haplotype calling was done on subsets of regions specified by the -L parameter which held a bed file with regions to call.

For the draft assembly, the original 204318 contigs were divided into 20 bed files of ~10220 contigs in each.

For the chromosome assembly, each of the 19 chromosomes were called individually while all scaffolds were combined into one call.

Call per sample and region
```
sbatch scripts/04.1_haplotype_calling.sh

```

For us the recommended `CombineGVCFs` was very slow to run. 
Instead we used `GenomicsDBImport` to combine the samples calls per called region.

Combine sample calls
```
sbatch scripts/04.2_genomicDBimport.sh
```

Cohort genotype calling 
```
scripts/04.3_genotype_vcf.sh
```

Concat all regions called files into one vcf file
```
sbatch scripts/04.4_concat_vcf.sh
```

Filtering calls

```
sbatch scripts/04.5_filter_vcf.sh
```

## Popgen stats
### PCA
Plink complained about too many contigs so the vcf files were modified to avoid this complaint.
What was done:
1. For each bed file used during the haplotype calling the chromosome was replaced by the bed file number (1-20)
2. To avoid duplicate positions, positions were recalculated as $1$2, where:
    - $1 = original contig number (remove all letters and 0 at start. eg. Potra000019 -> 19) 
    - $2 the original position
    - e.g if the chromosome was Potra000019 it became 19 and with position 1054 the final position would be 191054
3. IDs for each SNP was premade as original_contig/chromosome:new_contig:new_position  eg. contig: Potra000019, position: 1054 -> 19:19:1054. The original contig/chromosome is added because only using new_contig:new_position would create duplicates due to the many contigs
LD prune the data

```
sbatch scripts/05.1_pca.sh
```

### vcftools stats
Nucleotide diversity
```
sbatch scripts/05.2_vcftools_stats.sh
```

#### population files
pop1.txt (East (Sweden), higher elevation)
- NordAsp_E17
- NordAsp_E21
- NordAsp_E28
- NordAsp_X701
- NordAsp_X706

pop2.txt (West (Norway), lower elevation)
- NordAsp_G17
- NordAsp_M14
- NordAsp_M21
- NordAsp_M29
- NordAsp_M30


## BUSCO
```
sbatch scripts/06.1_busco.sh
```