#!/bin/bash
# Download reference genome
cd /genome/
filename=$(basename -- "$1")
filename="${filename%.*}"
# build FASTA index
samtools faidx $1

# build BWA MEM index
mkdir bwa_$filename
cd bwa_$filename
cp ../$1* ./
bwa index $1
cd ..
mkdir hisat3n_${filename}_CT
cp ./$1* ./hisat3n_${filename}_CT
cd hisat3n_${filename}_CT
/home/hisat-3n/hisat-3n-build --base-change C,T $1 $1 > hisat3n_${filename}_CT_index.log
