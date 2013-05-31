setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

# mids data
load('dd.rda')

# gdelt data
# load('gd1992.rda')
# dim(gd1992)
# names(gd1992)
# head(gd1992[,1:25])
# head(gd1992[,36:56])
# countries = sort(unique(c(gd1992$Actor1CountryCode, gd1992$Actor2CountryCode)))

# # merge with gdelt by year 
# head(gd1992)
# gd1992$month = gd1992$MonthYear %% 100
# gd1992$day =  gd1992$SQLDATE %% 100
# gd1992$date = as.Date(paste(gd1992$Year, gd1992$month, gd1992$day, sep="-"))
# gd1992mid = merge(gd1992, dd, 
	# by=c('date', 'Actor1CountryCode', 'Actor2CountryCode'), 
	# all.x=TRUE)
# dim(gd1992mid)
# head(gd1992mid)
# tail(gd1992mid)
# length(which(!(is.na(gd1992mid$DispNum))))
# save(gd1992mid, file="gd1992mid.rda")
# rm(gd1992)

YEARS = c("1997a", "1997b")

for(year in YEARS){
	print(year)

	# load 
	varname = paste('gd', year, sep="")
	infile = paste(varname, '.rda', sep="")
	loadcommand = paste("load('", infile, "')", sep="")
	eval(parse(text=loadcommand))
	
	#print(loadcommand)

	# TODO: add R-formatted date variable to gdelt records 
	monthcommand = paste(varname, "$month = ", varname, "$MonthYear %% 100", sep="")
	daycommand = paste(varname, "$day = ", varname, "$SQLDATE %% 100", sep="")
	datecommand = paste(varname, "$date = as.Date(paste(", varname, "$Year, ", varname, "$month, ", varname, "$day, sep='-'))", sep="")
	eval(parse(text=monthcommand))
	eval(parse(text=daycommand))
	eval(parse(text=datecommand))
	#print(monthcommand)
	#print(daycommand)
	#print(datecommand)
	
	# merge
	mergecommand = paste(varname, "mid = merge(", varname, ", dd, by=c('date', 'Actor1CountryCode', 'Actor2CountryCode'), all.x=TRUE)", sep="" )
	eval(parse(text=mergecommand))
	#print(mergecommand)
		
	# save and clear 
	savecommand = paste("save(", varname, "mid, file='", varname, "mid.rda')", sep="")
	eval(parse(text=savecommand))
	#print(savecommand)

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
	#print(rmcommand)
	rmcommand = paste("rm(", varname, "mid)", sep="")
	eval(parse(text=rmcommand))
	#print(rmcommand)
}