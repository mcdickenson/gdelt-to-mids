import datetime as dt
from collections import defaultdict
import matplotlib
import numpy as np 
import pandas 
from pandas import * 
from sklearn import datasets
from sklearn import svm 
from sklearn.linear_model import LogisticRegression

# from path import path
# clf = svm.SVC(gamma=0.001, C=100.)
# clf.fit(digits.data[:-1], digits.target[:-1])
# clf.predict(digits.data[-1])

# train = pd.DataFrame(train_raw, columns = train_raw)
train = read_csv('/Users/mcdickenson/github/gdelt-to-mids/data/train.csv', iterator=True, chunksize=100000)
chunk = train.get_chunk()

chunk.head()
chunk.tail()
chunk.index # row names
chunk.columns # col names 
chunk.describe()
chunk.DispNum.values

y = chunk.HostlevA
y = y.fillna(0)
y.values
y[y>0] = 1 
y.describe()

X = chunk[['EventCode', 'EventBaseCode', 'EventRootCode', 'QuadClass', 'GoldsteinScale', 'AvgTone']]
X.describe()
logit = LogisticRegression().fit(X, y)
logit

chunk2 = train.get_chunk()
y_obs = chunk2.HostlevA
y_obs = y.fillna(0)
y_obs[y_obs>0] =1
y_obs.describe()

X_new = chunk2[['EventCode', 'EventBaseCode', 'EventRootCode', 'QuadClass', 'GoldsteinScale', 'AvgTone']]
p_pred = logit.predict_proba(X_new)
p_pred[[1]]
pp = DataFrame(p_pred)
pp.columns
pp_pred = pp[[1]]
y_pred = logit.predict(X_new)

brier = pp_pred.join(y_obs, how='outer')

brier[2] = brier[1] - brier['HostlevA']
brier[3] = brier[2]**2
bs = np.mean(brier[3])
bs

# clm = svm.SVC(gamma=0.001, C=100.)
# clm.fit(train)
