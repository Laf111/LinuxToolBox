#!/bin/bash
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## GENERID 
################################################################################
## INSTRUCTIONS
## This script evaluate a differences in seconds nanoseconds (signed float) : t1 -t2
## between 2 dates in the followinf format %Y-%m-%dT%H:%M:%S.%N (2006-10-01T23:59:58.102)
##
## Usage : $0 [t1] [t2]
##
## Where :
##  - t1 : fisrt date "
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
    echo "This script evaluate a differences in seconds nanoseconds (signed float) : t1 -t2"
    echo "between 2 dates in the followinf format %Y-%m-%dT%H:%M:%S.%N (2006-10-01T23:59:58.102)"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [t1] [t2]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- t1 : first date in format %Y-%m-%dT%H:%M:%S.%N quoted with \""
    echo "- t2 : second date in format %Y-%m-%dT%H:%M:%S.%N quoted with \""
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
    if [ $# -ne 2 ]
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

d1=$(dateToStamp $1)
d2=$(dateToStamp $2)

echo "scale="$scale"; $d1-$d2" | bc -q 2>/dev/null
cr=$?

exit $cr


