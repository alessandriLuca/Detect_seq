# re-alignment with BWA MEM
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_fq_R1=/scratch/bam.hisat3n/${sample}_R1_unmapped_and_LowerMAPQ20.fq.gz
    in_fq_R2=/scratch/bam.hisat3n/${sample}_R2_unmapped_and_LowerMAPQ20.fq.gz
    bwa_index=/genomes/bwa_mm9/mm9_only_chromosome.fa
    out_bam=/scratch/bam.hisat3n/${sample}_bwa_realign.bam
    bwa_log=/scratch/bam.hisat3n/${sample}_bwa_realign.log
    bwa mem ${bwa_index} ${in_fq_R1} ${in_fq_R2} -t 20 -M -R '@RG\tID:'${sample}'\tPL:ILLUMINA\tSM:'${sample} 2>${bwa_log} | samtools view -h -b -q 20 -f 3 -F 256 > ${out_bam} &
done
