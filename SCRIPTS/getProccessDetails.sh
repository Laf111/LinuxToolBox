#!/bin/bash
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## GENERID 
################################################################################
## INSTRUCTIONS
## This script extract information of given running process
## 
##
## USAGE:$0 [pid]
##
## WHERE : 
## $pid  : pid of the process
##
## return code values :
##
##    0  : exit successfully
##   >0  : warnings happens
##   >49 : errors happens
##   >99 : error on given args
##
## Notes : 
##
################################################################################
## HISTORIQUE :
## 07/10/2020 FAU : Version V1-0
## FIN-HISTORIQUE
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# LOCAL FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#///////////////////////////////////////////////////////////////////////////////
# Display how to use this script
function Syntaxe
{
    echo "This script extract information of given running process"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [pid]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pid : pid of the process"
    echo " "
    echo "RETURN CODE : "
    echo "   cr =0  : exit successfully"
    echo "   cr >0  : warnings happens"
    echo "   cr >49 : errors happens"
    echo "   cr >99 : error on given args"
    echo "-----------------------------------------------------------------------"
}



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cr=0

if [ $# -ne 1 ]
then
    Syntaxe
    exit 100
fi


if [ -d "/proc/$1" ]; then

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
        check=$(ps -eaf | grep -v $USERNAME | grep $1)
        if [ "$check" != "" ]; then
            echo "WARNING : Process "$1" is not one of yours, sudo this script if needed !"
        fi
    fi
    
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    echo " Details of the running process with pid $1"
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    echo " stat : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/stat" | more
    echo "======================================================================="
    echo " status : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/status" | more
    echo "======================================================================="
    echo " stack : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/stack" | more
    echo "======================================================================="
    echo " smaps : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/smaps" | more
    echo "======================================================================="
    echo " maps : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/maps" | more
    echo "======================================================================="
    echo " limits : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/limits" | more
    echo "======================================================================="
    echo " io : "
    echo "-----------------------------------------------------------------------"
    cat "/proc/$1/io" | more
    echo "======================================================================="
    echo " environ : "
    echo "-----------------------------------------------------------------------"
    tail "/proc/$1/environ"
    printf "\n"
    echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"    

else
    echo "ERROR : /proc/$1 folder does not exist"
    Syntaxe
fi

exit $cr

