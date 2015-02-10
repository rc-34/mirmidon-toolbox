#!/bin/bash

years=$(seq 1960 2012)
for i in $years; do
echo $i
	tar xvf "FLUX_EG4_"$i".tar" 
done
