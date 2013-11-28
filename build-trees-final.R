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


# compute lags and first-differences
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

############
# my model

form_mine = as.formula(hostile4 ~ actorMIL + 
	quad1p.l1 + quad2p.l1 + quad3p.l1 + quad4p.l1 +
	event1.d1 + event2.d1 + event3.d1 + event4.d1 + event5.d1 + 
	event6.d1 + event7.d1 + event8.d1 + event9.d1 + event10.d1 +
	event11.d1+ event12.d1+ event13.d1+ event14.d1+ event15.d1 +
	event16.d1+ event17.d1+ event18.d1+ event19.d1+ event20.d1)

# specify a loss matrix or split='gini' or split='information'
# loss_matrix = matrix(c(0,1,100,0), nrow=2, ncol=2)
ctrl = rpart.control(cp=1e-4)
start = Sys.time()
tree_mine = rpart(form_mine, data=data, 
	method='class', control=ctrl,
	parms=list(split='information'))
runtime = Sys.time() - start
runtime

yhat = predict(tree_mine, type='class')
yobs = data$hostile4
length(which(yhat==0 & yobs==1))
sum(as.numeric(yhat!=yobs)) 
sum(yobs)
sum(as.numeric(yhat!=yobs))/sum(yobs) # 0.865

tree_mine
summary(tree_mine)
printcp(tree_mine)
prp(tree_mine)

rsq.rpart(tree_mine)

# snip.rpart(x, toss)
# prune(x, cp=)

tree_mine_pruned = prune(tree_mine, cp=0.00019)
prp(tree_mine_pruned)
fancyRpartPlot(tree_mine_pruned)		

yhat = predict(tree_mine_pruned, type='class')
sum(as.numeric(yhat!=yobs))/sum(yobs) # 0.877

save(tree_mine, file="tree_mine.rda")
save(tree_mine_pruned, file="tree_mine_pruned.rda")

# todo: cross validation
# rpart(xval=k)
# xpred.rpart(tree, xval=k)