#!/bin/bash

## INSTRUCTIONS
## This script break a link and replace it by replacing it by its target
##
## USAGE : $0 [$linkPath]
##
## $linkPath    : path of the link
##
## return code : 
##
##   cr = 0   : OK
##   cr = -99 : invalid arguments 
cr=0

function Syntaxe
{
    echo "This script break a link and replace it by replacing it by its target"
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

# Checking args
# -------------
if [ $# -ne 1 ]
then
	Syntaxe
	exit 99
fi

link="$1"
if [ ! -L $link ]; then

    # $1 is a dir or a folder link
    if [ -d $1 ]; then
        # is '/' end $1 ?
        check=${1##*"/"}
        if [ "$check" == "" ]; then
            # '/' is present, remove it
            link=${1%?}
        fi
    fi
fi

if [ ! -L $link ]; then
    echo " "$1" is not a link ?"
    Syntaxe
    exit 99
fi

    
# link target
target=$(readlink -f $link)
if [ "$target" == "" ]; then
    echo " WARNING : link "$link" is broken ! ignore it !"
    cr=1
else
    echo " Replacing : $link"
    if [ -f $target ] ; then
        rm -rf $link 
        cp -f $target $link
        chmod 775 $link
    else
        rm -rf $link 
        mkdir -p $link
        cp -rL $target/* $link
        chmod 775 -R $link
    fi
fi

exit $cr
