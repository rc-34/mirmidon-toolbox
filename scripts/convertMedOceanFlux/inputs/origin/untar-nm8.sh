#!/bin/bash

years=$(seq 1962 2009)
outdir=untar
mkdir $outdir
for i in $years; do
echo $i
	tar xvf "NM8-24_med_1d_"$i"_vomecrty_surf.tar" -C $outdir
	tar xvf "NM8-24_med_1d_"$i"_sosstsst.tar"  -C  $outdir
	tar xvf "NM8-24_med_1d_"$i"_vozocrtx_surf.tar" -C $outdir
done
