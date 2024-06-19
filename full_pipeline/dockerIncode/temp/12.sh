# build BAM index
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam
    out_bam_index=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam.bai
    
    samtools index -@ 10 ${in_bam} ${out_bam_index} &
done
