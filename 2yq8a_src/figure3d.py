import numpy as np 
import pandas as pd 
from sklearn import linear_model
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score, LeaveOneOut, LeaveOneGroupOut
from sklearn import cross_validation
from sklearn import metrics
from scipy.stats import binom_test
from sklearn.preprocessing import OneHotEncoder
from sklearn.decomposition import PCA
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import make_friedman1
from sklearn.feature_selection import RFECV
from sklearn.feature_selection import RFE
from sklearn.svm import SVC
from sklearn.model_selection import cross_validate
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import train_test_split
from sklearn.model_selection import KFold
from sklearn.model_selection import permutation_test_score
from sklearn import metrics
from sklearn.model_selection import StratifiedKFold

def getData(target, dataPath):
    #----------------------------------------------#
    #return the target data for the chosen condition
    #----------------------------------------------#
    
    if target=='context': 
        payload=prepContextData(dataPath=dataPath+'LS_class_runs_social.csv')
    
    elif target=='opponent':
        payload=prepOppData(dataPath=dataPath+'LS_class_runs_opponent.csv')
    
    return payload
    
def createPredMat(roiList, data): 
    #----------------------------------------------------#
    #create the predictor dataframe based on a list of ROI
    #----------------------------------------------------#
    #demean and devariance (SVCs are sensitive to scale)
    
    PredMat=pd.DataFrame()
    for i in roiList: 
        curr=SelectData(i,data)
        PredMat=pd.concat([PredMat, curr], axis=1)
        
    scaler=StandardScaler(copy=True, with_mean=True, with_std=True).fit(PredMat)
    
    #return np array and col keys
    Xr=scaler.transform(PredMat)
    colCodes=PredMat.columns
        
    return Xr, colCodes

def prepContextData(dataPath):
    #---------------------------------------
    #preprocessing of the opponent dataframe
    #---------------------------------------
    #returns data matrix, label
    
    df = pd.read_csv(dataPath)
    data=df.pivot(index='id',columns='run')
    data.columns=data.columns.map('{0[0]}|{0[1]}'.format) 
    
    #Labels
    yr = np.array(data['social|1']=='social')
    
    #Store into dictionnary
    payload={'data': data, 'yr': yr}
    
    return payload

def prepOppData(dataPath):
    #---------------------------------------
    #preprocessing of the opponent dataframe
    #---------------------------------------
    #returns data matrix, label

    df = pd.read_csv(dataPath)
    df['sID']=df['id'] #keep ID
    df1=df.loc[df['opponent']==1].copy()
    df2=df.loc[df['opponent']==0].copy()
    dataLr=df1.pivot(index='id',columns='run')
    dataLr.columns=dataLr.columns.map('{0[0]}|{0[1]}'.format) 
    dataSeq=df2.pivot(index='id',columns='run')
    dataSeq.columns=dataSeq.columns.map('{0[0]}|{0[1]}'.format) 
    data=pd.concat([dataLr, dataSeq], axis=0)
    data['condition']=data['social|1'] + '_' +data['opponent|1'].map(str)
    
    #multicat prediction
    #-------------------
    #data['labelID']=data['social|1'].map(str)+'_'+data['opponent|1'].map(str)
    #Labels (multicat)
    #yr = np.array(data['labelID'])
    
    #Labels (opponent prediction)
    yr = np.array(data['opponent|1'])
    
    #Store into dictionnary
    payload={'data': data, 'yr': yr}
    
    return payload

def SelectData(roiName, data):
    #---------------------------------------------#
    #Select columns that contain the exact ROI name
    #---------------------------------------------#
    #e.g 'rTP' -> all columns which relate 'rTP' exactly (and not also rTPJ)
    
    #get the full names of the ROI-based features
    roiCols = [col for col in data.columns if '.' in col]
    F=list(set([i.split('.', 1)[1] for i in roiCols]))
    ExactNames = [roiName+'.' + F for F in F]
    
    #sort the list and select data columns
    ExactNames.sort()
    X=data[ExactNames]
    
    return X
    
def getCoefs(Xr, yr, nIter,  colkeys, clf): 
    #----------------------------------------------------------------------------------#
    #get coefficients for the SVC (they cannot be extracted from permutation_test_score)
    #----------------------------------------------------------------------------------#
    
    CoefsDf=pd.DataFrame(columns=colkeys, data=np.zeros((nIter, len(colkeys))))
    for i in range(0, nIter):
        clf.fit(Xr, yr)
        CoefsDf.iloc[i]=clf.coef_
        
    return CoefsDf
    
def getMedianCoefs(CoefsDf): 
    #--------------------------------------------------------------
    #Returns an n-by-m df, sorted with ROI as rows and epoch as cols
    #Contains the median of the coefficients of the linear SVC
    #--------------------------------------------------------------

    #get the mean coefficients
    mCoefs=CoefsDf.median()
    
    #Cut string at the dot into prefix and suffix
    Suffix=sorted(list(set([i.split('.', 1)[1] for i in mCoefs.index])))
    Prefix=sorted(list(set([i.split('.', 1)[0] for i in mCoefs.index])))
    
    #Cut the string of suffix to get trailing int to sort by run
    Suffix=sorted(Suffix, key=lambda x: int(x.split('|')[1]))
    
    #Create dataframe to store information
    mCoefsDf=pd.DataFrame(columns=Suffix, index=Prefix, data=np.zeros((len(Prefix), len(Suffix))))
    
    #Coefs into dataframe
    for s in Suffix:
        for p in Prefix:
            mCoefsDf.loc[p].loc[s]=mCoefs[p+'.'+s]
    
    return mCoefsDf
    
def getPerm(data, Xr, yr, nSim, clf, target): 
    #----------------------------------------------------------------
    #returns the classification accuracy and p-value for permutations
    #----------------------------------------------------------------
    
    print(clf)
    
    #LOO CV schemes
    if target == 'context':
        folds=cross_validation.LeaveOneOut(len(yr))
    elif target=='opponent':
        folds=LeaveOneGroupOut().split(Xr, yr, groups=np.array(data['sID|1']))
    
    #calculate chance-level for p-value determination and compare to scores
    score, permutation_scores, pvalue = permutation_test_score(clf, Xr, yr, cv=folds, scoring='accuracy', n_permutations=nSim, n_jobs=-1, random_state=0, verbose=5) 
    
    #print feedback
    print(score)
    print(pvalue)

    return score, pvalue

def DecoderJob(dataPath, roiList, target, nSim):
    #------------------------------------------#
    #Returns accuracies, p-vals, and coef matrix
    #------------------------------------------#
    
    #load the data and the label
    payload=getData(target, dataPath)
    
    #unpack dict
    data=payload['data']
    yr=payload['yr']
    
    #create predictor matrix
    Xr, colkeys = createPredMat(roiList, data)
    
    #define model: linear support vector machine with regularization
    clf=linear_model.SGDClassifier(max_iter=1000, penalty='elasticnet')
    
    #Get the permutation results
    print(data.shape)
    score, pval=getPerm(data, Xr, yr, nSim, clf, target)
    
    #Get coefficients
    CoefsDf=getCoefs(Xr, yr, nSim, colkeys, clf)
    
    #Take the median and sort into dataframe
    mCoefsDf=getMedianCoefs(CoefsDf)

    return score, pval, mCoefsDf    


#path to datasets
dataPath='/Users/chill/Desktop/SA_project/decoding/'

#define list of features for the Jobs
#ToMList=['PR','rTPJ','lTPJ','dmPFC']
#controlList=['nAc']
roiLists=[['rTPJ', 'dmPFC','lTPJ', 'lTP','rTP','PR']]
targetList=['opponent', 'context']

#define number of sims / permutations
nSim=10000

#Wrapper
resultList=[]
for roiList in roiLists:
    for target in targetList:
        print(roiList)
        print(target)
        output = DecoderJob(dataPath, roiList, target, nSim)
        resultList.append(output)


#----------------------------------------------
#Do factor analysis to show singular dimensions
#----------------------------------------------
#load the data and the label
target='opponent'
payload=getData(target, dataPath)
    
#unpack dict
data=payload['data']
yr=payload['yr']
    
#create predictor matrix
Xr, colkeys = createPredMat(roiLists[0], data) #all ToM regions

df=pd.DataFrame(Xr, columns=colkeys)

import matplotlib
import matplotlib.pyplot as plt
pl=pd.scatter_matrix(df)




#Run factor analysis
from sklearn.decomposition import FactorAnalysis

transformer = FactorAnalysis(1, tol=1e-8, max_iter=1000000)
fa = transformer.fit(Xr)

print(pd.DataFrame(factor.components_,columns=colkeys))



pca = PCA(3).fit(Xr)
pca.components_
pca.explained_variance_ratio_

print(pd.DataFrame(pca.components_,columns=colkeys))

resultList[0][0]
resultList[1][0]
resultList[2][0]
resultList[3][0]




#Store into a daframe for Arkady
idx=['ACC', 'p-val']
cols=['rTPJ_opponent', 'rTPJ_context','dmPFC_opponent','dmPFC_context',
    'lTPJ_opponent','lTPJ_context','nAc_opponent','nAc_context', 
    'lTP_opponent','lTP_context','rTP_opponent','rTP_context','PR_opponent','PR_context']

r=pd.DataFrame(columns=cols, index=idx, data=np.zeros((len(idx), len(cols))))
for u in range(len(cols)):
    for i in range(len(idx)):
        r.loc[idx[i]].loc[cols[u]]=resultList[u][i]

#save df        
r.to_csv('ACC_scores_perRoi.csv')
#------------------------------
#Decoding by region (nSim=1000)
#------------------------------
#PR, opponent = .55 / .126
#PR, context = .55 / .276
#dmPFC, opponent = .63 / .0089
#dmPFC PR = .55 / .276
#rTPJ, opponent = .59 / .036
#rTPJ, context = .65 / .024
#nACC, opponent.5 / .430
#nACC, context = .53 / .344
#rTP, opponent = .56 / .082
#rTP, context = .53 / .309
#lTPJ, opponent = .6 / .028
#lTPJ, context = .6 / .110
#lTP, opponent = .65 / .002
#lTP, context = .56 / .180
 
#----------------------------------------
#Canonical TOM network: rTPJ, lTPJ, dmPFC
#----------------------------------------
#opponent: .6 / .032
#context: .51 / .36

#PR, vmPFC, nAc
#opponent: .61 / 0.009
#context: .53 / .27





