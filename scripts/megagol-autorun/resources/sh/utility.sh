#!/bin/bash
#############################
#Utility - don't touch this!
#############################
LOGFILE="logs"
VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCLAIR="\\033[1;08m"
ORANGE="\\033[1;33m"
CYAN="\\033[1;36m"
clear
function log(){
    if [ $1 == 0 ]
    then
      echo -e "[ $VERT OK $NORMAL ] " $2
      echo "[ OK ] " $2 >> $LOGFILE
    elif [ $1 == "warning" ]
    then
      echo -e "[ $ORANGE WARNING $NORMAL ] " $2
      echo "[ WARNING ] " $2 >> $LOGFILE
    elif [ $1 == "notice" ]
    then
      echo -e "[ $CYAN NOTICE $NORMAL ] " $2
      echo "[ NOTICE ] " $2 >> $LOGFILE
    elif [ $1 == "raw" ]
    then
      echo -e $2
      echo $2 >> $LOGFILE
    else
      echo -e "[ $ROUGE FAIL $NORMAL ]" $2
      echo "[ FAIL ]" $2 " - Return code " $1 >> $LOGFILE
      exit $1
    fi
}

function rightnow(){
    d=$(date '+%Y-%m-%d %H:%M:%S')
}

function llsubmit(){
  if [ "$RUN" = "local" ] then 
    log "notice" "$1 might be submitted"
  elif ["$RUN" = "hpclr"] then
    llsubmit $1 > submission-file.txt
    jobid=$(tail -1 submission-file.txt | awk '{print $4}' | sed 's/\"//g')
    isNotFinished=1
    while [ $isNotFinished ]
    do
      isNotFinished=$(llq -u $USER | grep $jobid | wc -l)
    done
  else
    return -1
  fi
  return 0
}
