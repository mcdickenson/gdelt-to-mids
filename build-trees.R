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
load('output1.rda')
dim(newdata)
data = newdata[1:100000, ]
dim(data)
names(data)
# todo: consider doing a complete-case analysis

# dvs: HostlevMax, hostile1, ..., hostile5

# tree using current variables
# form_current = as.formula(HostlevMax ~ actorMIL + quad1 + quad2 + quad3 + quad4)
form_current = as.formula(HostlevMax ~ actorMIL + 
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

# todo: consider rpart.control(minsplit=x, cp=y, xval=n, maxdepth=k)

# tree using lagged variables

# tree using first-differences

# tree using quad percentages

# tree using first-differences and quad percentages