library(ATACseqQC)

my_bamfile = list.files(pattern="bowtie2.sorted.bam")
my_bamfile = my_bamfile[!grepl(".bai",my_bamfile)]

my.res = bamQC(bamfile=my_bamfile)

write.table(round(my.res$nonRedundantFraction,3),"NRF.txt",col.names = FALSE,row.names=FALSE)
write.table(round(my.res$PCRbottleneckCoefficient_1,3),"PCR1.txt",col.names = FALSE,row.names=FALSE)
write.table(round(my.res$PCRbottleneckCoefficient_2,3),"PCR2.txt",col.names = FALSE,row.names=FALSE)
