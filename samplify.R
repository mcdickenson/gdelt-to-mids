setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

# prep data
load('gd1993mid.rda')
dim(gd1993mid)

names(gd1993mid)
summary(gd1993mid$HiactA)
gd1993mid$mid = ifelse(is.na(gd1993mid$HiactA), 0, 1)
gd1993mid$HiactA = ifelse(is.na(gd1993mid$HiactA), 0, gd1993mid$HiactA)
gd1993mid$HiactB = ifelse(is.na(gd1993mid$HiactB), 0, gd1993mid$HiactB)
gd1993mid$HostlevA = ifelse(is.na(gd1993mid$HostlevA), 0, gd1993mid$HostlevA)
gd1993mid$HostlevB = ifelse(is.na(gd1993mid$HostlevB), 0, gd1993mid$HostlevB)
gd1993mid$FatalA = ifelse(gd1993mid$FatalA < 0, NA, gd1993mid$FatalA)
gd1993mid$FatalA = ifelse(is.na(gd1993mid$FatalA), 0, gd1993mid$FatalA)
gd1993mid$FatalB = ifelse(gd1993mid$FatalB < 0, NA, gd1993mid$FatalB)
gd1993mid$FatalB = ifelse(is.na(gd1993mid$FatalB), 0, gd1993mid$FatalB)
head(gd1993mid)

# 10 subsets of 1993 for feature selection 
samps = sample.int(10, size=nrow(gd1993mid), replace=TRUE)

for(i in 1:10){
	print(i)
	want = which(samps==i)
	subset = gd1993mid[want,]
	print(dim(subset))
	writecommand = paste("write.table(subset, file='trainsub", i, ".csv', row.names=FALSE, col.names=TRUE, sep=',')", sep='')
	# print(writecommand)
	eval(parse(text=writecommand))
}