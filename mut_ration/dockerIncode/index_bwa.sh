#!/bin/bash
# Download reference genome
cd /genome/

# build FASTA index
samtools faidx $1

# build BWA MEM index
mkdir bwa_hg38
cd bwa_hg38
cp ../$1* ./
bwa index $1
