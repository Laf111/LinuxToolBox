#!/bin/bash

## INSTRUCTIONS
## "This script sorts data in separate directories"
## "-----------------------------------------------------------------------"
## "USAGE : $0 [dirIn] [mess] [dirOut]"
## "-----------------------------------------------------------------------"
## "WHERE :"
## "- dirIn   : path of input directory"
## "- mess    : message to filter"
## "- dirOut  : path of filtered directory "
## " "
## "RETURN CODE : "
## "   cr = 0   : OK"
## "   cr = 99 : invalid arguments "


function Syntaxe
{
    echo "This script sorts data in separate directories"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [dirIn] [mess] [dirOut]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- dirIn   : path of input directory"
    echo "- mess    : message to filter"
    echo "- dirOut  : path of filtered directory "
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}



################################################################################
# MAIN PROGRAM                                                                  
################################################################################
cr=0
# Checking args
# -------------
if [ $# -ne 3 ]
then
	Syntaxe
	exit 99
fi

dirIn=$1
mess=$2
dirOut=$3

filesFiltered=$(find -L $dirIn/*.log -exec grep -l "$mess" {} \;)
for f in $filesFiltered; do 
    parentDir=$(dirname $f); 
    mv $parentDir $dirOut; 
done
