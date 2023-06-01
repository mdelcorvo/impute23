args <- (commandArgs(trailingOnly = TRUE))
isdata_table <- "data.table" %in% installed.packages()[, 1]
isRutils <- "R.utils" %in% installed.packages()[, 1]

if (!isdata_table) {install.packages("data.table", repos = "http://cran.rstudio.com/",lib = .libPaths()[1])}
if (!isRutils) {install.packages("R.utils", repos = "http://cran.rstudio.com/",lib = .libPaths()[1])}

library(data.table)
options(warn = -1)
vcf=args[1]
db=args[2]
outputfile=args[3]

gwas<-fread(db)
raw_vcf<-fread(vcf)

raw_vcf<-merge(raw_vcf,gwas[,c(2,6:8,15,21:22,25,27:28)],by.x='ID',by.y='SNPS',all.x=T)
colnames(raw_vcf)<-c('Snp_name','Chrom','Pos','REF','ALT','Genotype','Cosmic','ClinVar_name','ClinVar_Clinical_Sign','PubmedID','Link','Study','Trait','Gene','SNP_Risk_Allele','Context','Risk_Allele_Freq','P.val')
raw_vcf<-raw_vcf[,c('Snp_name','Chrom','Pos','REF','ALT','Genotype','ClinVar_name','ClinVar_Clinical_Sign','Cosmic','Gene','Trait','SNP_Risk_Allele','Context','Risk_Allele_Freq','P.val','PubmedID','Link','Study')]
raw_vcf <- raw_vcf[with(raw_vcf, order(raw_vcf$Chrom,raw_vcf$Pos)), ]
fwrite(raw_vcf,file=outputfile, row.names=F, col.names=T,quote=F, sep='\t')
