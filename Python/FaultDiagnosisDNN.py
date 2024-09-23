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
eng.cd(r'C:\\Users\\Nate\\Documents\\MATLAB\\FaultDiagnosis\\DoMPCCSTR', nargout=1)
eng.addpath(eng.genpath(r'C:\\Users\\Nate\\Documents\\MATLAB\\CORA-master'), nargout=0)
eng.addpath(eng.genpath(r'C:\\Users\\Nate\\Documents\\MATLAB\\FaultDiagnosis'), nargout=0)
eng.addpath(eng.genpath(r'C:\\Users\\Nate\\Documents\\MATLAB\\YALMIP-master'), nargout=0)



#Import data
data = loadmat('C:\\Users\\Nate\\Documents\\MATLAB\\FaultDiagnosis\\DoMPCCSTR\\10D512-1.mat')
X = data['train_u'].T
Y = data['y']

train_X = torch.tensor(X).float()
train_Y = torch.tensor(Y).float()
#print('Data in, train_X size = ',train_X.size())
    



#Loop training neural networks to find the optimal inputs
def OptimalPointLoop(its,alp,dims):
    #Initialize Parameters
    wmdir = 'C:/Users/Nate/Desktop/School/Paulson Lab/FaultDetection/model'
    incumbent = []
    crange = mldb(1) #For the linear problem
    trange = mldb(100) #For the simple cstr
    urange = mldb(25) #For the simple cstr
    Frange = mldb(4.27) #For the complex cstr
    Q_dotrange = mldb(8211) #For the complex cstr

    ltr_X = train_X
    ltr_Y = train_Y
    
    
    #Loop through the active learning process
    for j in range(its):
        #Find incumbent
        opt_pt = [1000]
        d = 1e10
        for i in range(len(ltr_X)):
            if ltr_Y[i] == 0:
                if d > dist(ltr_X[i]):
                    opt_pt = ltr_X[i]
                    d = dist(opt_pt)
        
        maxE = d
        
        incumbent.append(opt_pt)
        #Initial Train
        myDNN = train(1000,0.0008,200,2,20,ltr_X,ltr_Y,dims)
        
        ds = torch.tensor(Sobol(dims).random(131072)*maxE-maxE/2,dtype=torch.float)
        dstv = myDNN(ds)
        dstvprob = np.exp(dstv.detach().numpy())/(1+np.exp(dstv.detach().numpy()))
        
        
        #Active Learning Batch
        #OMLT solve
        bestpts = torch.zeros(alp,dims)
        sol = (OMLT(myDNN,dims,criteria=.7))
        bestpts[0,:] = torch.tensor(sol).view(1,dims)
        sol = (OMLT(myDNN,dims,criteria=.6))
        bestpts[1,:] = torch.tensor(sol).view(1,dims)
        sol = (OMLT(myDNN,dims,criteria=.5))
        bestpts[2,:] = torch.tensor(sol).view(1,dims)
        sol = (OMLT(myDNN,dims,criteria=.4))
        bestpts[3,:] = torch.tensor(sol).view(1,dims)
        
        
        
        

        
        #Create a subset of the dense sampling and its predicted values such that all points have a lower energy than maxE
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
        print(len(ssdstvprob))
        #Calcualte the entropy for the points in the subset
        entropy = -ssdstvprob*np.log(ssdstvprob+1e-10)-(1-ssdstvprob)*np.log(1-ssdstvprob+1e-10)
        
        #Find the best points
        bestpti =  -1
        for i in range(alp-4):
            bestpti = np.argmax(entropy)
            bestpts[i+4,:] = ssds[bestpti]
            
            entropy = np.delete(entropy, bestpti)
            ssds = torch.cat([ssds[:bestpti], ssds[bestpti+1:]])
        
        #print(bestpts)
        
        gtv = 0
        for bestpt in bestpts:
            gtv = eng.activeLearning(mldb(vector=bestpt.detach().tolist()),Frange,Q_dotrange)

            ltr_X = torch.cat((ltr_X,bestpt.view(-1,dims)))
            ltr_Y = torch.cat((ltr_Y,torch.tensor(gtv).view(-1,1)))
        
        print(j)
    return ltr_X, ltr_Y, incumbent



#Check for bottlenecks
import cProfile
import pstats
profiler = cProfile.Profile()

profiler.enable()

pts, ptstv, incumbent = OptimalPointLoop(30,16,10)

#Find optimal soln

opt_pt = [1000]
for i in range(len(pts)):
    if ptstv[i] == 0:
        if dist(opt_pt) > dist(pts[i]):
            opt_pt = pts[i]

print(opt_pt)
print(dist(opt_pt))
incumbent.append(opt_pt)
np.savez('C:\\Users\\Nate\\Desktop\\School\\Paulson Lab\\FaultDetection\\Python\\do-mpc_CSTR\\soln-1',incumbent,pts,ptstv)

print(opt_pt.tolist())


# Stop profiling
profiler.disable()

# Print the profiling results
stats = pstats.Stats(profiler)

# Sort the functions by cumulative time
stats.sort_stats('cumulative')

# Print the top 10 functions
print("Top 10 functions by runtime:")
stats.print_stats(20)




















