#!/bin/bash
##
## INSTRUCTIONS
##
## This script give memory usage of a process taking into account all core used
##
## USAGE : $0 [$pid] 
##
## $pid : pid of the process
##
## RETURN CODE : 
##
##   cr = 0  : OK
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script give memory usage of a process taking into account all core used"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [pid]  "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pid : pid of the process"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

# Checking args
# -------------
if [ $# -ne 1 ]
then
	Syntaxe
	exit 99
fi

# workingInputDirFullPath
pid=$1

ps -p $pid -O rss | gawk '{ count++; sum+=$2 }; END { count--; print "Number of Core used = ", count; print "Memory used per core (Mo) =", sum/1024/count; print "Total Memory used (Mo) =", sum/1024 ;};'
exit $?

