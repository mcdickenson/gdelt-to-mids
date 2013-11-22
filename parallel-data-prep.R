rm(list=ls())
setwd('~/github/gdelt-to-mids')
source('start.R')
library(doSNOW)
library(foreach)
# options(repos=structure(c(CRAN="http://cran.revolutionanalytics.com")))
# install.packages('doSNOW')
# install.packages('foreach')

setwd(pathData)
load("newdata.rda")
dim(newdata)

vars = c(names(newdata[7:31]), 'mid', 'hostile1', 'hostile2', 'hostile3','hostile4','hostile5')
countries = sort(unique(c(newdata$country_1, newdata$country_2)))
dates = sort(unique(newdata$date))
output = matrix(NA, nrow=nrow(newdata), ncol=length(vars))

myLagger = function(i, LAGLENGTH=1){
	print(i)
	row = newdata[i,]
	date.to = row$date 
	if (date.to == min(dates)){ return(rep(NA, length(vars))); }
	date.from = dates[(which(dates==date.to)-LAGLENGTH)]
	country1 = row$country_1
	country2 = row$country_2
	want = which((newdata$country_1==country1) & (newdata$country_2 == country2) & (newdata$date==date.from))[1]
	if (is.na(want)){ return(rep(NA, length(vars))); }
	row.from = newdata[want, ]
	return(row.from[, vars])
}

cl = makeCluster(4)
registerDoSNOW(cl)
getLag = foreach(i=1:nrow(newdata), .combine=rbind) %dopar% {
	myLagger(i)
}
stopCluster(cl)
output[1:LIMIT, ] = getLag
save(output, file="pdp-output.rda")

