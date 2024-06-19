# merge tandem mutation signals and sort
for sample in UNG_DKO_CIT_1_CKDL220026488 UNG_DKO_CIT_Duv_1_CKDL220026488 UNG_DKO_NS_1_CKDL220026488
do
    in_CT_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.CT.mpmat
    in_GA_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.GA.mpmat
    ref_genome_fa_index=/genomes/hisat3n_mm9_CT/mm9_only_chromosome.fa.fai

    out_CT_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.CT.select.mpmat
    out_GA_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.GA.select.mpmat
    out_merge_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge_d50_D100.merge.select.mpmat
out_merge_sort_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge.select.sort.mpmat
out_rm_chr_mpmat=/scratch/pmat_and_mpmat/${sample}.MAPQ20.merge.select.sort.RmChrYChrM.mpmat

    # select CT
    /root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/mpmat-select.py -i ${in_CT_mpmat} -o ${out_CT_mpmat} -f C -t T -m 4 -c 6 -r 0.01 --RegionPassNum 1 --RegionToleranceNum 10 --RegionMutNum 2 --InHeader True --OutHeader False

    # select GA
    /root/anaconda3/envs/DetectSeq/bin/python /home/Detect-seq/src/detect_seq/mpmat-select.py -i ${in_GA_mpmat} -o ${out_GA_mpmat} -f G -t A -m 4 -c 6 -r 0.01 --RegionPassNum 1 --RegionToleranceNum 10 --RegionMutNum 2 --InHeader True --OutHeader False
 # merge CT singal on the Watson strand and the Crick strand
    cat ${out_CT_mpmat} ${out_GA_mpmat}  > ${out_merge_mpmat}

    # sort by the genome coordinate
    bedtools sort -i ${out_merge_mpmat} -g ${ref_genome_fa_index} | uniq > ${out_merge_sort_mpmat}

    # remove chrY and chrM
    cat ${out_merge_sort_mpmat} | grep -v chrY | grep -v chrM > ${out_rm_chr_mpmat}
done
