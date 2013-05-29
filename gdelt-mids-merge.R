setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

# mids data
load('dd.rda')

# gdelt data
load('gd1992.rda')
dim(gd1992)
names(gd1992)
head(gd1992[,1:25])
head(gd1992[,36:56])

countries = sort(unique(c(gd1992$Actor1CountryCode, gd1992$Actor2CountryCode)))
countries

# merge with gdelt by year 
head(gd1992)
gd1992$month = gd1992$MonthYear %% 100
gd1992$day =  gd1992$SQLDATE %% 100
gd1992$date = as.Date(paste(gd1992$Year, gd1992$month, gd1992$day, sep="-"))
gd1992mid = merge(gd1992, dd, 
	by=c('date', 'Actor1CountryCode', 'Actor2CountryCode'), 
	all.x=TRUE)
dim(gd1992mid)
head(gd1992mid)
tail(gd1992mid)
length(which(!(is.na(gd1992mid$DispNum))))

save(gd1992mid, file="gd1992mid.rda")
rm(gd1992)

YEARS = c("1992")

for(year in YEARS){
	print(year)

	# load 
	varname = paste('gd', year, sep="")
	datafile = paste(year, '.csv.gz', sep="")
	readcommand = paste(varname, " = read.csv('", datafile, "', sep='\t', header=F, flush=T, as.is=T)",sep="")
	eval(parse(text=readcommand))

	# TODO: add R-formatted date variable to gdelt records 

	# TODO: merge
	
	# save and clear 
	savecommand = paste("save(", varname, ", file='", varname, ".rda')", sep="")
	eval(parse(text=savecommand))

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
}