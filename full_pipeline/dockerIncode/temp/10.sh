# remove duplication
#for sample in 293T-BE4max-mCherry-PD 293T-BE4max-VEGFA-All-PD 293T-DdCBE-GFP-PD 293T-DdCBE-ND6-All-PD
#for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
for sample in UNG_DKO_NS_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A
do  
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort.MAPQ20.bam
    out_log=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.log
    out_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.WithClip.bam
    out_matrix=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.matrix
    
    java -Xms50g -Xmx50g -XX:ParallelGCThreads=20 -jar /home/picard.jar MarkDuplicates I=${in_bam} O=${out_bam} M=${out_matrix} ASO=coordinate REMOVE_DUPLICATES=true 2> ${out_log} &
done
