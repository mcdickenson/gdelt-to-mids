args = commandArgs(TRUE)

setwd('~/desktop')

year = args[1]

print(year)

# load 
varname = paste('gd', year,  sep="")
infile = paste(year, '.tsv', sep="")
loadcommand = paste(varname, " = read.delim('", infile, "')", sep="")
eval(parse(text=loadcommand))

writecommand = paste("write.table(", varname, ", file='", year, ".csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',')", sep='')
eval(parse(text=writecommand))

rmcommand = paste("rm(", varname, ")", sep="")
eval(parse(text=rmcommand))

