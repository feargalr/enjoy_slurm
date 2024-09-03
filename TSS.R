library(ATACseqQC)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(GenomicAlignments)
txs <- transcripts(TxDb.Hsapiens.UCSC.hg38.knownGene)

bamfile = list.files(pattern="bowtie2.sorted.bam")
bamfile = bamfile[!grepl(".bai",bamfile)]
myTSS = c()

mybam = readGAlignments(file=bamfile)
tsse_scores = TSSEscore(mybam, txs,width=100,upstream = 2000,downstream = 2000)
write.table(round(tsse_scores$TSSEscore,3),"TSS.txt",col.names = FALSE,row.names=FALSE)
