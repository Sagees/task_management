# -*- coding: utf-8 -*-
# @author: Longxing Tan, tanlongxing888@163.com
# @date: 2020-03
# This script is used for testing the new data

import sys
import os
filePath = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.split(filePath)[0])

import numpy as np
import matplotlib.pyplot as plt
from data.read_data import AppData
from deepts.model import Model
from config import params
from numpy import argmin, argmax


def main(plot=False):
    x, y = AppData(params).get_examples(data_dir='../data/trace104.csv', sample=0.2)
    print(x.shape, y.shape)

    model = Model(params=params, use_model=params['use_model'])
    try:
        y_pred = model.predict(x.astype(np.float32), model_dir=params['saved_model_dir'])
    except:
        y_pred = model.predict((x.astype(np.float32), np.ones_like(y)), model_dir=params['saved_model_dir'])

    #print(y_pred)

    f = open('result/log104.txt', mode='wt', encoding='utf-8')

    for i in range(15696):
        #print(str(argmin(y_pred[i, :, 0])))
        #print('True : '+str(argmin(y[i, :, 0])) + ', Predict : '+str(argmin(y_pred[i, :, 0])))
        
        f.write(str(argmin(y_pred[i, :, 0]))+"\n")


    f.close()
    
    return y, y_pred


if __name__ == '__main__':
    main(plot=True)
