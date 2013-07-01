setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

agg = read.csv("1979-2001-agg.csv", as.is=TRUE)
dim(agg)
head(agg)
tail(agg)

quad1 = c("event1", "event2", "event3", "event4", "event5")
quad2 = c("event6", "event7", "event8", "event9")
quad3 = c("event10", "event11", "event12", "event13", "event14")
quad4 = c("event15", "event16", "event17", "event18", "event19", "event20")

agg$quad1 = rowSums(agg[ , quad1]) # verbal cooperation
agg$quad2 = rowSums(agg[ , quad2]) # material cooperation
agg$quad3 = rowSums(agg[ , quad3]) # verbal conflict
agg$quad4 = rowSums(agg[ , quad4]) # material conflict
agg$total = rowSums(agg[ , c(quad1, quad2, quad3, quad4)])

agg$quad1p = agg$quad1/ (agg$total + .01)
agg$quad2p = agg$quad2/ (agg$total + .01)
agg$quad3p = agg$quad3/ (agg$total + .01)
agg$quad4p = agg$quad4/ (agg$total + .01)
head(agg)

agg$mo = ifelse(agg$month<10, paste("0", agg$month, sep=""), as.character(agg$month) )
agg$yrmo = paste(agg$year, agg$mo, "01", sep="-")
agg$date = as.Date(agg$yrmo, format="%Y-%m-%d")
head(agg)

sort(unique(agg$country_1))
usarus = agg[which(agg$country_1=="USA" & agg$country_2=="RUS"), ]
rususa = agg[which(agg$country_2=="RUS" & agg$country_1=="USA"), ]

head(usarus)
setwd("~/desktop")
pdf("usa-rus1.pdf")
plot(usarus$date, usarus$quad1, type='l', col='blue',
	main="USA-RUS", 
	xlab="Date", ylab="Event Count",
	ylim=c(0,900))
lines(usarus$date, usarus$quad2, type='l')
lines(usarus$date, usarus$quad3, type='l', col='green')
lines(usarus$date, usarus$quad4, type='l', col='red')
legend("topleft", 
	legend=c("Verbal cooperation", "Material Cooperation", "Verbal conflict", "Material conflict"), 
	col=c("blue", "black", "green", "red"),
	pch=16)
dev.off()

pdf("usa-rus2.pdf")
plot(usarus$date, usarus$quad1p, type='l', col='blue',
	main="USA-RUS", 
	xlab="Date", ylab="Proportion of Events",
	ylim=c(0,1))
lines(usarus$date, usarus$quad2p, type='l')
lines(usarus$date, usarus$quad3p, type='l', col='green')
lines(usarus$date, usarus$quad4p, type='l', col='red')
legend("topleft", 
	legend=c("Verbal cooperation", "Material Cooperation", "Verbal conflict", "Material conflict"), 
	col=c("blue", "black", "green", "red"),
	pch=16)
dev.off()

pdf("rus-usa1.pdf")
plot(rususa$date, rususa$quad1, type='l', col='blue',
	main="RUS-USA", 
	xlab="Date", ylab="Event Count",
	ylim=c(0,900))
lines(rususa$date, rususa$quad2, type='l')
lines(rususa$date, rususa$quad3, type='l', col='green')
lines(rususa$date, rususa$quad4, type='l', col='red')
legend("topleft", 
	legend=c("Verbal cooperation", "Material Cooperation", "Verbal conflict", "Material conflict"), 
	col=c("blue", "black", "green", "red"),
	pch=16)
dev.off()

?legend