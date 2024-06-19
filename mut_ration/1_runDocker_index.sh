mkdir "$(pwd)"/genome
mkdir "$(pwd)"/scratch
cp $1 "$(pwd)"/genome/
gen=$(basename $1)
docker run --rm -itv "$(pwd)"/genome:/genome --name detectseq repbioinfo/detectseq /home/index_bwa.sh $gen

