import torch
import torch.nn as nn
from AMLDNN import AMLDNNPyramid as DNN
import numpy as np
import matplotlib.pyplot as plt

def train(e,lr,bs,layers,init_size,tx,ty,dims,pretrained_model=None):
  criterion = nn.BCEWithLogitsLoss()
  
  model = DNN(nin=dims, nout=1, num_layers=layers, initial_size=init_size)
  
  if pretrained_model is not None:
      model.load_state_dict(torch.load(pretrained_model))
  
  dataset = torch.utils.data.TensorDataset(tx, ty)
  loader = torch.utils.data.DataLoader(dataset, batch_size=bs)

  epochs=e
  loss = []
  acc = []
  iterator = range(epochs)#tqdm(range(epochs))
  opt = torch.optim.Adam(model.parameters(), lr=lr)
  for i in iterator:
    error = 0
    total = 0
    batch_loss = []
    for batch, data in enumerate(loader):
      x_batch, y_batch = data
      y_batch = y_batch.view(-1,1)
      pred_y = model(x_batch)

      l = criterion(pred_y, y_batch)
      batch_loss.append(l.item())

      opt.zero_grad()
      l.backward()

      opt.step()

      error += torch.sum(torch.abs(pred_y - y_batch))
      total += len(y_batch)

#    if i%(e/10) == 0:
#      print(str(i/e*100)+'%')
    
    loss.append(np.mean(batch_loss))
    acc.append(100*(1-error/total))


#  x = np.linspace(1,epochs,epochs)
#  plt.yscale('log')
#  plt.plot(x,loss)
#  plt.show()

  return model