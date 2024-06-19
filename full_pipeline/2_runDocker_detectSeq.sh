#!/bin/bash

# Trova il numero massimo degli esperimenti esistenti e incrementa di 1
exp_num=1
for dir in "$(pwd)"/Exp*; do
  if [[ -d "$dir" && "$dir" =~ Exp([0-9]+) ]]; then
    num=${BASH_REMATCH[1]}
    if (( num > exp_num )); then
      exp_num=$((num + 1))
    fi
  fi
done

# Crea le directory necessarie
exp_dir="$(pwd)/Exp${exp_num}"
mkdir -p "${exp_dir}/raw.fastq"

# Copia i file fastq nella directory di lavoro
cp "$2"/* "${exp_dir}/raw.fastq"

# Definisce le variabili per il genoma e il threshold
genome_dir=$(dirname "$1")
genome_file=$(basename "$1")
threshold=$3

# Esegui il container Docker, montando le cartelle corrette
echo $genome_dir
docker run --rm -i -v "$genome_dir":/genome -v "${exp_dir}":/scratch --name detectseq repbioinfo/detectseq /home/fullScript_fullPipeline.sh $genome_file $threshold $4 $5

