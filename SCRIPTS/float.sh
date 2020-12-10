#!/bin/bash
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## GENERID 
################################################################################
## INSTRUCTIONS
## This script evaluate float expression
##
## Usage : $0 [expression]
##
## Where :
##  - expression : expression to evaluate surrounded by "
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
## 04/04/2016 FAU : Version V1-0
## 20/01/2016 LAF111 : file creation
## FIN-HISTORIQUE
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# LOCAL FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#####################################################################
# Evaluate a floating point number expression.

function floatEval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}


#####################################################################
# Evaluate a floating point number conditional expression.

function floatCond()
{
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# return code
cr=0

# check args
if [ $# -eq 0 ]
then
    echo "-----------------------------------------------------------------------"
    echo "Usage:$0 [expression]"
    echo "where :"
    echo "- expression : expression to evaluate surrounded by \""
    echo " "
    echo "Return code values :"
    echo "RETURN CODE : "
    echo "  cr =0  : exit successfully"
    echo "  cr >0  : warnings happens"
    echo "  cr >49 : errors happens"
    echo "  cr >99 : error on given args"
    echo "-----------------------------------------------------------------------"
    exit 100
fi

# Default scale used by float functions.
float_scale=16

# Turn off pathname expansion so * doesn't get expanded
set -f
echo $(floatEval $*)
cr=$?
# Turn on pathname expansion so * doesn't get expanded
set +f

exit $cr


