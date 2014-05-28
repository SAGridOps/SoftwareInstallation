import time
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.svm import LinearSVC
from sklearn.ensemble import RandomForestClassifier

timer = time.time()

classifiers = [LogisticRegression(), LinearSVC(), KNeighborsClassifier(), 
               RandomForestClassifier(), SVC()]

XandY = np.loadtxt('train1000.csv', delimiter=',', skiprows=1)
np.random.shuffle(XandY)
X = XandY[:,1:]
Y = XandY[:,0]
nX = np.shape(X)[0]

XTrain = X[:0.7*nX,:]
YTrain = Y[:0.7*nX]
XTest = X[0.7*nX:,:]
YTest = Y[0.7*nX:]

for classifier in classifiers:
    clf = classifier
    clf.fit(XTrain,YTrain)
    trainingAccuracy =  clf.score(XTrain,YTrain)
    testAccuracy = clf.score(XTest,YTest)
    print str(classifier)
    print 'training accuracy = ' + str(trainingAccuracy)
    print ' test accuracy is = ' + str(testAccuracy)
    print "**********"
    print "\n"

print "\n"
print("total time = " + str(time.time()-timer) + " secs")