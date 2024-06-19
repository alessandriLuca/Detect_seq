# remove sequencing adapter 
mkdir /scratch/fix.fastq

for sample in AID_KO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_2_CKDL220028945-1A UNG_DKO_CIT_Duv_2_CKDL220028945-1A UNG_DKO_CIT_Ide_2_CKDL220028945-1A UNG_DKO_NS_2_CKDL220028945-1A
do
    in_fq_R1=/scratch/raw.fastq/${sample}_R1.fq.gz
in_fq_R2=/scratch/raw.fastq/${sample}_R2.fq.gz
    out_fq_R1=/scratch/fix.fastq/${sample}_R1_cutadapt.fq.gz
out_fq_R2=/scratch/fix.fastq/${sample}_R2_cutadapt.fq.gz
    log=/scratch/fix.fastq/${sample}_cutadapt.log
    cutadapt -j 0 --times 1  -e 0.1  -O 3  --quality-cutoff 25 -m 55 -a AGATCGGAAGAGCACACGT  -A  AGATCGGAAGAGCGTCGTG -o ${out_fq_R1} -p ${out_fq_R2} ${in_fq_R1} ${in_fq_R2} > ${log} 2>&1 &
done
