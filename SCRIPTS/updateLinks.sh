#!/bin/bash
## INSTRUCTIONS
## This script update links under $pathRoot by replacing $strOldPath with $replacementPath in its targeted path
##
## USAGE : $0 [$pathRoot] [$strOldPath] [$replacementPath] [depth]*
##
## $pathRoot        : path of directory to be linked
## $strOldPath      :  string surrounded by "" that contain the part of targeted paths to replace
## $replacementPath :  string surrounded by "" that contain the replacement part of targeted paths
## $depth (optionnal) : searching depth
##
## return code : 
##
##   cr = 0   : OK
##   cr = 1  : error when parsing pathRoot
##   cr = 2  : broken links found
##   cr = 99 : invalid arguments 
cr=0

function Syntaxe
{
    echo "This script update links under pathRoot by replacing strOldPath with replacementPath in its targeted path"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pathRoot] [strOldPath] [replacementPath] [depth*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot          : path of directory to be linked"
    echo "- strOldPath        :  string surrounded by "" that contain the part of targeted paths to replace"
    echo "- replacementPath   :  string surrounded by "" that contain the replacement part of targeted paths"
    echo "- depth (optionnal) : searching depth"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 1  : error when parsing pathRoot"
    echo "   cr = 2  : broken links found"
    echo "   cr = 99 : invalid arguments "
    echo " "
    echo "NOTES : "
    echo "   Strings passed as arguments mustn't contain any reserved characters or they need to be escaped !"
    echo "-----------------------------------------------------------------------"
}

# Checking args
# -------------
if [ $# -lt 3 ]
then
	Syntaxe
	exit 99
else
    if [ $# -gt 4 ]
    then
	    Syntaxe
	    exit 99
    else
        # at least 3 args
        pathRoot=$(printf '%q' "$1")

        strOldPath="$2"
        replacementPath="$3"

        if [ $# -eq 4 ]
        then
            depth=$4
        fi
    fi
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi

nbTreatedLinks=0

# checking $pathRoot
if [ ! -d "$pathRoot" ]; then
    echo "ERROR invalid pathRoot : ("$pathRoot") !"
    exit 99
fi

linkList=$(find $pathRoot $depthOption -name "*")
for l in $linkList; do
    if [ -L $l ]; then
        updateLink.sh $l "$strOldPath" "$replacementPath"
        cr=$?
        if [ $cr -eq 0 ]; then
           nbTreatedLinks=$(($nbTreatedLinks+1))
        fi
    fi
done 

# check if broken links exists
findBrokenLinks.sh $pathRoot
cr=$?
if [ $cr -ne 0 ]; then
    echo "Broken links found ! "
    cr=2
fi
echo "-----------------------------------------------------------------------"
if [ $cr -le 2 ]; then
    echo " Done."
    echo " $nbTreatedLinks links treated"
else
    echo " Errors happens."    
fi
exit $cr
