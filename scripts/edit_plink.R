args <- (commandArgs(trailingOnly = TRUE))

if (!requireNamespace("data.table", quietly = TRUE))
    install.packages("data.table",repos = "http://cran.rstudio.com/",lib = .libPaths()[1])

library(data.table)
options(warn = -1)

bim=args[1]
bim = paste(bim,'.bim',sep='')

bim_data <- fread(bim)
bim_data$V5 <- ifelse(bim_data$V5==0 & bim_data$V1 <=22,bim_data$V6,bim_data$V5)
fwrite(bim_data,file=bim, row.names=F, col.names=F,quote=F, sep='\t')
