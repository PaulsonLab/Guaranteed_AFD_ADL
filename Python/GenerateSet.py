import numpy as np
from time import time

#Generates an n-dimensional grid with desired number of points npts per dimenson
def GenerateSet(ndim, start, stop, npts, X=None):
    if X is None:
        X = []

    Z = np.linspace(start, stop, npts)

    if len(X) == 0:
        X = np.tile(Z, (ndim, 1)).T
    else:
        X = np.tile(np.array(X), (npts, 1))
        X[:, 0] = np.repeat(Z, len(X) // npts)

    if ndim > 1:
        return GenerateSet(ndim-1, start, stop, npts, X)
    else:
        return X.tolist()



            