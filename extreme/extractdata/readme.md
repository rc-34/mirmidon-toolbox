The goal of this script is to extract data from 

1. a file of sites in format LON LAT node[number],
2. a directory tree containing several year of ww3 v4.18 simulation on an unstructured grid. 

We assume that any point of 1. is part of the UG grid of any file of 2.
We also assume that any file of 2. contains the following variables :

HS  # Significant Wave height.
LM  # Mean wave length.
T01 # Mean wave period (Tm01).
DIR # Mean wave direction.