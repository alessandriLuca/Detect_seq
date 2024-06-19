# select low mapping quality BAM
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_bam=/scratch/bam.hisat3n/${sample}_hisat3n.bam 
    out_bam=/scratch/bam.hisat3n/${sample}_hisat3n.MAPQ20.LowerMAPQ20.bam

    samtools view -h -@ 4 ${in_bam} | awk '$1~"@" || $5 <= 20  {print $0}' |  samtools view -@ 4 -hb > ${out_bam} &
done
