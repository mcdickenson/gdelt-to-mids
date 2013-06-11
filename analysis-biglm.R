setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

train = read.big.matrix('train.csv', type='char', header=TRUE)