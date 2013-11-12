# lagger & multilagger: Functions to create lagged variables
#
# lagger works for single vectors, multilagger is for collections of variables bound into a dataframe.


# Brian Greenhill, 8/15/08
# bdgreen@u.washington.edu


# Usage:
# lagger(variable, country, year, laglength)
# multilagger(X, country, year, laglength)

# Arguments:
# variable - a vector corresponding to the variable that you want to lag
# country - a vector (of the same length as the variable vector) containing the country IDs (numeric/character format is OK)
# year - a numeric vector containing the time variable (usually years).  Again this has to be a vector of the same length as the variable vector.
# laglength - the number of periods for which the variable should be lagged.
# X - a data frame containing all the variables that you want to be lagged.

# Values:
# lagger returns a vector of same length as the input vectors containing the values of the lagged variable.  Values for the lead period are replaced with NAs.
# multilagger returns an entire dataframe corresponding to the lagged values of the variables supplied as the X dataframe.  The variable names will all contain the suffix ".l" followed by the number of lagged periods, e.g., gdp -> gdp.l1 after a 1-year lag.


# Example:
#a<-data.frame(country=rep(c("A","B","C","D"),each=10), year=rep(1991:2000, 4), var1=round(runif(40),3), var2=round(runif(40),3))
# var1.lag <- lagger(a$var1, a$country, a$year, 1)
#
# b<-subset(a, select=c(var11, var2))
# b.lags <- multilagger(b, a$country, a$year, 1)



# variable is the variable to be lagged, country is the variable that contains the country IDs, year is the variable that countains the year IDs, laglength is the number of years to be lagged.



# function for lagging single variables:
lagger<-function(variable, country, year, laglength){
	
	country<-as.character(country)
	laggedvar<-rep(NA,length(variable))
	
	leadingNAs<-rep(NA,laglength)
	countryshift<-c(leadingNAs, country[1:(length(country)-laglength)])
	
	variableshift<-c(leadingNAs, variable[1:(length(variable)-laglength)])
	
	replacementrefs<-country==countryshift
	replacementrefs[is.na(replacementrefs)==T]<-FALSE
	laggedvar[replacementrefs]<-variableshift[replacementrefs]
	
	laggedvar
	
	} # close lagger function
	
# function for lagging whole dataframes:
multilagger<-function(X, country, year, laglength, relabel=T){
	
	if(is.data.frame(X)==F) stop("X needs to be a dataframe")
	
	laggedX<-X
	
	for (i in 1:ncol(X)){
		
		laggedX[,i]<-lagger(variable=X[,i], country=country, year=year, laglength=laglength)
		
		} # close i loop
	
	# now append the laglength to the variable names:
	if (relabel==T){
		suffix<-paste(".l",laglength,sep="")
		names(laggedX)<-paste(names(X), suffix, sep="")
		} # close if relabel==T condition
	
	laggedX
	
	} # close multilagger function
	


