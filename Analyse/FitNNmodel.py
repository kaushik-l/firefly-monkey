# generic methods
import os
os.environ["THEANO_FLAGS"] = "mode=FAST_RUN,device=cuda,floatX=float32"
import warnings
import numpy as np
import pandas as pd
import scipy.io

# import methods from spykesML
import sys
sys.path.append('C:\\Users\\jklakshm\\Documents\\GitHub\\spykesML\\MLencoding')
from mlencoding import *

# import data from mat file
data_imported = scipy.io.loadmat('tempdata_Xy.mat')
X = data_imported['X']
y = data_imported['y'][0]


# instantiate model object
"""
glm_model = MLencoding(tunemodel = 'glm')
Y_hat, varexp = glm_model.fit_cv(X,y, n_cv = 10, verbose = 2)
"""

nn_model = MLencoding(tunemodel = 'feedforward_nn')
Y_hat, varexp = nn_model.fit_cv(X,y, n_cv = 10, verbose = 2)
print(varexp)