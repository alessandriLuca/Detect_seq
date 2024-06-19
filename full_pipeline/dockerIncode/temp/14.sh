# tracing tandem mutation signals
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do  
    ref_genome_fa=/genomes/hisat3n_mm9_CT/mm9_only_chromosome.fa
    
    in_pmat=/scratch/pmat_and_mpmat/${sample}_merge_sort_rmdup.MAPQ20.pmat
    out_C_pmat=/scratch/pmat_and_mpmat/${sample}_merge_sort_rmdup.MAPQ20_C.pmat
    out_G_pmat=/scratch/pmat_and_mpmat/${sample}_merge_sort_rmdup.MAPQ20_G.pmat

    out_CT_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.CT.mpmat
    out_GA_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.GA.mpmat
    out_CT_log=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.CT.mpmat.log
    out_GA_log=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.GA.mpmat.log

    awk '$10 == "C" {print $0}' ${in_pmat} > ${out_C_pmat} 

    # CT on the Watson strand
    /root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/pmat-merge.py -i ${out_C_pmat} -f C -t T -r ${ref_genome_fa} -d 50 -D 100 --NoMutNumCutoff 2 --OmitTandemNumCutoff 2 -o ${out_CT_mpmat} 2> ${out_CT_log} 

        awk '$10 == "G" {print $0}' ${in_pmat} > ${out_G_pmat} 

    # CT on the Crick strand
    /root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/pmat-merge.py -i ${out_G_pmat} -f G -t A -r ${ref_genome_fa} -d 50 -D 100 --NoMutNumCutoff 2 --OmitTandemNumCutoff 2 -o ${out_GA_mpmat} 2> ${out_GA_log} 

done
