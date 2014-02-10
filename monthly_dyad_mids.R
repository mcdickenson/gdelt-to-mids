rm(list=ls())

toLoad <- c("countrycode", "dplyr", "data.table", "reshape2")
lapply(toLoad, library, character.only=TRUE)

data <- read.csv("../data/MID/MIDB_4.0.csv")
names(data)

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


temp <- head(finalMatrix)
a <- strsplit(temp$Var1, " ")
new <- cbind(data.frame(do.call(rbind, strsplit(temp$Var1, " "))),
             data.frame(do.call(rbind, strsplit(temp$Var2, " "))))

test <- matrix(c("USA", "USA", "FRA", "UK"), ncol=2)
test2 <- matrix(c(2000, 2000, 1, 2), ncol=2)

paste(test)

expand.grid(paste(test[,1], test[,2]), paste(test2[,1], test2[,2])
