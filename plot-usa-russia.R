setwd('~/github/gdelt-to-mids')
source('start.R')
setwd(pathData)

agg = read.csv("1979-2001-agg.csv", as.is=TRUE)
dim(agg)
head(agg)
tail(agg)

usarus = agg[which(agg$country_1=="USA" & agg$country_2=="RUS"), ]
rususa = agg[which(agg$country_2=="RUS" & agg$country_1=="USA"), ]

compute.quad.counts = function(data) {
  quad1 = c("event1", "event2", "event3", "event4", "event5")
  quad2 = c("event6", "event7", "event8", "event9")
  quad3 = c("event10", "event11", "event12", "event13", "event14")
  quad4 = c("event15", "event16", "event17", "event18", "event19", "event20")
  data$quad1 = rowSums(data[ , quad1]) # verbal cooperation
  data$quad2 = rowSums(data[ , quad2]) # material cooperation
  data$quad3 = rowSums(data[ , quad3]) # verbal conflict
  data$quad4 = rowSums(data[ , quad4]) # material conflict
  
  return(data)
}

plot.event.counts = function(data, title="") {
  data = compute.quad.counts(data)
  
  data$X.Date = as.Date(paste(as.character(data$year), "-", as.character(data$month), "-01", sep=''))
  to.plot = melt(data[,c('quad1', 'quad2', 'quad3', 'quad4', 'X.Date')], 
                 id.vars="X.Date")
  
  p = ggplot(to.plot, aes(x=X.Date, y=value, color=variable)) + 
    geom_line() + xlab("") + ylab("Counts") + theme_bw() + theme(legend.position="top") + 
    labs(title=title) +
    scale_color_discrete(name="Conflict Type", 
                         labels=c("Verbal Cooperation", "Material Cooperation", "Verbal Conflict", "Material Conflict"))
  return(p)
}

setwd("~/desktop")

pdf("usa-rus1.pdf")
plot.event.counts(usarus, "USA-RUS")
dev.off()


pdf("rus-usa1.pdf")
plot.event.counts(rususa, "RUS-USA")
dev.off()