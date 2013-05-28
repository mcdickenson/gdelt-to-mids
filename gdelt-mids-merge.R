setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

load('dailydyad.rda')
dailydyad$Actor1Geo_CountryCode = countrycode(dailydyad$CCodeA, "cown", "iso2c")
dailydyad$Actor2Geo_CountryCode = countrycode(dailydyad$CCodeB, "cown", "iso2c")
head(dailydyad)
# TODO: handle missingness
# yugoslavia

# TODO: consider de-directing the dyads 
# (ie duplicating all records in dailydyad and reversing the actor codes)

# merge with gdelt by year 

load('gd1992.rda')
dim(gd1992)
names(gd1992)
head(gd1992[,1:25])

head(gd1992[,36:56])

YEARS = c("1992")

for(year in YEARS){
	print(year)

	# load 
	varname = paste('gd', year, sep="")
	datafile = paste(year, '.csv.gz', sep="")
	readcommand = paste(varname, " = read.csv('", datafile, "', sep='\t', header=F, flush=T, as.is=T)",sep="")
	eval(parse(text=readcommand))

	# merge
	
	# save and clear 
	savecommand = paste("save(", varname, ", file='", varname, ".rda')", sep="")
	eval(parse(text=savecommand))

	rmcommand = paste("rm(", varname, ")", sep="")
	eval(parse(text=rmcommand))
}