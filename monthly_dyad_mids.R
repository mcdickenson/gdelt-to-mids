rm(list=ls())

toLoad <- c("plyr", "countrycode", "dplyr", "data.table", "reshape2")
lapply(toLoad, library, character.only=TRUE)

data <- read.csv("../data/MID/MIDB_4.0.csv")
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
temp <- data[data$DispNum3==3429, ]
temp
dyads <- t(combn(as.character(temp$StAbb), 2))
dyads <- expand.grid(paste(dyads[,1], dyads[,2]),
                     paste(month_years[,1], month_years[,2]),
                     stringsAsFactors = FALSE)
dyads <- data.frame(do.call(rbind, strsplit(dyads$Var1, " ")),
               do.call(rbind, strsplit(dyads$Var2, " ")),
               stringsAsFactors=FALSE)

# Check if a dyad is in ever conflict. 
# Extension is to check according to month as well
f_isConflictual <- function(dyad, ref) {
  conflict <- ref$SideA[ref$StAbb==dyad[1]] != ref$SideA[ref$StAbb==dyad[2]]
  return(conflict)
}

# Function that takes one dispute and turn into dyads conflict
f_dispIntoDyad <- function(df) {
  dyads <- t(combn(as.character(df$StAbb), 2))
  dyads <- cbind(dyads, apply(dyads, 1, f_isConflictual, df))
  return(dyads)
}

# This works for one dispute
df <- data[data$DispNum3==3429, ]
f_dispIntoDyad(df)

# This doesn't run. warnings() suggests that a country name shows up more than once
# in a dispute?
a <- head(data)
res <- ddply(a, c("DispNum3"), f_dispIntoDyad)
res

# Finally merge transformed data with the full finalMatrix
