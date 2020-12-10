#!/bin/bash

## INSTRUCTIONS
## This script rename a link with its target name
##
## USAGE : $0 [$linkPath]
##
## $linkPath    : path of the link
##
## return code : 
##
##   cr = 0   : OK
##   cr = -99 : invalid arguments 

function Syntaxe
{
    echo "This script rename a link with its target name"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [linkPath] "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- linkPath    : path of the link"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr = -99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

cr=0

# Checking args
# -------------
if [ $# -ne 1 ]
then
	Syntaxe
	exit 99
fi


# link target
link=$(printf '%q' "$1")

target=$(readlink -f $link)
if [ "$target" == "" ]; then
    echo " WARNING : link "$1" is broken ! ignore it !"
else

    targetName=$(basename $target)
    linkFolderPath=$(dirname $1)

    if [ -f $target -a -d $target]; then
        mv "$link" "$linkFolderPath/$targetName"
        cr=$?
    else
        " File broken link : "$l" pointing to "$target
    fi
    
fi

echo "-----------------------------------------------------------------------"
if [ $cr -eq 0 ]; then
    echo " Done."
else
    echo " Errors happens."    
fi
exit $cr
