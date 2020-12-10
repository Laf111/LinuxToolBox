#!/bin/bash
## INSTRUCTIONS
## This script launch the inventory industry
## 
##
## Usage:$0 [rootFolder] [depth*]
##
## rootFolder        : root folder for searching
## depth (optionnal) : searching depth from rootFolder
##
## return code values :
##
##    0  : exit successfully
##   >0  : warnings happens
##   >49 : errors happens
##   >99 : error on given args
################################################################################
# HISTORIQUE :
# 28/07/17 LAF111 : file creation
#
# FIN-HISTORIQUE
################################################################################


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# LOCAL FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Display how to use this script
function Syntaxe
{
  echo "-----------------------------------------------------------------------"
  echo "Usage:$0 [rootFolder] [depth*]"
  echo "where :"
  echo "- rootFolder : working directory full path expected for CHAIN-CSO (test directory)"
  echo "- depth (optionnal) : searching depth "
  echo " "
  echo "Return code values :"
    echo "RETURN CODE : "
    echo "  cr =0  : exit successfully"
    echo "  cr >0  : warnings happens"
    echo "  cr >49 : errors happens"
    echo "  cr >99 : error on given args"
  echo "-----------------------------------------------------------------------"

}
# return code
cr=0


# check args
if [ $# -ge 3 -o $# -eq 0 ]
then
    Syntaxe
    exit 100
else
    rootFolder=$1
    if [ ! -d $rootFolder -a ! L $rootFolder ]; then
        echo "ERROR : ("$(basename $0)"), root folder "$rootFolder" doesn't exist ! "
        exit 101
    fi
    if [ $# -eq 2 ]; then
        depth=$2
    fi
fi


echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" 
printf " Upper Case files and links under $rootfolder "
if [ "$depth" != "" ]; then
    printf "with depth < $depth\n"
else
    printf "\n"
fi

# scan rootFolder
files=$(find $rootFolder -type f)
links=$(find $rootFolder -type l)
all=$files" "$links

nbFilesTreated=0
for f in $all; do
    newName=$(basename $f | tr '[:lower:]''[:upper:]' )
    
    mv $f $(dirname $f)/$newName
    ret=$?
    if [ $cr -eq 0 ]; then
        echo "> $f renamed $(dirname $f)/$newName"
        nbFilesTreated=$(($nbFilesTreated+1))
    else
        echo "ERROR when treating $f"
        cr=50
    fi
done
echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" 
echo "done, $nbFilesTreated were renamed"
exit $cr

