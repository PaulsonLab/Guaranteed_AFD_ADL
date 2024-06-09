import torch
import numpy as np

#Finds 2norm of torch tensor, numpy array, or list.
def dist(a,b=None):
    tot = 0
    if type(a) == torch.tensor:
        if b == None:
            return torch.linalg.vector_norm(a)
        else:
            return torch.linalg.vector_norm(a-b)
    elif type(a) == np.array:
        if b == None:
            return np.linalg.norm(a)
        else:
            return np.linalg.norm(a-b)
    else:
        a = np.array(a)
        if b == None:
            return np.linalg.norm(a)
        else:
            b = np.array(b)
            return np.linalg.norm(a-b)
