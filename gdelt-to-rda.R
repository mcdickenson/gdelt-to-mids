# turn gdelt historical csvs into rda files 

setwd('~/github/gdelt-to-mids')
source('start.R')

setwd(pathData)

headers = read.table('CSV.header.historical.txt', sep='\t', as.is=TRUE)

YEARS = c(1998:1998)

for(year in YEARS){
	print(year)

	if(year<=1997){
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
	else{
		bigname = paste('gd', year, sep="")
		for(ltr in letters[1:3]){
			varname = paste('gd', year, ltr, sep="")
			datafile = paste(year, ltr, '.csv.gz', sep="")
			readcommand = paste(varname, " = read.csv('", datafile, "', sep='\t', header=F, flush=T, as.is=T)",sep="")
			eval(parse(text=readcommand))

			checkcommand = paste("print(dim(", varname, "))", sep="")
			eval(parse(text=checkcommand))

			namecommand = paste("colnames(", varname, ") = headers", sep="")
			eval(parse(text=namecommand))

			if(ltr=="a"){
				combcommand = paste(bigname, "=", varname, sep="")
			}
			else{
				combcommand = paste(bigname, "=rbind(", bigname, ", ", varname, ")", sep="")
			}
			# print(combcommand)
			eval(parse(text=combcommand))

			rmcommand = paste("rm(", varname, ")", sep="")
			eval(parse(text=rmcommand))
		}
		savecommand = paste("save(", bigname, ", file='", bigname, ".rda')", sep="")
		eval(parse(text=savecommand))
		rmcommand = paste("rm(", bigname, ")", sep="")
		eval(parse(text=rmcommand))
	}

}
