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

clinvar<-fread(db)
clinvar$ClinVarDisease_name<-ifelse(clinvar$ID!='.',gsub('.*CLNDN=|;.*','',clinvar$INFO),NA)
clinvar$ClinVarClinical_significance<-ifelse(clinvar$ID!='.',gsub('.*CLNSIG=|;.*','',clinvar$INFO),NA)

raw_vcf<-fread(vcf,skip=grep('CHROM',readLines(vcf))-1)

colnames(clinvar)[1]<-'CHROM';colnames(raw_vcf)[1]<-'CHROM'
clinvar$id<-paste(clinvar$CHROM,clinvar$POS,sep='_');raw_vcf$id<-paste(raw_vcf$CHROM,raw_vcf$POS,sep='_')
clinvar<-clinvar[!duplicated(clinvar$id),]

raw_vcf$ClinVarDisease_name<- clinvar[match(raw_vcf$id,clinvar$id),]$ClinVarDisease_name
raw_vcf$ClinVarClinical_significance<- clinvar[match(raw_vcf$id,clinvar$id),]$ClinVarClinical_significance
raw_vcf$id<-NULL;raw_vcf$QUAL<-NULL;raw_vcf$FILTER<-NULL;raw_vcf$INFO<-NULL;raw_vcf$FORMAT<-NULL
fwrite(raw_vcf,file=outputfile, row.names=F, col.names=T,quote=F, sep='\t')
