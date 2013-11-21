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

# dummies by hostility level (in case high levels easier to detect)
data$HostlevA = ifelse(is.na(data$HostlevA), 0, data$HostlevA)
summary(data$HostlevA)
data$HostlevB = ifelse(is.na(data$HostlevB), 0, data$HostlevB)
summary(data$HostlevB)
data$HostlevMax = apply(data[, c('HostlevA', 'HostlevB')], 1, max)
summary(data$HostlevMax)

data$hostile1 = ifelse(data$HostlevMax>=1, 1, 0)
data$hostile2 = ifelse(data$HostlevMax>=2, 1, 0)
data$hostile3 = ifelse(data$HostlevMax>=3, 1, 0)
data$hostile4 = ifelse(data$HostlevMax>=4, 1, 0)
data$hostile5 = ifelse(data$HostlevMax>=5, 1, 0)

summary(data$hostile1)
summary(data$hostile5) # biggest dropoff: 4-5



# # create lagged versions of vars
# lagger = function(data, vars, countries, dates, laglength=1, evaluate=FALSE){
# 	# data: the full dataset
# 	# vars: vars you want lags of
# 	# countries: vector of uniq country names
# 	# dates: vector of uniq (sorted) dates
# 	# laglength: # months you want laggged -- scalar
# 	newdata = data

# 	# create new variables, eg newdata$foo.l1
# 	for(var in vars){
# 		newname = paste(var, '.l', laglength, sep='')
# 		command = paste('newdata$', newname, '=NA', sep='')
# 		if(evaluate){ eval(command) }
# 		else{ print(command) }
# 	}
# 	# return;

# 	# lag vars
# 	for(country1 in countries){
# 		print(country1)
# 		for(country2 in countries){
# 			print(country2)
# 			for(i in (laglength+1):length(dates)){
# 				date.to = dates[i] # eg feb, march, april
# 				date.from = dates[i-laglength] # jan, feb, mar
# 				row.from = which(newdata$country_1==country1 & newdata$country_2==country2 & newdata$date==date.from)[1]
# 				row.to = which(newdata$country_1==country1 & newdata$country_2==country2 & newdata$date==date.to)[1]
# 				if(is.na(row.from) || is.na(row.to)){
# 					next
# 				}
# 				for(var in vars){
# 					newname = paste(var, '.l', laglength, sep='')
# 					command = paste('newdata[', row.to, ', "', newname, '"] = newdata[', row.from, ', "', var, '"]', sep='')
# 					if(evaluate){ eval(command) }
# 					else{ print(command) }
# 				}
# 			}
# 		}
# 	}
# 	return(newdata)
# }

names(data)
vars = c(names(data[7:31]), 'mid', 'hostile1', 'hostile2', 'hostile3','hostile4','hostile5')
#  [1] "event1"   "event2"   "event3"   "event4"   "event5"   "event6"  
#  [7] "event7"   "event8"   "event9"   "event10"  "event11"  "event12" 
# [13] "event13"  "event14"  "event15"  "event16"  "event17"  "event18" 
# [19] "event19"  "event20"  "actorMIL" "quad1"    "quad2"    "quad3"   
# [25] "quad4"    "mid"      "hostile1" "hostile2" "hostile3" "hostile4"
# [31] "hostile5"
vars
countries = sort(unique(c(data$country_1, data$country_2)))
countries
dates = sort(unique(data$date))
dates
# lagger(data, vars, countries, dates, laglength=1, evaluate=TRUE)



###
LAGLENGTH = 1
newdata = data 
newvars = c()
for(var in vars){
	newname = paste(var, '.l', LAGLENGTH, sep='')
	newvars = c(newvars, newname)
	command = paste('newdata$', newname, ' = NA', sep='')
	print(command)
	eval(parse(text=command))
}
newvars


for(i in 1:nrow(newdata)){
	if(i%%100==0){print(i/nrow(newdata))}
	row = newdata[i,]
	date.to = row$date 
	if (date.to == min(dates)){ next }
	date.from = dates[(which(dates==date.to)-LAGLENGTH)]
	country1 = row$country_1
	country2 = row$country_2
	want = which((newdata$country_1==country1) & (newdata$country_2 == country2) & (newdata$date==date.from))[1]
	if (is.na(want)){ next }
	row.from = newdata[want, ]
	newdata[i, newvars] = row.from[, vars]
}



# create 1-month diffs of vars
# create proportion changes
# create % conflictual vs cooperative


# get years 
# subset to training data
# pick a continuous range for train/test 


