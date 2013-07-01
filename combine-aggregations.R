setwd('~/github/gdelt-to-mids')
source('start.R')
setwd("~/Dropbox/gdelt aggregations")

test = read.csv("test-agg.csv", as.is=TRUE)
dim(test)
train = read.csv("train-agg.csv", as.is=TRUE)
dim(train)
predelt = read.csv("1979-1991-agg.csv", as.is=TRUE)
dim(predelt)

combined = rbind(test, train, predelt)
combined = combined[order(combined$year, combined$month, combined$)]