# attempt to turn gdelt data into dyadic mids data
# with a statistical model 

setwd('~/documents/madcow')
source('start.R')

# load mids directed dyad data
setwd(pathMids)
mids = read.csv('MIDDyadic_v3.10.csv')
mids$Actor1Code = countrycode(mids$CCodeA, "cown", "iso3c")
mids$Actor2Code = countrycode(mids$CCodeB, "cown", "iso3c")
dim(mids)
head(mids)

length(allStates)

midDyadYears = c(1992:2001)

# set up large country-country-year data frame 
allStates = sort(allStates)
allStates
numcombos = choose(length(allStates), 2)
numcombos
gdmid = matrix(NA, nrow=numcombos*length(midDyadYears), ncol=3)
dim(gdmid)

tmpstates = allStates
len = length(allStates)-1
row = 1
for(i in 1:len){
	sta = tmpstates[1]
	for(j in 2:length(tmpstates)){
		stb = tmpstates[j]
		for(yr in midDyadYears){
			gdmid[row,] = c(sta, stb, yr)
			row = row + 1
		}
	}
	tmpstates = tmpstates[-1]
}
head(gdmid)
tail(gdmid)
colnames(gdmid) = c("Actor1Code", "Actor2Code", "year")
head(gdmid)
gdmid = as.data.frame(gdmid)
dim(gdmid)
head(gdmid)
gdmid$year = as.numeric(gdmid$year)
gdmid$year = gdmid$year + 1991

class(gdmid$Actor1Code)
gdmid$Actor1Code = as.character(gdmid$Actor1Code)
gdmid$Actor2Code = as.character(gdmid$Actor2Code)
head(gdmid)

# use mids as outcome var
gdmid$midonset = 0 
gdmid$midongoing = 0
for(i in 1:nrow(mids)){
	if(i%%10==0){print(i)}
	sta = mids$Actor1Code[i]
	stb = mids$Actor2Code[i]
	if(!(sta %in% allStates)){ next }
	if(!(stb %in% allStates)){ next }
	if(sta>stb){ # sort alphabetically
		tmp = sta 
		sta = stb 
		stb = tmp 
	}
	start = mids$StYear[i]
	end = mids$EndYear[i]
	for(yr in start:end){
		want = which(gdmid$Actor1Code==sta & gdmid$Actor2Code==stb & gdmid$year==yr)
		# print(length(want))
		if(yr==start){ gdmid$midonset[want] = 1 }
		gdmid$midongoing[want] = 1
	}
}

sum(gdmid$midonset)
sum(gdmid$midongoing)
head(gdmid)

getwd() # mids
save(gdmid, file="gdmid-before-gdelt.rda")

#############
setwd('~/documents/madcow')
source('start.R')
setwd(pathMids)
load("gdmid-before-gdelt.rda")
class(gdmid$Actor1Code)

# use gdelt as covariates
setwd(pathGdelt)
load('allmi.rda')
dim(allmi)
head(allmi)
allmi$EventCode = as.numeric(allmi$EventCode)
allmi$GoldsteinScale = as.numeric(allmi$GoldsteinScale)
class(allmi$GoldsteinScale)
allmi$countryA = pmin(allmi$country1, allmi$country2)
allmi$countryB = pmax(allmi$country1, allmi$country2)

gdmid$eventmin = NA
gdmid$eventmax = NA
gdmid$eventmean = NA
gdmid$eventmedian = NA 
gdmid$eventsd = NA
gdmid$eventcount = NA
gdmid$event190count  = NA
gdmid$goldmin = NA
gdmid$goldmax = NA
gdmid$goldmean = NA
gdmid$goldmedian = NA
gdmid$goldsd = NA
gdmid$goldcount = NA
gdmid$gold10count  = NA

# head(gdmid)

# head(allmi)
# class(allmi$Actor2Code)
# i = 10000 
# sta = gdmid$Actor1Code[i]
# stb = gdmid$Actor2Code[i]
# yr = gdmid$year[i]
# rows = which(allmi$countryA==sta & allmi$countryB==stb & allmi$year==yr)
# length(rows)
# sta 
# stb 
# yr
# length(which(allmi$countryA=='AFG'))
# length(which(gdmid$Actor1Code=="AFG"))
# which(gdmid$Actor1Code=="AFG" & gdmid$Actor2Code=="PAK")
# rows = which(allmi$countryA=="AFG" & allmi$countryB=="PAK" & allmi$year==1992)
# length(rows)

# nrow(allmi)
# nrow(gdmid)

for(i in 1:nrow(gdmid)){
	if(i%%1000==0){ 
		print(i)
		# print(gdmid[i-1,])
		print(length(which(!(is.na(gdmid$eventmin)))))
	}
	if(i%%10000==0){ save(gdmid, file="gdmid-after-gdelt.rda")}
	# if(gdmid$year[i] != year){ next }
	sta = gdmid$Actor1Code[i]
	stb = gdmid$Actor2Code[i]
	yr = gdmid$year[i]
	rows = which(allmi$countryA==sta & allmi$countryB==stb & allmi$year==yr)
	if(length(rows)==0){ next }
	want = allmi[rows, ]
	gdmid$eventmin[i] = min(want$EventCode) 
	gdmid$eventmax[i] = max(want$EventCode)
	gdmid$eventmean[i] = mean(want$EventCode)
	gdmid$eventmedian[i] = median(want$EventCode)
	# gdmid$eventmode[i] = mode()
	gdmid$eventsd[i] = sd(want$EventCode)
	gdmid$eventcount[i] = nrow(want) 
	gdmid$event190count[i] = length(which(want$EventCode>=190 & want$EventCode<=199))
	gdmid$goldmin[i] = min(want$GoldsteinScale)
	gdmid$goldmax[i] = max(want$GoldsteinScale)
	gdmid$goldmean[i] = mean(want$GoldsteinScale)
	gdmid$goldmedian[i] = median(want$GoldsteinScale)
	# gdmid$goldmode[i]
	gdmid$goldsd[i] = sd(want$GoldsteinScale)
	gdmid$goldcount[i] = nrow(want)
	gdmid$gold10count[i] = length(which(want$GoldsteinScale==-10))
	print(i)
}

save(gdmid, file="gdmid-after-gdelt.rda")

# put zeroes on one column
gdmid$eventcount = ifelse(is.na(gdmid$eventcount), 0, gdmid$eventcount)
save(gdmid, file="gdmid-impute-zeroes.rda")

# subset to complete cases
length(which(!is.na(gdmid$eventmin)))
gdmid = gdmid[which(!is.na(gdmid$eventmin)), ]
dim(gdmid)
save(gdmid, file="gdmid-complete-cases.rda")

########
setwd(pathGdelt)
load("gdmid-complete-cases.rda")
dim(gdmid)
# estimate statistical model(s) on training set
head(gdmid)
sum(gdmid$eventcount) # 123387

midDyadYears = c(1992:2008)
set.seed(54321)
training = sample(midDyadYears, 12)
training = sort(training) 
training = training[which(training<=2001)]
# 1992, 1994, 1995, 1996, 1999, 2001, 2002, 2003, 2004, 2005, 2006, 2008
test = midDyadYears[-(which(midDyadYears %in% training))]
test = test[which(test<=2001)]

gdmid$event190 = ifelse(gdmid$event190count>0, 1, 0)
gdmid$gold10 = ifelse(gdmid$gold10count>0, 1, 0)

gdmidtrain = gdmid[which(gdmid$year %in% training), ]
dim(gdmidtrain)
head(gdmidtrain)
gdmidtest = gdmid[which(gdmid$year %in% test), ]
dim(gdmidtest)

train1 = glm(midongoing ~ eventmax + eventcount + event190count + goldmin + gold10count,
	data=gdmidtrain, family="binomial")
summary(train1)
separationplot(train1$fitted.values, train1$y)

train2 = glm(midongoing ~ eventmax + eventmean + event190count + goldmin + goldmean + gold10count,
	data=gdmidtrain, family="binomial")
summary(train2)
separationplot(train2$fitted.values, train2$y)

train3 = glm(midonset ~ eventmax + eventmean + event190count + goldmin + goldmean + gold10count,
	data=gdmidtrain, family="binomial")
summary(train3)
separationplot(train3$fitted.values, train3$y) # better 

train4 = glm(midongoing ~ eventmin + eventmax + eventmedian + eventcount + event190count +
	goldmin + goldmax + goldmean + goldmedian + gold10count,
	data=gdmidtrain, family="binomial")
summary(train4)
separationplot(train4$fitted.values, train4$y)

train5 = glm(midonset ~ eventmin + eventmax + eventmedian + eventcount + event190count +
	goldmin + goldmax + goldmean + goldmedian + gold10count,
	data=gdmidtrain, family="binomial")
summary(train5)
separationplot(train5$fitted.values, train5$y) # best

train6 = glm(midongoing ~ eventmin + eventmax + eventmedian + eventcount + event190count +
	goldmin + goldmax + goldmean + goldmedian + gold10count,
	data=gdmidtrain, family="binomial")
summary(train6)

train7 = glm(midonset ~ eventmin + eventmax + eventmedian + eventcount + event190count + event190 +
	goldmin + goldmax + goldmean + goldmedian + gold10count + gold10,
	data=gdmidtrain, family="binomial")
summary(train7)
separationplot(train7$fitted.values, train7$y) # best

train8 = glm(midongoing ~ eventmin + eventmax + eventmedian + eventcount + event190count + event190 +
	goldmin + goldmax + goldmean + goldmedian + gold10count + gold10,
	data=gdmidtrain, family="binomial")
summary(train8)

# check accuracy 
p5 = predict(train5, type="response")
somers2(p5, train5$y) # AUC=0.857
brier(train5$y, p5, bins=FALSE) # BRIER=0.0245

p6 = predict(train6, type="response")
somers2(p6, train6$y) # AUC = 0.851
brier(train6$y, p6, bins=FALSE) # BRIER = 0.0315

p7 = predict(train7, type="response")
somers2(p7, train7$y) # AUC=0.857
brier(train7$y, p7, bins=FALSE) # BRIER=0.0244

p8 = predict(train8, type="response")
somers2(p8, train8$y) # AUC = 0.854
brier(train8$y, p8, bins=FALSE) # BRIER = 0.0314

# predict with test set

p5test = predict(train5, newdata=gdmidtest, type="response")
length(p5test)
somers2(p5test, gdmidtest$midonset) # AUC = 0.838
brier(gdmidtest$midonset, p5test, bins=FALSE) # BRIER = 0.0253

p6test = predict(train6, newdata=gdmidtest, type="response")
somers2(p6test, gdmidtest$midongoing) # AUC = 0.873
brier(gdmidtest$midongoing, p6test, bins=FALSE) # BRIER = 0.0278

p7test = predict(train7, newdata=gdmidtest, type="response")
length(p7test)
somers2(p7test, gdmidtest$midonset) # AUC = 0.841
brier(gdmidtest$midonset, p7test, bins=FALSE) # BRIER = 0.0230

p8test = predict(train8, newdata=gdmidtest, type="response")
somers2(p8test, gdmidtest$midongoing) # AUC = 0.875
brier(gdmidtest$midongoing, p8test, bins=FALSE) # BRIER = 0.0278

# separation plots for presentation
setwd("~/Documents/madcow/present5-16-13")

separationplot(train7$fitted.values, train7$y, file="sepplot-onset-training.pdf") # best

notwant = which(is.na(p7test))
separationplot(p7test[-notwant], gdmidtest$midonset[-notwant], file="sepplot-onset-test.pdf") 

separationplot(train8$fitted.values, train8$y, file="sepplot-ongoing-training.pdf") # best

notwant = which(is.na(p8test))
separationplot(p8test[-notwant], gdmidtest$midongoing[-notwant], file="sepplot-ongoing-test.pdf")

sum(gdmidtrain$midonset) # 170
sum(gdmidtrain$midongoing) # 233
sum(gdmidtest$midonset) # 114
sum(gdmidtest$midongoing)