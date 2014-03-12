#!/bin/bash

echo 'load wind .inp'
cp ww3_prnc-wind.inp ww3_prnc.inp
echo 'launch ww3_prnc for wind...'
./ww3_prnc
echo 'load current .inp'
cp ww3_prnc-current.inp ww3_prnc.inp
echo 'launch ww3_prnc for current...'
./ww3_prnc

