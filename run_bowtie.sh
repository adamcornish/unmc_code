TIME=`date +'%T'`
echo "[$TIME] bowtie begins."
bowtie -S -p 150 --best -t /safer/genomes/Homo_sapiens/UCSC/hg19/Sequence/BowtieIndex/genome -1 RK-1_TGACCA_L002_R1.fastq,RK-2_TGACCA_L003_R1.fastq -2 RK-1_TGACCA_L002_R2.fastq,RK-2_TGACCA_L003_R2.fastq alignment.sam
TIME=`date +'%T'`
echo "[$TIME] samtools view begins."
samtools view -bS alignment.bam alignment.sam
TIME=`date +'%T'`
echo "[$TIME] samtools sort begins."
samtools sort alignment.bam alignment_sorted
TIME=`date +'%T'`
echo "[$TIME] samtools mpileup / bcftools view begins."
samtools mpileup -f ../alignments/ref/ref.fa -l /safer/genomes/Homo_sapiens/UCSC/hg19/Annotation/Genes/exome_regions.bed -u alignment_sorted.bam | bcftools view -bvcg - > variants.raw.bcf
TIME=`date +'%T'`
echo "[$TIME] variant filtering begins."
bcftools view variants.raw.bcf | vcfutils.pl varFilter -D 100 > filtered_variants.vcf
TIME=`date +'%T'`
echo "[$TIME] fin."
