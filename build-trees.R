#!/usr/bin/Rscript

# set up workspace
rm(list=ls())
setwd('~/github/gdelt-to-mids')
source('start.R')

# tree libraries
library(rpart)				# Popular decision tree algorithm
library(rattle)				# Fancy tree plot
library(rpart.plot)		# Enhanced tree plots
library(RColorBrewer) # Color selection for fancy tree plot
library(party) 				# Alternative decision tree algorithm
library(partykit) 		# Convert rpart object to BinaryTree
# library(RWeka) 				# Weka decision tree J48

# load data
setwd(pathData)
load('output4.rda')
dim(newdata)
data = newdata[which(data$year<=1998), ]
dim(data)
names(data)

head(data)

# todo: name variables more nicely for final trees
# todo: consider rpart.control(minsplit=x, cp=y, xval=n, maxdepth=k)

# dvs: HostlevMax, hostile1, ..., hostile5
summary(data$HostlevMax)
summary(data$hostile4)
summary(data$hostile5)


# tree using current variables
# form_current = as.formula(HostlevMax ~ actorMIL + quad1 + quad2 + quad3 + quad4)

# best for this dv: 
# form_current = as.formula(HostlevMax ~ actorMIL + 
# 	event1 + event2 + event3 + event4 + event5 + 
# 	event6 + event7 + event8 + event9 + event10 +
# 	event11+ event12+ event13+ event14+ event15 +
# 	event16+ event17+ event18+ event19+ event20)

# not bad:
# form_current = as.formula(hostile4 ~ actorMIL + quad1 + quad2 + quad3 + quad4)

# best so far (lowest mse):
form_current = as.formula(hostile4 ~ actorMIL + 
	event1 + event2 + event3 + event4 + event5 + 
	event6 + event7 + event8 + event9 + event10 +
	event11+ event12+ event13+ event14+ event15 +
	event16+ event17+ event18+ event19+ event20)

start = Sys.time()
tree_current = rpart(form_current, data=data)
runtime = Sys.time() - start
runtime

tree_current
summary(tree_current)
printcp(tree_current)
prp(tree_current)


############
# tree using lagged variables
# form_lagged = as.formula(HostlevMax ~ actorMIL + 
# 	event1.l1 + event2.l1 + event3.l1 + event4.l1 + event5.l1 + 
# 	event6.l1 + event7.l1 + event8.l1 + event9.l1 + event10.l1 +
# 	event11.l1+ event12.l1+ event13.l1+ event14.l1+ event15.l1 +
# 	event16.l1+ event17.l1+ event18.l1+ event19.l1+ event20.l1)

form_lagged = as.formula(hostile4 ~ actorMIL + 
	event1.l1 + event2.l1 + event3.l1 + event4.l1 + event5.l1 + 
	event6.l1 + event7.l1 + event8.l1 + event9.l1 + event10.l1 +
	event11.l1+ event12.l1+ event13.l1+ event14.l1+ event15.l1 +
	event16.l1+ event17.l1+ event18.l1+ event19.l1+ event20.l1)

start = Sys.time()
tree_lagged = rpart(form_lagged, data=data)
runtime = Sys.time() - start
runtime

tree_lagged
summary(tree_lagged)
printcp(tree_lagged)
prp(tree_lagged)

############
# tree using first-differences
quads = paste("quad", 1:4, sep="")
events = paste("event", 1:20, sep="")
vars = c(quads, events)
lag_vars = paste(vars, ".l1", sep="")
lag_vars
# replace NA in lags with 0 
for(i in 1:length(vars)){
	lag = lag_vars[i]
	command = paste("data$", lag, "[which(is.na(data$", lag, "))] = 0" , sep="")
	print(command)
	eval(parse(text=command))
}
length(which(is.na(data$event1.l1)))

diff_vars = paste(vars, ".d1", sep="")
diff_vars
for(i in 1:length(vars)){
	var = vars[i]
	lag = lag_vars[i]
	dif = diff_vars[i]
	command = paste("data$", dif, " = data$", var, " - data$", lag, sep="")
	print(command)
	eval(parse(text=command))
}

# form_diffed = as.formula(HostlevMax ~ actorMIL + 
# 	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
# 	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
# 	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
# 	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

# best so far
form_diffed = as.formula(hostile1 ~ actorMIL + 
	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

ctrl = rpart.control(cp=1e-5)
start = Sys.time()
tree_diffed = rpart(form_diffed, data=data, control=ctrl)
runtime = Sys.time() - start
runtime

tree_diffed
summary(tree_diffed)
printcp(tree_diffed)
prp(tree_diffed)

############
# tree using quad percentages
names(data)
data$quadsum = data$quad1 + data$quad2 + data$quad3 + data$quad4 + .001
head(data)
data$quad1p = data$quad1 / data$quadsum
data$quad2p = data$quad2 / data$quadsum
data$quad3p = data$quad3 / data$quadsum
data$quad4p = data$quad4 / data$quadsum

data$quadsum.l1 = data$quad1.l1 + data$quad2.l1 + data$quad3.l1 + data$quad4.l1 + .001
head(data)
data$quad1p.l1 = data$quad1.l1 / data$quadsum.l1
data$quad2p.l1 = data$quad2.l1 / data$quadsum.l1
data$quad3p.l1 = data$quad3.l1 / data$quadsum.l1
data$quad4p.l1 = data$quad4.l1 / data$quadsum.l1

# form_quadp = as.formula(HostlevMax ~ actorMIL + 
# 	quad1p + quad2p + quad3p + quad4p )

form_quadp = as.formula(hostile4 ~ actorMIL + 
	quad1p + quad2p + quad3p + quad4p )

start = Sys.time()
tree_quadp = rpart(form_quadp, data=data)
runtime = Sys.time() - start
runtime

tree_quadp
summary(tree_quadp)
printcp(tree_quadp)
prp(tree_quadp)

############
# kitchen sink

# form_sink = as.formula(HostlevMax ~ actorMIL + 
# 	# quad1  + quad2  + quad3  + quad4  +
# 	quad1p + quad2p + quad3p + quad4p +
# 	quad1.l1 + quad2.l1 + quad3.l1 + quad4.l1 +
# 	quad1.d1 + quad2.d1 + quad3.d1 + quad4.d1 +
# 	event1 + event2 + event3 + event4 + event5 + 
# 	event6 + event7 + event8 + event9 + event10 +
# 	event11+ event12+ event13+ event14+ event15 +
# 	event16+ event17+ event18+ event19+ event20 +
# 	event1.l1 + event2.l1 + event3.l1 + event4.l1 + event5.l1 + 
# 	event6.l1 + event7.l1 + event8.l1 + event9.l1 + event10.l1 +
# 	event11.l1+ event12.l1+ event13.l1+ event14.l1+ event15.l1 +
# 	event16.l1+ event17.l1+ event18.l1+ event19.l1+ event20.l1 +
# 	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
# 	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
# 	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
# 	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

form_sink = as.formula(hostile4 ~ actorMIL + 
	quad1  + quad2  + quad3  + quad4  +
	quad1p + quad2p + quad3p + quad4p +
	quad1.l1 + quad2.l1 + quad3.l1 + quad4.l1 +
	quad1.d1 + quad2.d1 + quad3.d1 + quad4.d1 +
	event1 + event2 + event3 + event4 + event5 + 
	event6 + event7 + event8 + event9 + event10 +
	event11+ event12+ event13+ event14+ event15 +
	event16+ event17+ event18+ event19+ event20 +
	event1.l1 + event2.l1 + event3.l1 + event4.l1 + event5.l1 + 
	event6.l1 + event7.l1 + event8.l1 + event9.l1 + event10.l1 +
	event11.l1+ event12.l1+ event13.l1+ event14.l1+ event15.l1 +
	event16.l1+ event17.l1+ event18.l1+ event19.l1+ event20.l1 +
	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

start = Sys.time()
tree_sink = rpart(form_sink, data=data)
runtime = Sys.time() - start
runtime

tree_sink
summary(tree_sink)
printcp(tree_sink)
prp(tree_sink)

############
# my model

form_mine = as.formula(HostlevMax ~ actorMIL + 
	# quad1  + quad2  + quad3  + quad4  +
	quad1p.l1 + quad2p.l1 + quad3p.l1 + quad4p.l1 +
	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

form_mine = as.formula(hostile4 ~ actorMIL + 
	# quad1  + quad2  + quad3  + quad4  +
	quad1p.l1 + quad2p.l1 + quad3p.l1 + quad4p.l1 +
	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

start = Sys.time()
tree_mine = rpart(form_mine, data=data)
runtime = Sys.time() - start
runtime

tree_mine
summary(tree_mine)
printcp(tree_mine)
prp(tree_mine)