# prep mids dyadic for merg
setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

# mids dyadic data
load('dailydyad.rda')
dim(dailydyad)

dailydyad$Actor1CountryCode = countrycode(dailydyad$CCodeA, "cown", "iso3c")
dailydyad$Actor2CountryCode = countrycode(dailydyad$CCodeB, "cown", "iso3c")
head(dailydyad)

# handle missingness
sort(unique(dailydyad$CCodeA[which(is.na(dailydyad$Actor1CountryCode))]))
unique(dailydyad$CCodeA[which(!(dailydyad$Actor1CountryCode %in% countries))])
unique(dailydyad$CCodeB[which(!(dailydyad$Actor2CountryCode %in% countries))])
length(which(!(dailydyad$Actor2CountryCode %in% countries)))

dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==325, "ITA", dailydyad$Actor1CountryCode) # ITALY
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==344, "HRV", dailydyad$Actor1CountryCode) # FORMER CROATIA
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==345, "SRB", dailydyad$Actor1CountryCode) # FORMER YUGOSLAVIA
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==346, "BIH", dailydyad$Actor1CountryCode) # FORMER YUGOSLAVIA
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==349, "SVN", dailydyad$Actor1CountryCode) # SLOVENIA
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==360, "ROM", dailydyad$Actor1CountryCode) # ROMANIA
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==731, "PRK", dailydyad$Actor1CountryCode) # N. KOREA
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==713, "TWN", dailydyad$Actor1CountryCode) # TAIWAN
dailydyad$Actor1CountryCode = ifelse(dailydyad$CCodeA==710, "CHN", dailydyad$Actor1CountryCode) # CHINA

dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==325, "ITA", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==344, "HRV", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==345, "SRB", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==346, "BIH", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==349, "SVN", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==360, "ROM", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==731, "PRK", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==713, "TWN", dailydyad$Actor2CountryCode)
dailydyad$Actor2CountryCode = ifelse(dailydyad$CCodeB==710, "CHN", dailydyad$Actor2CountryCode)


# TODO: de-directing the dyads 
# (ie duplicating all records in dailydyad and reversing the actor codes)
dd2 = dailydyad
dd2$reverse = 1
dailydyad$reverse = 0
tmp1 = dd2$Actor1CountryCode
tmp2 = dd2$Actor2CountryCode
dd2$Actor1CountryCode = tmp2
dd2$Actor2CountryCode = tmp1
head(dd2)

dd = rbind(dailydyad, dd2)
dim(dd)
save(dd, file="dd.rda")