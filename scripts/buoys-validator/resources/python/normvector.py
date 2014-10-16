#!/bin/python
import sys, numpy as np

def main(argv):
    opts, args = getopt.getopt(argv,"i",["ifile="])
    for opt, args in opts:
        if opt == '-i':
            data = np.loadtxt(arg)
            print data
