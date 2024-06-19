# filter clip, non-concordant reads, low MAPQ reads and secondary alignment
#for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.WithClip.bam
    out_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam
    ref_genome_fa=/genomes/hisat3n_mm9_CT/mm9_only_chromosome.fa
    
    samtools view -@ 4 -h ${in_bam} -q 20 -f 3 -F 256 | /home/samclip --ref ${ref_genome_fa} --max 3 --progress 0 | awk 'function abs(v) {return v < 0 ? -v : v} $1~"@" || ($7 == "=" && abs($9) <= 2500 ) {print $0}' | samtools view -@ 4 -hb > ${out_bam} &
done
