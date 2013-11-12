setwd('~/github/gdelt-to-mids')
source('start.R')
setwd("~/Dropbox/gdelt-aggregations")

test = read.csv("test-agg.csv", as.is=TRUE)
dim(test)
train = read.csv("train-agg.csv", as.is=TRUE)
dim(train)
predelt = read.csv("1979-1991-agg-corrected.csv", as.is=TRUE)
dim(predelt)

combined = rbind(test, train, predelt)
dim(combined)
names(combined)
head(combined)
combined = combined[order(combined$year, combined$month, combined$country_1, combined$country_2), ]
head(combined)
tail(combined)
write.csv(combined, file="1979-2001-agg-corrected.csv")

big = read.csv("1979-2001-agg.csv", as.is=TRUE)
big = big[ , -1]
dim(big)
names(big)
postdelt = read.csv("2002-2005-agg.csv", as.is=TRUE)
dim(postdelt)
postdelt2 = read.csv("2006-2012-agg.csv", as.is=TRUE)
dim(postdelt2)

combined = rbind(big, postdelt, postdelt2)
dim(combined)
combined = combined[order(combined$year, combined$month, combined$country_1, combined$country_2), ]

write.csv(combined, file="1979-2012-agg.csv")

