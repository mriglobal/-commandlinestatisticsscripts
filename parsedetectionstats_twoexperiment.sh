#!/bin/bash

usage(){
cat << EOF
INPUT: A file with data that has items of interest spiked in (spike file), a file with data that does not have items of interest spiked in (absent file), a file that lists the strings to be searched for seperated by newlines (list file) and a pattern that should be matched for a line to register as a hit (pattern)
OUTPUT: returns TP, TN, FP, FN; space seperated 


OPTIONS:
    -s - spike file - file that has rows of data where items of interest should appear
    -a - absent file - file that has rows of data where items of interest should not appear
    -l - list file - file that lists off items of interest seperated by newlines, should pattern match to spike file
    -p - pattern - a pattern that grep can take, in order to filter out unwanted lines. For example, set pattern to 'species' and count will only consider lines that have 'species' and not lines that have 'genus' instead
    -r - removepattern - a pattern that grep can take, in order to filter out unwanted lines. For example, set removepattern to 'filtered' and count will only consider lines that do not have 'filtered'
    -c - column - an integer to say which column to look for a match in. For example, 3 says only look for matches in column 3
    -h  Help
EOF
}

pattern="default"
removepattern="null"
column="null"

while getopts "r:c:s:a:l:p:h" flag; 
do
  case "${flag}" in
    s) spikefile="${OPTARG}" ;;
    a) absentfile="${OPTARG}" ;;
    l) listfile="${OPTARG}" ;;
    p) pattern="${OPTARG}" ;;
    r) removepattern="${OPTARG}" ;;
    c) column="${OPTARG}" ;;
    h) usage;exit  ;;
  esac
done

if [ $column == "null" ]
then

  echo $(grep $pattern $spikefile | grep -v $removepattern |  grep -cf $listfile -)  \
       $(expr $(wc -l $listfile | cut -f1 -d' ')  -  $(grep $pattern $absentfile | grep -f $listfile - | grep -v $removepattern  | wc -l | cut -f1 -d' ')) \
       $(grep $pattern $absentfile | grep -v $removepattern | grep -cf $listfile -) \
       $(expr $(wc -l $listfile | cut -f1 -d' ')  -  $(grep $pattern $spikefile | grep -f $listfile - | grep -v $removepattern | wc -l | cut -f1 -d' ')) 

elif [ $column != "null" ]
then

  echo $(grep $pattern $spikefile | grep -v $removepattern |  cut -f $column - |  grep -xf $listfile - | wc -l )  \
       $(expr $(wc -l $listfile | cut -f1 -d' ')  -  $(grep $pattern $absentfile | grep -v $removepattern | cut -f $column - |  grep -xf $listfile -  | wc -l | cut -f1 -d' ')) \
       $(grep $pattern $absentfile | grep -v $removepattern |  cut -f $column - |  grep -xf $listfile - | wc -l ) \
       $(expr $(wc -l $listfile | cut -f1 -d' ')  -  $(grep $pattern $spikefile | grep -v $removepattern | cut -f $column - |  grep -xf $listfile -  | wc -l | cut -f1 -d' ')) 


fi
