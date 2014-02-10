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

finalMatrix <- expand.grid(paste(dyads[,1], dyads[,2]),
                           paste(month_years[,1], month_years[,2]),
                           stringsAsFactors = FALSE)
finalMatrix2 <- cbind(data.frame(do.call(rbind, strsplit(finalMatrix$Var1, " "))),
                      data.frame(do.call(rbind, strsplit(finalMatrix$Var2, " "))))

# Create the matrix of conflictual dyad months

f_isConflictual <- function(dyad, ref) {
  conflict <- ref$SideA[ref$StAbb==dyad[1]] != ref$SideA[ref$StAbb==dyad[2]]
  return(conflict)
}

f_dispIntoDyad <- function(df) {
  dyads <- t(combn(as.character(df$StAbb), 2))
  dyads <- cbind(dyads, apply(dyads, 1, f_isConflictual, df))
  return(dyads)
}

df <- data[data$DispNum3==3429, ]
f_dispIntoDyad(df)

a <- head(data)
res <- ddply(a, c("DispNum3"), f_dispIntoDyad)
res
# Finally merge the two matrix, keeping the info from the conflictual one
