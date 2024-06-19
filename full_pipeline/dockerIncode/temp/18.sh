# for DdCBE sample
ref_genome_fa=/genomes/hisat3n_hg38_CT/hg38_only_chromosome.fa
/root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/find-significant-mpmat.py -p 25 \
-i /scratch/pmat_and_mpmat/293T-DdCBE-ND6-All-PD_hg38.MAPQ20.merge.select.sort.RmChrYChrM.mpmat \
-o /scratch/poisson_res/293T-DdCBE-ND6-All-PD_vs_ctrl_hg38.select.pvalue_table \
-c /scratch/bam.hisat3n/293T-DdCBE-GFP-PD_hg38_merge_sort_rmdup.MAPQ20.bam \
-t /scratch/bam.hisat3n/293T-DdCBE-ND6-All-PD_hg38_merge_sort_rmdup.MAPQ20.bam \
-r ${ref_genome_fa} \
--query_mutation_type CT,GA  \
--mpmat_filter_info_col_index -1 \
--mpmat_block_info_col_index -1  \
--region_block_mut_num_cutoff 2  \
--query_mut_min_cutoff 2  \
--query_mut_max_cutoff 16  \
--total_mut_max_cutoff 16  \
--other_mut_max_cutoff 6   \
--seq_reads_length 150  \
--lambda_method ctrl_max \
--poisson_method mutation \
2> /scratch/poisson_res/293T-DdCBE-ND6-All-PD_vs_ctrl_hg38_possion_test.log &
