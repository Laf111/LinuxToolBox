#!/bin/bash
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## GENERID 
################################################################################
## INSTRUCTIONS
## This script evaluate a date in format %Y-%m-%dT%H:%M:%S.%N from a timestamp in J2000
##
## Usage : $0 [t]
##
## Where :
##  - t : timestamp in seconds
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
    echo "This script evaluate a date in format %Y-%m-%dT%H:%M:%S.%N from a timestamp in J2000"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [t] "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- t : timestamp in seconds as a float"
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

# stamp to date
echo $(date --utc --date "2000-01-01 $1 sec" +"%Y-%m-%dT%H:%M:%S.%N")
cr=$?

exit $cr


