import torch.nn as nn

#Constructs scalable dnn for auto ML optimization
class AMLDNNPyramid(nn.Module):
  def __init__(self,nin,nout,num_layers,initial_size):
    super(AMLDNNPyramid,self).__init__()
    self.activation = nn.ReLU()
    self.num_layers=num_layers
    self.initial_size=initial_size
    self.nout=nout
    self.nin = nin
    nodes = []
    for i in range(self.num_layers+1):
        nodes.append(int(-(self.initial_size-self.nout)/(self.num_layers+1)*i+self.initial_size))

    self.Densein = nn.Linear(nin,initial_size)
    self.Dense = nn.ModuleList([nn.Linear(nodes[i],nodes[i+1]) for i in range(self.num_layers)])
    self.Denseout = nn.Linear(nodes[len(nodes)-1],nout)
#    print(self.Densein)
#    print(self.Dense)
#    print(self.Denseout)

  def forward(self,x):
    x = self.activation(self.Densein(x))
    for i, l in enumerate(self.Dense):
      x = self.activation(l(x))
    out = (self.Denseout(x))
    return out

class AMLDNNSymmetric(nn.Module):
  def __init__(self,nin,nout,num_layers,growth_rate):
    super(AMLDNNSymmetric,self).__init__()
    self.activation = nn.Sigmoid()

    frontN = []
    backN = []
    for i in range(num_layers//2+1):
      frontN.append(int(nin*growth_rate**i))
      backN.append(int(nout*growth_rate**(num_layers//2-i)))

    self.Densefront = nn.ModuleList([nn.Linear(frontN[i],frontN[i+1]) for i in range(num_layers//2)])
    self.Densemiddle = nn.Linear(frontN[len(frontN)-1],backN[0])
    self.Denseback = nn.ModuleList([nn.Linear(backN[i],backN[i+1]) for i in range(num_layers//2)])

    print(self.Densefront,self.Densemiddle,self.Denseback)

  def forward(self,x):
    for i, l in enumerate(self.Densefront):
      x = self.activation(l(x))
    x = self.activation(self.Densemiddle(x))
    for i,l in enumerate(self.Denseback):
      x = self.activation(l(x))
    out = x
    return out