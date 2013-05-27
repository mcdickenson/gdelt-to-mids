setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)
system.time(read.csv('1979.csv', sep='\t', header=F, flush=T, as.is=T))
system.time(read.csv('1979.csv.gz', sep='\t', header=F, flush=T, as.is=T))
system.time(load('gd1979.rda'))

