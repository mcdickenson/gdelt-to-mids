# turn gdelt historical csvs into rda files 

setwd('~/github/gdelt-to-mids')
source('start.R')

setwd(pathData)

headers = read.table('CSV.header.historical.txt', sep='\t', as.is=TRUE)

YEARS = c(1984:2001)

for(year in YEARS){
	print(year)

	varname = paste('gd', year, sep="")
	datafile = paste(year, '.csv.gz', sep="")
	readcommand = paste(varname, " = read.csv('", datafile, "', sep='\t', header=F, flush=T, as.is=T)",sep="")
	eval(parse(text=readcommand))

	checkcommand = paste("print(dim(", varname, "))", sep="")
	eval(parse(text=checkcommand))

	namecommand = paste("colnames(", varname, ") = headers", sep="")
	eval(parse(text=namecommand))

	savecommand = paste("save(", varname, ", file='", varname, ".rda')", sep="")
	eval(parse(text=savecommand))

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
}
