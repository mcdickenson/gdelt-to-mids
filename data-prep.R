setwd('~/github/gdelt-to-mids')
source('start.R')
# previous script: merge-agg-with-mids.R

setwd(pathData)

# load data
load("gdelt_mids_merge.rda")
dim(gdelt.mids.merge)
data = gdelt.mids.merge
head(data)
tail(data)

# preprocess data
names(data)

# remove all data that isn't a country dyad
unique(data$country_1)
unique(data$country_2)
not.want = union(which(data$country_1==""), which(data$country_2=="") )
length(not.want)
data = data[-not.want,]
dim(data)

# impute zeroes for NA's on mid vars
summary(data$HiactA)
summary(data$HiactB)
summary(data$HostlevA)
summary(data$HostlevB)
summary(data$start)
summary(data$end)
summary(data$reverse)
data$mid = ifelse(is.na(data$reverse), 0, 1)
summary(data$mid)
sum(data$mid) # approx 1% of cases 

# write a lagger function


# create lagged versions of vars
# create 1-month diffs of vars
# create proportion changes
# create % conflictual vs cooperative


# get years 
# subset to training data
# pick a continuous range for train/test 


