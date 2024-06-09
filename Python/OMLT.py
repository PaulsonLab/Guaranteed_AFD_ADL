import torch
import tempfile
from scipy.io import loadmat
from omlt.io import write_onnx_model_with_bounds, load_onnx_neural_network_with_bounds
from omlt.neuralnet import ReluBigMFormulation, FullSpaceNNFormulation
from omlt import OmltBlock, OffsetScaling
import pyomo.environ as pyo
from pyomo.opt import SolverFactory
import numpy as np
from dist import dist

def OMLT(net,dims,criteria=0.5):
 
    #Export torch NN to ONNX.
    xx = torch.randn(10,dims, requires_grad=True)
    with tempfile.NamedTemporaryFile(suffix='.onnx', delete=False) as f:
        torch.onnx.export(
            net,
            xx,
            f,
            input_names=['inputs'],
            output_names=['outputs'],
            dynamic_axes={
                'inputs': {0: 'batch_size'},
                'outputs': {0: 'batch_size'}
            }
        )
        write_onnx_model_with_bounds(f.name,None,input_bounds=[(-1,1) for i in range(dims)])
        filename = f.name

    #Import ONNX NN to OMLT.
    network_def = load_onnx_neural_network_with_bounds(filename)
    formulation = FullSpaceNNFormulation(network_def)

    #Make pyomo concrete model with OMLT block.
    m = pyo.ConcreteModel()
    m.nn = OmltBlock()
    m.nn.build_formulation(formulation)

    #Define constraints in logit space.
    m.con = pyo.Constraint(expr=m.nn.outputs[0] <= np.log(criteria/(1-criteria)))

    #Define optimization problem.
    def f():
        res = 0
        for i in range(dims):
            res += (m.nn.inputs[i])**2
            
        return res

    #Solve the block.
    m.obj = pyo.Objective(expr=f())
    pyo.SolverFactory('gurobi').solve(m)
#    print('Solved')

    res = []
    for i in range(dims):
        res.append(pyo.value(m.nn.inputs[i]))
    
    return res
