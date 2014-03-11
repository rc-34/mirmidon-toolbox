#!/bin/bash

#############################################################################################
# GLOBAL SCHEME OF THE SCRIPT                                                               #
#############################################################################################
#1 Get the sequence of year to compute
#1bis Verifiy the folder-tree and whether the mandatory files/exe are available
#2 For each year in that sequence -- sequentially work
	#2a prepare workdir with all mandatory files 
		#2a-1 particular case in strt pre-routine for year 1
		#2a-2 otherwise
	#2b replace changing path and date in inp files
	#2c submit pre-processing work
		#2c-1 particular case in strt pre-routine for year 1
		#2c-2 otherwise
	#2d submit shel.cmd
	#2e scrutation while job isn't finished
	#2f move outputs from working dir to corresponding outputs dir
#3 clean stuff
#4 verify the overall behaviour of the script -- by checking availability of outputs files -- 
#############################################################################################

#output & error redirection to log
exec 2>logs.err 1>logs



d=$(date '+%Y-%m-%d %H:%M:%S')
echo "$d => That's all folks !!!"