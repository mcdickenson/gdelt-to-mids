rm(list=ls())

toLoad <- c("plyr", "countrycode", "dplyr", "data.table", "reshape2", "zoo")
lapply(toLoad, library, character.only=TRUE)

data <- read.csv("../data/MID/MIDB_4.0.csv", as.is=TRUE)
names(data)

# ---- Step 1: Create the full matrix of dyad months (very sparse) ----

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


# ---- Step 2: Transform dispute data into matrix of dyad month ----

# Create the matrix of conflictual dyad months from original data
# Test on one dispute. Then later apply these functions to all other disputes,
# using plyr

# Check if a dyadmonth is in conflict. Dyadmonth is a one row data frame
f_isConflictual <- function(dyadmonth, ref) {
  stateA <- dyadmonth[1, 1]
  stateB <- dyadmonth[1, 2]
  
  currentMonth <- as.yearmon(paste(dyadmonth[1, 3], dyadmonth[1, 4], sep="-"), format="%Y-%m") 
  
  # Remember that in a dispute, a state may appear multiple times, in multiple rows. So,
  
  # Check which row in the REFerence dataframe matches with currentMonth
  # There should be only one match, 
  # i.e. matchMonthA is a logical vector with AT MOST one element = T
  stMonthA <- as.yearmon(paste(ref$StYear[ref$StAbb==stateA], ref$StMon[ref$StAbb==stateA], 
                                sep="-"), format="%Y-%m")
  endMonthA <- as.yearmon(paste(ref$EndYear[ref$StAbb==stateA], ref$EndMon[ref$StAbb==stateA], 
                                  sep="-"), format="%Y-%m")
  matchMonthA <- (currentMonth >= stMonthA) & (currentMonth <= endMonthA)
  
  stMonthB <- as.yearmon(paste(ref$StYear[ref$StAbb==stateB], ref$StMon[ref$StAbb==stateB], 
                               sep="-"), format="%Y-%m")
  endMonthB <- as.yearmon(paste(ref$EndYear[ref$StAbb==stateB], ref$EndMon[ref$StAbb==stateB], 
                                sep="-"), format="%Y-%m")
  matchMonthB <- (currentMonth >= stMonthB) & (currentMonth <= endMonthB)
  
  # Check side using the row/micro-conflict that matches currentMonth
  # This ensures correct result even if countries switch side across rows/micro-conflicts
  conflict <- ref$SideA[ref$StAbb==stateA][matchMonthA] != 
    ref$SideA[ref$StAbb==stateB][matchMonthB]
  # If the currentMonth does not match any row then conflict is length 0, so:
  conflict <- ifelse(length(conflict)==0, FALSE, conflict)
  
  # Do similarly for other factor
  fatalityA <- ref$Fatality[ref$StAbb==stateA][matchMonthA]
  fatalityB <- ref$Fatality[ref$StAbb==stateB][matchMonthB]

  fatalityA <- ifelse(length(fatalityA)==0, NA, fatalityA)
  fatalityB <- ifelse(length(fatalityB)==0, NA, fatalityB)
  
  hostlevA <- ref$HostLev[ref$StAbb==stateA][matchMonthA]
  hostlevB <- ref$HostLev[ref$StAbb==stateB][matchMonthB]
  hostlevA <- ifelse(length(hostlevA)==0, NA, hostlevA)
  hostlevB <- ifelse(length(hostlevB)==0, NA, hostlevB)
  
  return(data.frame(conflict, fatalityA, fatalityB, hostlevA, hostlevB))
}

# Function that takes one dispute and turn into dyads conflict
f_genDyadMonthFromDisp <- function(ref) {
  years <- c(min(ref$StYear):max(ref$StYear))
  months <- c(1:12)
  month_years <- expand.grid(years, months, stringsAsFactors=FALSE)
  
  countries <- as.character(unique(ref$StAbb))

  if (length(countries) > 2) {
    dyads <- t(combn(countries, 2))
    dyads <- data.frame(dyads[order(dyads[, 1], dyads[, 2]), ], stringsAsFactors=FALSE)
  } else {
    dyads <- data.frame(countries[1], countries[2])
  }
  
  
  # Match each dyad with each month. Had to temporarily join 2 countries into 1 var
  # then split again (ideal?)

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

# Test one one dispute; 3429 is a conflict with 3 state
# 298 is motherfucking WW 2!
temp <- data[data$DispNum3==3429, ]
temp
system.time(res <- f_transformDispIntoDyad(temp))

# Test for several disputes
temp2 <- head(data)
table(temp2$DispNum3)
system.time(res2 <- ddply(temp2, c("DispNum3"), f_transformDispIntoDyad))

# Do it for the entire MID 4.0 dataset
dataPost1990 <- data[data$StYear>=1990, ]
system.time(finalRes <- ddply(dataPost1990, c("DispNum3"), f_transformDispIntoDyad))

write.csv(finalRes, "dyad_month_MID_post1990.csv")


# ---- Step 3: Merge the full matrix of dyad month with the one matrix got via transformation ----