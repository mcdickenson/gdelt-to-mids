rm(list=ls())

toLoad <- c("countrycode", "dplyr", "data.table", "reshape2")
lapply(toLoad, library, character.only=TRUE)

data <- read.csv("../data/MID/MIDB_4.0.csv")
names(data)