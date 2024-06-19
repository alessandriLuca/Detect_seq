#!/bin/bash
# Array dei campioni
samples=("CH12F3_AID-KO_DMSO" "CH12F3_AID-WT_DMSO" "CH12F3_AID-WT_Idelalisib_DMSO" "CH12F3_Ligase4-KO_DMSO")

# Funzione per eseguire il calcolo per un singolo campione
process_sample() {

 local sample=$1
  mkdir /scratch/alignment
    in_fq_R1=/scratch/raw.fastq/${sample}_R1.fastq.gz
    in_fq_R2=/scratch/raw.fastq/${sample}_R2.fastq.gz
    bwa_index=/genome/mm9_only_chromosome.fa
    out_bam=/scratch/alignment/${sample}.bam
    bwa_log=/scratch/alignment/${sample}.log
    bwa mem ${bwa_index} ${in_fq_R1} ${in_fq_R2} -t 20 -M -R '@RG\tID:'${sample}'\tPL:ILLUMINA\tSM:'${sample} 2>${bwa_log} | samtools view -h -b -q 20 -f 3 -F 256 > ${out_bam}

# sort BAM by genome coordinate
    in_bam=/scratch/alignment/${sample}.bam
    out_bam=/scratch/alignment/${sample}sort.bam
    temp_file=/scratch/alignment/${sample}.bam.temp

    samtools sort -O BAM -o ${out_bam} -T ${temp_file} -@ 15 -m 2G ${in_bam}

# remove duplication
    in_bam=/scratch/alignment/${sample}sort.bam
    out_log=/scratch/alignment/${sample}sort_rmdup.log
    out_bam=/scratch/alignment/${sample}sort_rmdup.bam
    out_matrix=/scratch/alignment/${sample}sort_rmdup.matrix

    java -Xms50g -Xmx50g -XX:ParallelGCThreads=20 -jar /home/picard.jar MarkDuplicates I=${in_bam} O=${out_bam} M=${out_matrix} ASO=coordinate REMOVE_DUPLICATES=true 2> ${out_log}
    in_bam=/scratch/alignment/${sample}sort.bam
    out_bam_index=/scratch/alignment/${sample}sort.bam.bai

    samtools index -@ 10 ${in_bam} ${out_bam_index}
    mkdir pmat_and_mpmat
    in_bam=/scratch/alignment/${sample}sort.bam
    ref_genome_fa=/genome/mm9_only_chromosome.fa
    out_pmat=/scratch/pmat_and_mpmat/${sample}_CLEAN.pmat
    out_log=/scratch/pmat_and_mpmat/${sample}_CLEAN.log


/root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/bam2pmat.py -i ${in_bam} -r ${ref_genome_fa} -o ${out_pmat} -p 20 --out_format pmat --bed_like_format True --mut_type ALL --block_size 100000  --cover_num_cutoff 0 --mut_num_cutoff 0 --mut_ratio_cutoff 0 --keep_temp_file False --out_header False > ${out_log}  2>&1

# Definisci il locus di interesse
chr="chr12"
start=114437957
end=114697959

dir=$(dirname "$out_pmat")
new_file="${sample}_IGH.pmat"
new_path="${dir}/${new_file}"

# Cerca nel file tutte le righe che iniziano con il locus di interesse
grep "^${chr}\s" ${out_pmat} | awk -v chr="$chr" -v start="$start" -v end="$end" '$2>=start && $3<=end'  > ${new_path}




directoryOut="/scratch/Res_Stat/${sample}"
threshold=4
input_file=/scratch/pmat_and_mpmat/${sample}_IGH.pmat
filename=$(basename "$input_file")
filebase="${filename%.*}"
path_without_filename=$(dirname "$input_file")
search_strings=("CT" "GA")
for search_string in "${search_strings[@]}"; do
    mkdir -p "${directoryOut}/filtered_${search_string}"
    awk -v dirOut="${directoryOut}/filtered_${search_string}" -v fname="$filename" -v threshold="$threshold" -v search="$search_string" '
        $9 ~ search {
            line = sprintf("%s_%s", $1, $2)
            for (i = 5; i <= NF; i++) {
                if (i != 10 && i != 11 && i != 15 && i != 16) {
                    line = sprintf("%s %s", line, $i)
                }
            }
            echo $13
            if ($13 >= threshold) {
                file2 = dirOut "/filtered2_" fname
                print line >> file2
                close(file2)
            }
        }
    ' "$input_file" > "${directoryOut}/filtered_${search_string}/filtered_${filename}"

awk -v search="$search_string" '
        {gsub("_", " "); if ($7=="CT") {print "variableStep chrom="$1" span=1\n"$2" "$9} else {print "variableStep chrom="$1" span=1\n"$2" -"$9}}
    ' "${directoryOut}/filtered_${search_string}/filtered_${filename}" >> "${directoryOut}/filtered_${search_string}/filtered_${filebase}.wig"
awk -v search="$search_string" '
        {gsub("_", " "); if ($7=="CT") {print "variableStep chrom="$1" span=1\n"$2" "$9} else {print "variableStep chrom="$1" span=1\n"$2" -"$9}}
    ' "${directoryOut}/filtered_${search_string}/filtered2_${filename}" >> "${directoryOut}/filtered_${search_string}/filtered2_${filebase}.wig"


output_file="${directoryOut}/filtered_${search_string}/filtered2_${filebase}.bed"

while IFS= read -r line; do
  chr=$(echo "$line" | awk '{split($0, a, "[ _]"); print a[1]}')
  start=$(echo "$line" | awk '{split($0, a, "[ _]"); print a[2]}')
  count=$(echo "$line" | awk '{split($0, a, " "); print a[length(a)-1]}')
  for ((i = 0; i < count; i++)); do
    #uniqueName=$(bash identific.sh)
   uniqueName=$i #
   randomNumber=$(shuf -i 30-60 -n 1)
   strand=$(awk 'BEGIN{srand(); r = int(rand() * 2); if(r == 0) print "+"; else print "-"}')
    echo -e "$chr\t$start\t$start\t$uniqueName\t$randomNumber\t$strand" >> "$output_file"
  done

done < "${directoryOut}/filtered_${search_string}/filtered2_${filename}"

done

search_strings=("CT" "GA")

for search_string in "${search_strings[@]}"; do
echo "yoyoyoyoyo"
echo $directoryOut
echo "${directoryOut}/filtered_${search_string}/filtered_${filename}"
#echo "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114498650 114503581 12 SA "${directoryOut}/filtered_${search_string}/filtered_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114498650 114503581 12 SA "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114661796 114665162 12 SU "${directoryOut}/filtered_${search_string}/filtered_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114661796 114665162 12 SU "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114589303 114616242 12 SY3 "${directoryOut}/filtered_${search_string}/filtered_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114589303 114616242 12 SY3 "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114568421 114581890 12 SY1 "${directoryOut}/filtered_${search_string}/filtered_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114568421 114581890 12 SY1 "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114544419 114557888 12 SY2b "${directoryOut}/filtered_${search_string}/filtered_${filename}"
awk -f /scratch/locationAWK_COUNT.awk 114544419 114557888 12 SY2b "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
done
}


for sample in "${samples[@]}"; do
    process_sample "$sample" &
done

# Attendi che tutti i processi figlio abbiano completato l'esecuzione
wait

echo "Tutti i processi sono stati completati."
