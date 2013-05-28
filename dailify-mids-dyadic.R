# turn dyadic mid data with start/end dates into daily records 

setwd('~/github/gdelt-to-mids')
source('start.R')

setwd(pathData)

mid = read.csv('MIDDyadic_v3.10.csv', as.is=T)
dim(mid)
head(mid)

mid$StDay = ifelse(mid$StDay==-9, 15, mid$StDay)
mid$EndDay = ifelse(mid$EndDay==-9, 15, mid$EndDay)
mid$start = as.Date(paste(mid$StYear, mid$StMon, mid$StDay, sep="-"))
mid$end = as.Date(paste(mid$EndYear, mid$EndMon, mid$EndDay, sep="-"))
head(mid)


dailify = function(mydata){
	value_names = colnames(mydata)

	# set up data frame for daily data
	daily = matrix(NA, nrow=1, ncol=ncol(mid)+1)
	colnames(daily) = c(value_names, "date")
	daily = as.data.frame(daily)

	for(i in 1:nrow(mydata)){  
		start.date = mydata[i,"start"]
		end.date =  mydata[i,"end"]
		all.dates = seq(start.date, length = end.date - start.date, by = "day")
		if(length(all.dates)==0){all.dates=start.date}

		tmp = matrix(NA, nrow=length(all.dates), ncol=ncol(mid))
		colnames(tmp) = value_names
		tmp = as.data.frame(tmp)
		tmp$date = all.dates
		tmp[, value_names] = mydata[i, value_names]
		
		daily<-rbind(daily,tmp)
	}
	daily <- daily[-1,]
	daily$start = as.Date(daily$start)
	daily$end = as.Date(daily$end)
	daily$date = as.Date(daily$date)
	return(daily)
}

midmini = mid[1:10,]
dailymini = dailify(midmini)
head(dailymini)
tail(dailymini)


