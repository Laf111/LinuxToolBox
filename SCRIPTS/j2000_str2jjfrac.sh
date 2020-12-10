#!/bin/bash
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## GENERID 
################################################################################
## INSTRUCTIONS
## This script evaluate julian fractionnal date from a date in format %Y-%m-%dT%H:%M:%S.%N"
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
    echo "This script evaluate julian fractionnal date from a date in format %Y-%m-%dT%H:%M:%S.%N"
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

#///////////////////////////////////////////////////////////////////////////////
# Evaluate the difference with UNIX epoch 1970/1/1
function dateToStamp () {
    date -u -d "$1" +"%s.%N"
}



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cr=0
# Default scale used by bc.
scale=12

# Checking args
CheckArgs $*

j2000_1970=$(dateToStamp "2000-01-01T00:00:00.0")
nbSec1970=$(dateToStamp $1)

nbSec2000=$(echo "scale="$scale"; $nbSec1970 - $j2000_1970" | bc -q 2>/dev/null)

echo "scale="$scale"; $nbSec2000 / 86400.0" | bc -q 2>/dev/null
cr=$?

exit $cr


