setwd('~/github/gdelt-to-mids')
source('start.R')

setwd(pathData)
mid = read.csv("MIDDyadic_v3.10.csv", as.is=TRUE)
mid$StDay = ifelse(mid$StDay==-9, 1, mid$StDay)
mid$EndDay = ifelse(mid$EndDay==-9, 1, mid$EndDay)
mid$start = as.Date(paste(mid$StYear, mid$StMon, "01", sep="-"))
mid$end = as.Date(paste(mid$EndYear, mid$EndMon, "01", sep="-"))
mid$end = ifelse(mid$end<mid$start, mid$start, mid$end)
mid$end = as.Date(mid$end)


monthify = function(mydata){
	value_names = colnames(mydata)

	# set up data frame for daily data
	monthly= matrix(NA, nrow=1, ncol=ncol(mid)+1)
	colnames(monthly) = c(value_names, "date")
	monthly = as.data.frame(monthly)

	for(i in 1:nrow(mydata)){  
		if(i%%10==0){print(i)}
		start.date = mydata[i,"start"]
		end.date =  mydata[i,"end"]
		all.dates = seq(start.date, end.date, by = "month")
		if(length(all.dates)==0){all.dates=start.date}

		tmp = matrix(NA, nrow=length(all.dates), ncol=ncol(mid))
		colnames(tmp) = value_names
		tmp = as.data.frame(tmp)
		tmp$date = all.dates
		tmp[, value_names] = mydata[i, value_names]
		
		monthly<-rbind(monthly,tmp)
	}
	monthly <- monthly[-1,]
	monthly$start = as.Date(monthly$start)
	monthly$end = as.Date(monthly$end)
	monthly$date = as.Date(monthly$date)
	return(monthly)
}

head(mid)
monthly.mids = monthify(mid[1:10, ])
head(monthly.mids)

monthlymids = monthify(mid)
head(monthlymids)
save(monthlymids, file="monthlymids.rda")
