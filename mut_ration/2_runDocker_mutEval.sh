#!/bin/bash

# Crea le directory necessarie
mkdir -p "$(pwd)"/genome
mkdir -p "$(pwd)"/scratch/raw.fastq

# Copia i file fastq nella directory di lavoro
cp $2/* "$(pwd)"/scratch/raw.fastq

# Definisce le variabili per il genoma e il threshold
genome_dir=$(dirname "$1")
genome_file=$(basename "$1")
threshold=$3

# Esegui il container Docker, montando le cartelle corrette
docker run --rm -it -v "$genome_dir":/genome -v "$(pwd)"/scratch:/scratch --name detectseq repbioinfo/detectseq /home/fullScript.sh $genome_file $threshold
