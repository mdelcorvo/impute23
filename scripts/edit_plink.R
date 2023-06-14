args <- (commandArgs(trailingOnly = TRUE))

library(data.table)
options(warn = -1)

bim=args[1]
bim = paste(bim,'.bim',sep='')

bim_data <- fread(bim)
bim_data$V5 <- ifelse(bim_data$V5==0 & bim_data$V1 <=22,bim_data$V6,bim_data$V5)
bim_data$V1 <- ifelse(bim_data$V1==23,'X',bim_data$V1)
fwrite(bim_data,file=bim, row.names=F, col.names=F,quote=F, sep='\t')
