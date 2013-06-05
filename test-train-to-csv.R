setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

set.seed(54321)
years = c(1992:2001)
training = sort(sample(years, 5))
# training = c(1993, 1996, 1998, 1999, 2001)
test = years[-which(years %in% training)]
# test = c(1992, 1994, 1995, 1997, 2000)

# YEARS = c("1992", "1993", "1994", "1995", "1996", "1997a", "1997b", "1998a", "1998b", "1998c", "1999a", "2000a", "2000b", "2000c", "2001a", "2001b", "2001c")
TRAINYEARS = c("1993", "1996", "1998a", "1998b", "1998c", "1999a", "1999b", "1999c", "2001a", "2001b", "2001c")
TESTYEARS = c("1992", "1994", "1995", "1997a", "1997b", "2000a", "2000b", "2000c")

for(year in TRAINYEARS){
	print(year)

	# load 
	varname = paste('gd', year, 'mid',  sep="")
	infile = paste(varname, '.rda', sep="")
	loadcommand = paste("load('", infile, "')", sep="")
	eval(parse(text=loadcommand))
	
	if((year=="1992") | (year=="1993")){
		writecommand = paste("write.table(", varname, ", file='train.csv', append=TRUE, row.names=FALSE, col.names=TRUE, sep=',')", sep='')
	}
	else{
		writecommand = paste("write.table(", varname, ", file='train.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')", sep='')
	}
		
	eval(parse(text=writecommand))
	#print(writecommand)

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
	#print(rmcommand)
}

for(year in TESTYEARS){
	print(year)

	# load 
	varname = paste('gd', year, 'mid',  sep="")
	infile = paste(varname, '.rda', sep="")
	loadcommand = paste("load('", infile, "')", sep="")
	eval(parse(text=loadcommand))
	
	if((year=="1992") | (year=="1993")){
		writecommand = paste("write.table(", varname, ", file='test.csv', append=TRUE, row.names=FALSE, col.names=TRUE, sep=',')", sep='')
	}
	else{
		writecommand = paste("write.table(", varname, ", file='test.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')", sep='')
	}
		
	eval(parse(text=writecommand))
	#print(writecommand)

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
	#print(rmcommand)
}
