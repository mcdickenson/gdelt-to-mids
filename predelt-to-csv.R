setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)


YEARS = c("1979", "1980", "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990", "1991")


for(year in YEARS){
	print(year)

	# load 
	varname = paste('gd', year,  sep="")
	infile = paste(varname, '.rda', sep="")
	loadcommand = paste("load('", infile, "')", sep="")
	eval(parse(text=loadcommand))
	
	if(year=="1979") {
		writecommand = paste("write.table(", varname, ", file='predelt.csv', row.names=FALSE, col.names=TRUE, sep=',')", sep='')
	}
	else{
		writecommand = paste("write.table(", varname, ", file='predelt.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')", sep='')
	}
		
	eval(parse(text=writecommand))
	#print(writecommand)

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
	#print(rmcommand)
}
