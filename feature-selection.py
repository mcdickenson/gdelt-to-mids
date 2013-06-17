import datetime as dt
from collections import defaultdict
import matplotlib
import numpy as np 
import pandas 
from pandas import * 
from sklearn import datasets
from sklearn import svm 
from sklearn import grid_search 
from sklearn.linear_model import LogisticRegression
import statsmodels.api as sm 

trainsub1 = read_csv('/Users/mcdickenson/github/gdelt-to-mids/data/trainsub1.csv', sep=',')
trainsub = trainsub1 

# description
trainsub.head()
trainsub.tail()
trainsub.index # row names
trainsub.columns # col names 
trainsub.describe()
trainsub.mid.values

# logit model 
y = trainsub.mid 
y.values
y.describe()

X = trainsub[['EventCode', 'EventBaseCode', 'EventRootCode', 'QuadClass', 'GoldsteinScale', 'AvgTone']]
X.describe()
logit = sm.Logit(y, X)
result = logit.fit()
result.summary()

# another logistic regression
logit2 = LogisticRegression().fit(X, y)
logit2
trainsub2 = read_csv('/Users/mcdickenson/github/gdelt-to-mids/data/trainsub2.csv', sep=',')
X_new = trainsub2[['EventCode', 'EventBaseCode', 'EventRootCode', 'QuadClass', 'GoldsteinScale', 'AvgTone']]
y_obs = trainsub2.mid
pp = logit2.predict_proba(X_new)
pp = DataFrame(pp)
pp = pp[[1]]
pp.describe()

def brier(obs, pred):
	pred = DataFrame(pred)
	data = pred.join(obs, how='outer')
	data[2] = data[1] - data['mid']
	data[3] = data[2]**2
	score = np.mean(data[3])
	return score 

bs = brier(pp, y_obs) # .016 

# svm 
svm1 = svm.SVC(gamma=0.0000001, C=10.)
svm1.fit(X, y)
# can take a while under certain specifications

# in-sample fit 
y_pred = svm1.predict(X) # all zeroes 
y_pred.describe() # all zeroes 

pred = DataFrame(y_pred)
pred.columns = ['pred']
data = pred.join(y_obs, how='right')
data['tp'] = 0 
data['tp'][(data.mid==1) & (data.pred==1)] = 1
data['fp'] = 0 
data['fp'][(data.mid==0) & (data.pred==1)]
data['fn'] = 0 
data['fn'][(data['mid']==1) & (data['pred']==0)] = 1

# out-sample fit 
y_new_pred = sv1.predict(X_new) # all zeroes
new_pred = DataFrame(new_pred)

# grid search for gamma specification
gammas = np.logspace(-6, -1, 10)
svc = svm.SVC()
clf = grid_search.GridSearchCV(estimator=svc, 
	param_grid=dict(gamma=gammas), 
	n_jobs=-1)
clf.fit(X, y)
clf.best_score_
clf.best_estimator.gamma 
# gamma = 1**(-6)


# untested, probably needs tweaking 
def pnr(obs, pred):
	pred = DataFrame(pred)
	data = pred.join(obs, how='outer')
	data[3] = 0 
	data[3][data.mid==1 & data[0]==1] = 1 
	data[4] = 0 
	data[4][data.mid==1 & data[0]==0] = 1
	tp = sum(data[3])
	fp = len(pred.index) - tp 
	fn = sum(data[4])
	precis = tp / (tp + fp)
	print "precision: ", precis 
	recall = tp / (tp + fn)
	print "recall: ", recall 

# pred = DataFrame(y_pred)

# data = pd.concat(pred, y)

# data = pred.join(y, how='outer', colnames=c('pred', 'actual'))
# data[3] = 0 



