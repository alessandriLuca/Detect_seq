# sort BAM by genome coordinate
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_bam=/scratch/bam.hisat3n/${sample}_merge.MAPQ20.bam
    out_bam=/scratch/bam.hisat3n/${sample}_merge_sort.MAPQ20.bam
    temp_file=/scratch/bam.hisat3n/${sample}_merge_sort.MAPQ20.bam.temp

    samtools sort -O BAM -o ${out_bam} -T ${temp_file} -@ 15 -m 2G ${in_bam} &
done
