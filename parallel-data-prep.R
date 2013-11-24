#!/usr/bin/Rscript

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
newvars = paste(vars, ".l1", sep="")
countries = sort(unique(c(newdata$country_1, newdata$country_2)))
dates = sort(unique(newdata$date))
dim(newdata)
names(newdata)

myLagger = function(i, LAGLENGTH=1){
	row = newdata[i,]
	date.to = row$date 
	if (date.to == min(dates)){ 
		return(NA) 
	}
	date.from = dates[(which(dates==date.to)-LAGLENGTH)]
	want = which((newdata$country_1==row$country_1) & (newdata$country_2 == row$country_2) & (newdata$date==date.from))[1]
	if (is.na(want)){ 
		return(NA)
	}
	row.from = newdata[want, ]
	return(row.from[, vars])
}


mins = c(1, 100001, 200001, 300001, 400001, 500001)
maxs = c(100000, 200000, 300000, 400000, 500000, nrow(newdata))
for(j in 1:6){
	start = mins[j]
	stop = maxs[j]
	filename = paste("output", j, ".rda", sep="")
	for(x in start:stop){
		print(x)
		tmp = myLagger(x)
		if(is.na(tmp[1])){ next }
		else{
			newdata[x , newvars ] = tmp  
		}
	}
	save(newdata, file=filename)
}

