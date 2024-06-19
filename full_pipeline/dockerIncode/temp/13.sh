# convert BAM to pmat format
mkdir pmat_and_mpmat

for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    in_bam=/scratch/bam.hisat3n/${sample}_merge_sort_rmdup.MAPQ20.bam
    ref_genome_fa=/genomes/hisat3n_mm9_CT/mm9_only_chromosome.fa
    out_pmat=/scratch/pmat_and_mpmat/${sample}_CLEAN.pmat
    out_log=/scratch/pmat_and_mpmat/${sample}_CLEAN.log

/root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/bam2pmat.py -i ${in_bam} -r ${ref_genome_fa} -o ${out_pmat} -p 20 --out_format pmat --bed_like_format True --mut_type ALL --block_size 100000  --cover_num_cutoff 0 --mut_num_cutoff 0 --mut_ratio_cutoff 0 --keep_temp_file False --out_header False > ${out_log}  2>&1 &

done
