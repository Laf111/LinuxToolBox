#!/bin/bash
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## GENERID 
################################################################################
## INSTRUCTIONS
## This script evaluate julian date from a date in format %Y-%m-%dT%H:%M:%S.%N"
##
## Usage : $0 [t]
##
## Where :
##  - t : date in format %Y-%m-%dT%H:%M:%S.%N quoted with \"
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
## 20/01/2016 LAF111 : file creation
## FIN-HISTORIQUE
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# LOCAL FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#///////////////////////////////////////////////////////////////////////////////
# Display how to use this script
function Syntaxe
{
    echo "This script evaluate julian date from a date in format %Y-%m-%dT%H:%M:%S.%N"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [t] "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- t : date in format %Y-%m-%dT%H:%M:%S.%N quoted with \""
    echo " "
    echo "RETURN CODE : "
    echo "   cr =0  : exit successfully"
    echo "   cr >0  : warnings happens"
    echo "   cr >49 : errors happens"
    echo "   cr >99 : error on given args"
    echo "-----------------------------------------------------------------------"
}

#///////////////////////////////////////////////////////////////////////////////
# Checking args
function CheckArgs
{
    if [ $# -ne 1 ]
    then
        Syntaxe
        exit 100
    fi
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cr=0
# Default scale used by bc.
scale=12

# Checking args
CheckArgs $*

j2000_str2jjParentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

jjfrac=$($j2000_str2jjParentDir/j2000_str2jjfrac.sh "$1")

echo ${jjfrac%%"."*}
secFrac=${jjfrac##*"."}
echo "scale="$scale"; "0."$secFrac * 86400.0" | bc -q 2>/dev/null
cr=$?

exit $cr


