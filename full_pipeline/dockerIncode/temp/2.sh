# HISAT-3N mapping
mkdir bam.hisat3n
#293T-BE4max-VEGFA-All-PD  293T-BE4max-mCherry-PD
for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do
    in_fq_R1=/scratch/fix.fastq/${sample}_R1_cutadapt.fq.gz
    in_fq_R2=/scratch/fix.fastq/${sample}_R2_cutadapt.fq.gz
    out_bam=/scratch/bam.hisat3n/${sample}_hisat3n.bam 

    ummapped_fq=/scratch/bam.hisat3n/${sample}_hisat3n_unmapped.fq.gz
    log=/scratch/bam.hisat3n/${sample}_hisat3n.log
    ref_idx=/genomes/hisat3n_mm9_CT/mm9_only_chromosome.fa

    /home/hisat-3n/hisat-3n -x ${ref_idx} -1 ${in_fq_R1} -2 ${in_fq_R2} -p 20 --sensitive --base-change C,T --unique-only --repeat-limit 1000 --no-spliced-alignment -X 700 --un-conc-gz ${ummapped_fq} --summary-file ${log} --rg-id ${sample} --rg "PL:ILLUMINA" --rg "ID:"${sample} --rg "SM:"${sample} | samtools view -hb > ${out_bam} &
done
