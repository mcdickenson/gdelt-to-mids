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

# todo: consider doing a complete-case analysis

# dvs: HostlevMax, hostile1, ..., hostile5

# tree using current variables
form_current = as.formula(HostlevMax ~ actorMIL + quad1 + quad2 + quad3 + quad4)

# start = Sys.time()
tree_current = rpart(form_current, data=data)
# runtime = Sys.time() - start
# runtime

summary(tree_current)

plot(tree_current)
prp(tree_current)

# todo: consider rpart.control(minsplit=x, cp=y, xval=n, maxdepth=k)

# tree using lagged variables

# tree using first-differences

# tree using quad percentages

# tree using first-differences and quad percentages