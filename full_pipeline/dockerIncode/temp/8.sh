# merge HISAT-3n BAM and BWA MEM BAM
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_bam_bwa=/scratch/bam.hisat3n/${sample}_bwa_realign.bam
    in_bam_hisat3n=/scratch/bam.hisat3n/${sample}_hisat3n.bam 
    out_bam=/scratch/bam.hisat3n/${sample}_merge.MAPQ20.bam

    samtools cat -o ${out_bam} ${in_bam_hisat3n} ${in_bam_bwa} &
done
