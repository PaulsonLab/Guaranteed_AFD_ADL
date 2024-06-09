import torch
from scipy.io import loadmat
from Train import train
from OMLT import OMLT
import numpy as np
from dist import dist
from scipy.stats.qmc import Sobol

#matlab engine
from matlab import engine
from matlab import double as mldb
eng = engine.start_matlab()

eng.cd(r'PATH to Matlab code', nargout=1)
eng.addpath(eng.genpath(r'PATH to CORA'), nargout=0)
eng.addpath(eng.genpath(r'PATH to general fault diagnosis folder'), nargout=0)
eng.addpath(eng.genpath(r'PATH to Yalmip'), nargout=0)


#Import data
data = loadmat('PATH to initial dataset')
X = data['train_u'].T
Y = data['y']

train_X = torch.tensor(X).float()
train_Y = torch.tensor(Y).float()
#print('Data in, train_X size = ',train_X.size())
    

#Function to find optimal separations inputs.
def OptimalPointLoop(its,alp,dims):
    #Initialize Parameters
    incumbent = []
    #CSTR problem needs 2 ranges labeled trange and crange defaulting to 100 and 1 respectively.
    trange = mldb(100)
    crange = mldb(1)
    #Linear problem needs 1 range 20 for normal, 25 for state constrained.
    urange = mldb(20)

    #To not change the initial sets as we iterate.
    ltr_X = train_X
    ltr_Y = train_Y
    
    
    #Loop through the active learning process.
    for j in range(its):
        #Find current incumbent
        opt_pt = [1000]
        d = 1e10
        for i in range(len(ltr_X)):
            if ltr_Y[i] == 0:
                if d > dist(ltr_X[i]):
                    opt_pt = ltr_X[i]
                    d = dist(opt_pt)
        incumbent.append(opt_pt)
        
        #Set energy bound for proposed active learning method.
        maxE = d
        
        #Train DNN on current data. (epochs, learning rate, batch size, depth-1, initial width, inputs to train on, outputs to train on, dimensions of input)
        myDNN = train(1000,0.0008,200,2,20,ltr_X,ltr_Y,dims)
        
        #Sobol dense sample inside energy bound region.
        ds = torch.tensor(Sobol(dims).random(131072)*maxE-maxE/2,dtype=torch.float)
        #Predict sobol samples output.
        dstv = myDNN(ds)
        #Turn predictions from logit to probability space.
        dstvprob = np.exp(dstv.detach().numpy())/(1+np.exp(dstv.detach().numpy()))
        
        
        #Active Learning Batch.
        #OMLT solve where criteria is the predicted probability of overlapping.
        bestpts = torch.zeros(alp,dims)
        sol = (OMLT(myDNN,dims,criteria=.7))
        bestpts[0,:] = torch.tensor(sol).view(1,dims)
        sol = (OMLT(myDNN,dims,criteria=.6))
        bestpts[1,:] = torch.tensor(sol).view(1,dims)
        sol = (OMLT(myDNN,dims,criteria=.5))
        bestpts[2,:] = torch.tensor(sol).view(1,dims)
        sol = (OMLT(myDNN,dims,criteria=.4))
        bestpts[3,:] = torch.tensor(sol).view(1,dims)
        

        #Create a subset of the dense sample and its predicted values such that all points have a lower energy than maxE.
        ssds = None
        ssdstvprob = []
        for i in range(len(ds)):
            if dist(ds[i]) <= maxE:
                if ssds == None:
                    ssds = ds[i].view(1,dims)
                else:
                    ssds = torch.cat((ssds,ds[i].view(1,dims)),0)
                ssdstvprob.append(dstvprob[i])
        
        ssdstvprob = np.array(ssdstvprob)

        #Calcualte the Shannon Entropy for the points in the subset.
        entropy = -ssdstvprob*np.log(ssdstvprob+1e-10)-(1-ssdstvprob)*np.log(1-ssdstvprob+1e-10)
        
        #Find active learning points - 4 new points with the highest Shannon Entropy.
        bestpti =  -1
        for i in range(alp-4):
            bestpti = np.argmax(entropy)
            bestpts[i+4,:] = ssds[bestpti]
            
            entropy = np.delete(entropy, bestpti)
            ssds = torch.cat([ssds[:bestpti], ssds[bestpti+1:]])
        
        #print(bestpts)
        
        #Get the true value for actively learned points and append new points and value to training data for next iteration.
        gtv = 0
        for bestpt in bestpts:
            #Make sure to change input arguments for the range if changing from CSTR problem to Linear problem example.
            #Its called activeLearning for CSTR problem and GetTrueValue... for the linear problems.
            gtv = eng.GetTrueValue(mldb(vector=bestpt.detach().tolist()),urange)

            ltr_X = torch.cat((ltr_X,bestpt.view(-1,dims)))
            ltr_Y = torch.cat((ltr_Y,torch.tensor(gtv).view(-1,1)))
        
        #Print current iteration.
        print(j)
        
    #Return all found inputs and their resulting output as well as the best point in the set over each learning iteration.
    return ltr_X, ltr_Y, incumbent


#Make sure to set dimensions correct.
pts, ptstv, incumbent = OptimalPointLoop(30,16,8)

#Find final optimal point.
opt_pt = [1000]
for i in range(len(pts)):
    if ptstv[i] == 0:
        if dist(opt_pt) > dist(pts[i]):
            opt_pt = pts[i]

print(opt_pt)
print(dist(opt_pt))
incumbent.append(opt_pt)
np.savez('PATH to save data of the run',incumbent,pts,ptstv)

