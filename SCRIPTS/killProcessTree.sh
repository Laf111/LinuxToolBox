#!/bin/bash

## INSTRUCTIONS
## This script kill a process tree (all of child processes and theirs child too) 
## 
##
## USAGE : $0 [procId]
##
## $procId : id of thee process
##
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

# recursive function to kill child process Tree
function KillChildProcess
{
    local pid=$1
    local lastChild

    lastChild=$(pgrep -P $pid -n)
    if [ "$lastChild" != "" ]; then
        echo "Explore child processes of : "$lastChild
        KillChildProcess $lastChild
    fi

    for k in $sigOrderedList; do

        if [ "$pid" != "" ]; then
            kill "$k" "$pid"
            cr=$?
        fi

    done


    echo "Killed final process : "$pid
}


function Syntaxe
{
    echo "This script kill a process tree (all of child processes and theirs child too) "
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [procId] "
    echo "-----------------------------------------------------------------------"
    echo " "
    echo "WHERE :"
    echo "- procId : id of thee process"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : OK"
    echo "   1 : not a process of yours (no root)"
    echo "  99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

procId=$1

# check that the process is running
if [ -z $1 ]
then 
  Syntaxe
  exit 99;
 fi

# check if it's one of yours processes
if [ "$USER" != "root" ]; then

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
    check=$(ps -eaf | grep -v $USERNAME | grep $procId)
    if [ "$check" != "" ]; then
        echo "WARNING : Process "$procId" is not one of yours, sudo this script if needed !"
#        exit 1
    fi
fi

if [ ! -e /proc/$procId ]; then
    echo "Process $procId already killed !"
    exit 10
fi

# get immediate child process
listChild=$(pgrep -P $procId)

isParent=$(echo $listChild | grep $$)

# loop on every child process
for child in $listChild; do

    # recursive calls on all child but this script's one
    if [ $child -ne $$ ]; then
        KillChildProcess $child
    fi
done

if [ "$isParent" == "" ]; then

    # finally kill $procId
    for k in $sigOrderedList; do

        if [  -e /proc/$procId ]; then
            kill "$k" "$procId"
            ret=$?
            if [ $ret -ne 0 ]; then
                cr=$ret
            fi
        fi

    done
    echo "Finally kill process : "$procId
fi

if [ $cr -eq 0 ]; then
    if [ ! -e /proc/$procId ]; then
        echo "Process $procId and all its children were killed !"
    fi
    exit $cr
else
    echo "ERRORS occurs when killing $procId, please check"
    exit 51
fi


