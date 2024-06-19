#!/bin/bash
threshold=$2
adapt1=$3
adapt2=$4


filenameGen=$(basename -- "$1")
filenameGen="${filenameGen%.*}"
#adapt1=AGATCGGAAGAGCACACGT
#adapt2=AGATCGGAAGAGCGTCGTG
for in_fq_R1 in /scratch/raw.fastq/*_R1.fastq.gz
do
    sample=$(basename ${in_fq_R1} _R1.fastq.gz)
     #SCRIPT1
    mkdir /scratch/fix.fastq
    in_fq_R1=/scratch/raw.fastq/${sample}_R1.fastq.gz
    in_fq_R2=/scratch/raw.fastq/${sample}_R2.fastq.gz
    out_fq_R1=/scratch/fix.fastq/${sample}_R1_cutadapt.fastq.gz
    out_fq_R2=/scratch/fix.fastq/${sample}_R2_cutadapt.fastq.gz
    log=/scratch/fix.fastq/${sample}_cutadapt.log
    cutadapt -j 0 --times 1  -e 0.1  -O 3  --quality-cutoff 25 -m 55 -a $adapt1 -A $adapt2 -o ${out_fq_R1} -p ${out_fq_R2} ${in_fq_R1} ${in_fq_R2} > ${log}
     #SCRIPT2
    in_fq_R1=/scratch/fix.fastq/${sample}_R1_cutadapt.fastq.gz
    in_fq_R2=/scratch/fix.fastq/${sample}_R2_cutadapt.fastq.gz
    out_bam=/scratch/bam.hisat3n/${sample}_hisat3n.bam
    ummapped_fq=/scratch/bam.hisat3n/${sample}_hisat3n_unmapped.fastq.gz
    log=/scratch/bam.hisat3n/${sample}_hisat3n.log
    ref_idx=/genome/hisat3n_${filenameGen}_CT/$1
    mkdir /scratch/bam.hisat3n
    /home/hisat-3n/hisat-3n -x ${ref_idx} -1 ${in_fq_R1} -2 ${in_fq_R2} -p 20 --sensitive --base-change C,T --unique-only --repeat-limit 1000 --no-spliced-alignment -X 700 --un-conc-gz ${ummapped_fq} --summary-file ${log} --rg-id ${sample} --rg "PL:ILLUMINA" --rg "ID:"${sample} --rg "SM:"${sample} | samtools view -hb > ${out_bam}
    # select low mapping quality BAM
    in_bam=/scratch/bam.hisat3n/${sample}_hisat3n.bam
    out_bam=/scratch/bam.hisat3n/${sample}_hisat3n.MAPQ20.LowerMAPQ20.bam
    samtools view -h -@ 4 ${in_bam} | awk '$1~"@" || $5 <= 20  {print $0}' |  samtools view -@ 4 -hb > ${out_bam}
    # BAM sort by reads name
    in_bam=/scratch/bam.hisat3n/${sample}_hisat3n.MAPQ20.LowerMAPQ20.bam
    out_bam=/scratch/bam.hisat3n/${sample}_hisat3n.MAPQ20.LowerMAPQ20.SortName.bam
    temp_file=/scratch/bam.hisat3n/${sample}_hisat3n.MAPQ20.LowerMAPQ20.SortName.bam.temp
    samtools sort -O BAM -o ${out_bam} -T ${temp_file} -@ 15 -m 2G -n ${in_bam}
    # fetch low mapping quality reads from BAM file
    in_bam=/scratch/bam.hisat3n/${sample}_hisat3n.MAPQ20.LowerMAPQ20.SortName.bam
    ref_genome_fa=/genome/hisat3n_${filenameGen}_CT/$1
    out_fq_R1=/scratch/bam.hisat3n/${sample}_hisat3n.LowerMAPQ20_R1.fastq.gz
    out_fq_R2=/scratch/bam.hisat3n/${sample}_hisat3n.LowerMAPQ20_R2.fastq.gz
    samtools fastq -@ 15 -0 /dev/null -s /dev/null -n -F 0x900 -1 ${out_fq_R1} -2 ${out_fq_R2} --reference ${ref_genome_fa}  ${in_bam}
    # merge unmapped reads and low mapping quality reads
    low_fq_R1=/scratch/bam.hisat3n/${sample}_hisat3n.LowerMAPQ20_R1.fastq.gz
    low_fq_R2=/scratch/bam.hisat3n/${sample}_hisat3n.LowerMAPQ20_R2.fastq.gz
    unmapped_fq_R1=/scratch/bam.hisat3n/${sample}_hisat3n_unmapped.fastq.1.gz
    unmapped_fq_R2=/scratch/bam.hisat3n/${sample}_hisat3n_unmapped.fastq.2.gz
    out_fq_R1=/scratch/bam.hisat3n/${sample}_R1_unmapped_and_LowerMAPQ20.fastq.gz
    out_fq_R2=/scratch/bam.hisat3n/${sample}_R2_unmapped_and_LowerMAPQ20.fastq.gz
    cat ${low_fq_R1} ${unmapped_fq_R1} > ${out_fq_R1}
    cat ${low_fq_R2} ${unmapped_fq_R2} > ${out_fq_R2}
    # re-alignment with BWA MEM
    in_fq_R1=/scratch/bam.hisat3n/${sample}_R1_unmapped_and_LowerMAPQ20.fastq.gz
    in_fq_R2=/scratch/bam.hisat3n/${sample}_R2_unmapped_and_LowerMAPQ20.fastq.gz
    bwa_index=/genome/bwa_${filenameGen}/$1
    out_bam=/scratch/bam.hisat3n/${sample}_bwa_realign.bam
    bwa_log=/scratch/bam.hisat3n/${sample}_bwa_realign.log
    bwa mem ${bwa_index} ${in_fq_R1} ${in_fq_R2} -t 20 -M -R '@RG\tID:'${sample}'\tPL:ILLUMINA\tSM:'${sample} 2>${bwa_log} | samtools view -h -b -q 20 -f 3 -F 256 > ${out_bam}
    # merge HISAT-3n BAM and BWA MEM BAM
    in_bam_bwa=/scratch/bam.hisat3n/${sample}_bwa_realign.bam
    in_bam_hisat3n=/scratch/bam.hisat3n/${sample}_hisat3n.bam
    out_bam=/scratch/bam.hisat3n/${sample}_merge.MAPQ20.bam
    samtools cat -o ${out_bam} ${in_bam_hisat3n} ${in_bam_bwa}
    # sort BAM by genome coordinate
    in_bam=/scratch/bam.hisat3n/${sample}_merge.MAPQ20.bam
    out_bam=/scratch/bam.hisat3n/${sample}_merge_sort.MAPQ20.bam
    temp_file=/scratch/bam.hisat3n/${sample}_merge_sort.MAPQ20.bam.temp
    samtools sort -O BAM -o ${out_bam} -T ${temp_file} -@ 15 -m 2G ${in_bam}
    # remove duplication
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort.MAPQ20.bam
    out_log=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.log
    out_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.WithClip.bam
    out_matrix=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.matrix
    java -Xms50g -Xmx50g -XX:ParallelGCThreads=20 -jar /home/picard.jar MarkDuplicates I=${in_bam} O=${out_bam} M=${out_matrix} ASO=coordinate REMOVE_DUPLICATES=true 2> ${out_log}
    # filter clip, non-concordant reads, low MAPQ reads and secondary alignment
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.WithClip.bam
    out_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam
    ref_genome_fa=/genome/hisat3n_${filenameGen}_CT/$1
    samtools view -@ 4 -h ${in_bam} -q 20 -f 3 -F 256 | /home/samclip --ref ${ref_genome_fa} --max 3 --progress 0 | awk 'function abs(v) {return v < 0 ? -v : v} $1~"@" || ($7 == "=" && abs($9) <= 2500 ) {print $0}' | samtools view -@ 4 -hb > ${out_bam}
    # build BAM index
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam
    out_bam_index=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam.bai
    samtools index -@ 10 ${in_bam} ${out_bam_index}
# convert BAM to pmat format
    mkdir /scratch/pmat_and_mpmat
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam
    ref_genome_fa=/genome/hisat3n_${filenameGen}_CT/$1
    out_pmat=/scratch/pmat_and_mpmat/${sample}_CLEAN.pmat
    out_log=/scratch/pmat_and_mpmat/${sample}_CLEAN.log
    /root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/bam2pmat.py -i ${in_bam} -r ${ref_genome_fa} -o ${out_pmat} -p 20 --out_format pmat --bed_like_format True --mut_type ALL --block_size 100000  --cover_num_cutoff 0 --mut_num_cutoff 0 --mut_ratio_cutoff 0 --keep_temp_file False --out_header False > ${out_log}


#


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
    awk -f /home/locationAWK_COUNT.awk 114498650 114503581 12 SA "${directoryOut}/filtered_${search_string}/filtered_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114498650 114503581 12 SA "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114661796 114665162 12 SU "${directoryOut}/filtered_${search_string}/filtered_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114661796 114665162 12 SU "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114589303 114616242 12 SY3 "${directoryOut}/filtered_${search_string}/filtered_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114589303 114616242 12 SY3 "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114568421 114581890 12 SY1 "${directoryOut}/filtered_${search_string}/filtered_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114568421 114581890 12 SY1 "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114544419 114557888 12 SY2b "${directoryOut}/filtered_${search_string}/filtered_${filename}"
    awk -f /home/locationAWK_COUNT.awk 114544419 114557888 12 SY2b "${directoryOut}/filtered_${search_string}/filtered2_${filename}"
    done


    done
