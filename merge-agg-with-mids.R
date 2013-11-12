setwd('~/github/gdelt-to-mids')
source('start.R')

setwd("~/Dropbox/gdelt-aggregations")
load("gdelt1979-2012.rda")
dim(agg)
head(agg)
agg$date = as.Date(paste(agg$year, agg$month, "01", sep="-"))

setwd(pathData)
load("monthlymids.rda")
dim(monthlymids)
head(monthlymids)


monthlymids$country_1 = countrycode(monthlymids$CCodeA, "cown", "iso3c")
monthlymids$country_2 = countrycode(monthlymids$CCodeB, "cown", "iso3c")
head(monthlymids)

# handle missingness
monthlymids$country_1 = ifelse(monthlymids$CCodeA==325, "ITA", monthlymids$country_1) # ITALY
monthlymids$country_1 = ifelse(monthlymids$CCodeA==344, "HRV", monthlymids$country_1) # FORMER CROATIA
monthlymids$country_1 = ifelse(monthlymids$CCodeA==345, "SRB", monthlymids$country_1) # FORMER YUGOSLAVIA
monthlymids$country_1 = ifelse(monthlymids$CCodeA==346, "BIH", monthlymids$country_1) # FORMER YUGOSLAVIA
monthlymids$country_1 = ifelse(monthlymids$CCodeA==349, "SVN", monthlymids$country_1) # SLOVENIA
monthlymids$country_1 = ifelse(monthlymids$CCodeA==360, "ROM", monthlymids$country_1) # ROMANIA
monthlymids$country_1 = ifelse(monthlymids$CCodeA==731, "PRK", monthlymids$country_1) # N. KOREA
monthlymids$country_1 = ifelse(monthlymids$CCodeA==713, "TWN", monthlymids$country_1) # TAIWAN
monthlymids$country_1 = ifelse(monthlymids$CCodeA==710, "CHN", monthlymids$country_1) # CHINA

monthlymids$country_2 = ifelse(monthlymids$CCodeB==325, "ITA", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==344, "HRV", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==345, "SRB", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==346, "BIH", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==349, "SVN", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==360, "ROM", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==731, "PRK", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==713, "TWN", monthlymids$country_2)
monthlymids$country_2 = ifelse(monthlymids$CCodeB==710, "CHN", monthlymids$country_2)


# de-directing the dyads 
# (ie duplicating all records in monthlymids and reversing the actor codes)
mm2 = monthlymids
mm2$reverse = 1
monthlymids$reverse = 0
tmp1 = mm2$country_1
tmp2 = mm2$country_2
mm2$country_1 = tmp2
mm2$country_2 = tmp1
head(mm2)

mm = rbind(monthlymids, mm2)
head(mm)
which(is.na(agg$date))
summary(mm$date)

merged = merge(agg, mm, by=c('date', 'country_1', 'country_2'), all.x=TRUE)
head(merged)
dim(merged)
names(merged)
merged = merged[which(merged$year>=1991 & merged$year<=2001), ]
tail(merged)

gdelt.mids.merge = merged
save(gdelt.mids.merge, file="gdelt_mids_merge.rda")
write.csv(gdelt.mids.merge, file="gdelt_agg_mids_merge.csv")


