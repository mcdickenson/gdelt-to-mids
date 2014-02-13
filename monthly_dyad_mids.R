rm(list=ls())

toLoad <- c("plyr", "countrycode", "dplyr", "data.table", "reshape2", "zoo")
lapply(toLoad, library, character.only=TRUE)

data <- read.csv("../data/MID/MIDB_4.0.csv", as.is=TRUE)
names(data)

# Populate the full matrix of dyads months
years <- c(min(data$StYear):max(data$StYear))
months <- c(1:12)
month_years <- expand.grid(years, months)

countries <- as.character(unique(data$StAbb))
dyads <- t(combn(countries, 2))
dyads <- dyads[order(dyads[, 1], dyads[, 2]), ]

# Match each dyad with each month. Had to temporarily join 2 countries into 1 var
# (ideal?)
finalMatrix <- expand.grid(paste(dyads[,1], dyads[,2]),
                           paste(month_years[,1], month_years[,2]),
                           stringsAsFactors = FALSE)
# Now I have to split the dyad var into 2 countries again
# This freezes my laptop
finalMatrix2 <- cbind(data.frame(do.call(rbind, strsplit(finalMatrix$Var1, " "))),
                      data.frame(do.call(rbind, strsplit(finalMatrix$Var2, " "))))

# Create the matrix of conflictual dyad months from original data
# Test on one dispute. Then later apply these functions to all other disputes,
# using plyr

# Check if a dyadmonth is in conflict. Dyadmonth is a one row data frame
f_isConflictual <- function(dyadmonth, ref) {
  stateA <- dyadmonth[1, 1]
  stateB <- dyadmonth[1, 2]
  # year <- dyadmonth[1, 3]
  # month <- dyadmonth[1, 4]
  currentMonth <- as.yearmon(paste(dyadmonth[1, 3], dyadmonth[1, 4], sep="-"), format="%Y-%m") 
  # Check. Remember that in a dispute, a state may appear multiple times
  
  # Check the month in dyad month matches with which row in the ref dataframe
  # There should be only one match, i.e. matchMonthA is a logical vector with one element = T
  
  stMonthA <- as.yearmon(paste(ref$StYear[ref$StAbb==stateA], ref$StMon[ref$StAbb==stateA], 
                                sep="-"), 
                          format="%Y-%m")
  endMonthA <- as.yearmon(paste(ref$EndYear[ref$StAbb==stateA], ref$EndMon[ref$StAbb==stateA], 
                                  sep="-"), 
                            format="%Y-%m")
  matchMonthA <- (currentMonth >= stMonthA) & (currentMonth <= endMonthA)
  
  stMonthB <- as.yearmon(paste(ref$StYear[ref$StAbb==stateB], ref$StMon[ref$StAbb==stateB], 
                               sep="-"), 
                         format="%Y-%m")
  endMonthB <- as.yearmon(paste(ref$EndYear[ref$StAbb==stateB], ref$EndMon[ref$StAbb==stateB], 
                                sep="-"), 
                          format="%Y-%m")
  matchMonthB <- (currentMonth >= stMonthB) & (currentMonth <= endMonthB)
  # Check side
  conflict <- ref$SideA[ref$StAbb==stateA][matchMonthA] != 
    ref$SideA[ref$StAbb==stateB][matchMonthB]
  
  conflict <- ifelse(length(conflict)==0, FALSE, conflict)
  
  # What if countries switch side?
  return(conflict)
}

# Function that takes one dispute and turn into dyads conflict
f_genDyadMonthFromDisp <- function(ref) {
  years <- c(min(ref$StYear):max(ref$StYear))
  months <- c(1:12)
  month_years <- expand.grid(years, months, stringsAsFactors=FALSE)
  
  countries <- as.character(unique(ref$StAbb))
  dyads <- t(combn(countries, 2))
  dyads <- data.frame(dyads[order(dyads[, 1], dyads[, 2]), ], stringsAsFactors=FALSE)
  
  # Match each dyad with each month. Had to temporarily join 2 countries into 1 var
  # (ideal?)
  finalMatrix <- expand.grid(paste(dyads[,1], dyads[,2]),
                             paste(month_years[,1], month_years[,2]),
                             stringsAsFactors = FALSE)
  finalMatrix2 <- data.frame(do.call(rbind, strsplit(finalMatrix$Var1, " ")),
                        do.call(rbind, strsplit(finalMatrix$Var2, " ")),
                        stringsAsFactors=FALSE)
  names(finalMatrix2) <- c("stateA", "stateB", "year", "month")
  finalMatrix2 <- transform(finalMatrix2, year = as.numeric(year),
                          month = as.numeric(month))
  finalMatrix2 <- finalMatrix2[order(finalMatrix2$year, finalMatrix2$month),]
  
  return(finalMatrix2)
}

f_transformDispIntoDyad <- function(ref) {
  dyadmonths <- f_genDyadMonthFromDisp(ref)
  dyads_conflict <- adply(dyadmonths, 1, f_isConflictual, ref)
  return(dyads_conflict)
}

# Test one one dispute
temp <- data[data$DispNum3==258, ]
temp

f_transformDispIntoDyad(temp)

ddply(a, names(a), f_isConflictual, temp)




res <- f_transformDispIntoDyad(temp)

# Also works for head(data)
test <- ddply(data[1:20, ], c("DispNum3"), f_dispIntoDyad)
test

# This doesn't run. warnings() suggests that a country name shows up more than once
# in a dispute?
res <- ddply(data, c("DispNum3"), f_dispIntoDyad, .inform=TRUE)
# DispNum3 = 258 is the problem. Countries appear more than once.

f_dispIntoDyad(data[data$DispNum3==258,])

res
res <- tapply(data, data$DispNum3, f_dispIntoDyad)
# Finally merge transformed data with the full finalMatrix
