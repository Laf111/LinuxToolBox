#!/bin/bash

## INSTRUCTIONS
## This script kill processes with name matching a given pattern
## 
##
## USAGE : $0 [pattern] [gpid*] [cmdPattern*] 
##
## $pattern : pattern for searching on process name
## $parentprocessId (optionnal) : id of a parent process
## $cmdPattern (optionnal) : pattern for searching on whole command line

## RETURN CODE : 
##
##   cr = 0  : OK
##   cr = 1  : not a process of yours (no root)
##   cr = 99 : invalid arguments 
##
##
cr=0

# Interrupt from keyboard
sigInt=2
# Kill signal
sigKill=9
# Termination signal
sigTerm=15


sigOrderedList="-"$sigTerm" -"$sigInt" -"$sigKill

function Syntaxe
{
    echo "This script kill processes with name matching a given pattern"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pattern] [gpid*]  [cmdPattern*] "
    echo "-----------------------------------------------------------------------"
    echo " "
    echo "WHERE :"
    echo "- pattern : pattern for searching on process name"
    echo "- parentprocessId (optionnal) : id of a parent process"
    echo "- cmdPattern (optionnal) : pattern for searching on whole command line"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : OK"
    echo "   1 : not a process of yours (no root)"
    echo "  99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}


cmdPattern=" "

# check that the process is running
if [ $# -lt 1 ]
then 
  Syntaxe
  exit 99;
else
    pattern=$1
    if [ $# -eq 2 ]
    then 
        check=$(echo "$2" | grep -E "^[0-9]{1,}$")
        if [ "$check" != "" ]; then
            gpid=$2
        else
            cmdPattern="$2"
        fi            
    fi  
    if [ $# -eq 3 ]
    then 
        check=$(echo "$2" | grep -E "^[0-9]{1,}$")
        if [ "$check" != "" ]; then
            gpid=$2
            cmdPattern="$3"
        else
            gpid=$2
            cmdPattern="$3"
        fi            
    fi  
    
fi

# BUG LINUX : if username exceed 8 characters (9 including empty string), ps used $UID instead of $USER in its first column)
nbCharUserName=$(echo $USER | wc -m)
if [ $nbCharUserName -gt 9 ]; then
    # compute UID
    str=$(getent passwd $USER)
    str=${str#*':'}
    str=${str#*':'}
    USERNAME=${str%%':'*}
else
    USERNAME=$USER
fi


reducedPattern=${pattern:0:8}

if [ "$gpid" != "" ]; then
    parentProcOption=" -P $gpid"
fi

# get immediate child process
listChild=$(pgrep -u $USERNAME $parentProcOption $reducedPattern)

# loop on every child process
for child in $listChild; do

    cmd=$(ps --pid $child -o cmd h)
    checkCmdLine=$cmd    
    if [ "$cmdPattern" != " " ]; then
        checkCmdLine=$(echo $cmd | grep $cmdPattern)
    fi
    
    if [ "$checkCmdLine" != "" ]; then

        for k in $sigOrderedList; do
    
            if [ -e /proc/$child ]; then
                kill "$k" "$child" > /dev/null 2>&1
                cr=$?
            fi        
        done
        echo "Killed process : "$child" : "$cmd
    fi        
done


exit $cr

