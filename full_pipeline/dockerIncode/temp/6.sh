# merge unmapped reads and low mapping quality reads
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    low_fq_R1=/scratch/bam.hisat3n/${sample}_hisat3n.LowerMAPQ20_R1.fq.gz
    low_fq_R2=/scratch/bam.hisat3n/${sample}_hisat3n.LowerMAPQ20_R2.fq.gz

    unmapped_fq_R1=/scratch/bam.hisat3n/${sample}_hisat3n_unmapped.fq.1.gz
    unmapped_fq_R2=/scratch/bam.hisat3n/${sample}_hisat3n_unmapped.fq.2.gz

    out_fq_R1=/scratch/bam.hisat3n/${sample}_R1_unmapped_and_LowerMAPQ20.fq.gz
    out_fq_R2=/scratch/bam.hisat3n/${sample}_R2_unmapped_and_LowerMAPQ20.fq.gz

    cat ${low_fq_R1} ${unmapped_fq_R1} > ${out_fq_R1} &
    cat ${low_fq_R2} ${unmapped_fq_R2} > ${out_fq_R2} & 
done
