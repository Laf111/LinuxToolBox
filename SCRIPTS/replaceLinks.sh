#!/bin/bash

## INSTRUCTIONS
## This script replace links in pathRoot with their targets
##
## USAGE : $0 [$pathRoot] [depth]*
##
## $pathRoot    : path to the directory where replacing links with their targets
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
    echo "This script replace links in pathRoot with their targets"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pathRoot] [depth]*"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot    : path to the directory where replacing links with their targets "
    echo "- depth (optionnal) : searching depth "
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 1  : error when parsing pathRoot"
    echo "   cr = 2  : broken links found"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

function GetDirectoryFullPath
{

    # checking $1
    if [ ! -d "$1" ]; then
        echo "ERROR invalid path : ("$1") !"
        exit 99
    fi
    
    checkedPath="$1"
    
    # check path's nature
    check=$(echo $checkedPath | grep "\./")
    if [ "$check" != "" ]; then
        # $checkedPath is given with a relative path, building full path
        check=$(echo $checkedPath | grep "\.\./")
        if [ "$check" != "" ]; then
            here=$(pwd); while [ "$check" != "" ]; do
                here=$(dirname $here)
                parentCheckedPath=${check#*"../"}
                
                check=$(echo $parentCheckedPath | grep "\.\./")
            done
            fullPath=$here/${parentCheckedPath##*"./"}
        else
        fullPath=$(pwd)/${checkedPath##*"./"}
        fi
    else
        if [ "$checkedPath" != "." ]; then
            # check if $checkedPath not begin with /
            check=${checkedPath%%"/"*}
            if [ "$check" != "" ]; then

               # try to cd to pathRoot
                here=$(pwd)
                cd $checkedPath
                if [ $? -eq 0 ]; then
                    # relative path without ./, building full path
                    fullPath=$(pwd)
                fi
                # return to working dir
                cd $here
            else
                fullPath=$checkedPath
            fi
        else
            fullPath=$(pwd)
        fi
    fi
    # remove last '/' if needed
    # check end of fullPath
    check=${fullPath##*"/"}
    if [ "$check" == "" ]; then
        # '/' is present, remove it
        fullPath=${fullPath%?}
    fi
    
}
################################################################################
# MAIN PROGRAM                                                                  
################################################################################

# Checking args
# -------------
if [ $# -lt 1 ]
then
	Syntaxe
	exit 99
else
    if [ $# -gt 2 ]
    then
	    Syntaxe
	    exit 99
    else
        # at least 1 args
        pathRoot=$1
        if [ $# -eq 2 ]
        then
            depth=$2
        fi
    fi
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi


nbTreatedLinks=0

# if $pathRoot is a link
if [ -L $pathRoot ]; then
    replaceLink.sh $pathRoot
else

    #getting full Path of pathRoot
    GetDirectoryFullPath $pathRoot
    cr=$?
    if [ $cr -eq 0 ]; then
        pathRoot=$fullPath
    else
        echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
        exit 99
    fi

    linkList=$(find $pathRoot $depthOption -type l)
    
    if [ "$linkList" == "" ]; then
        echo " Folder "$pathRoot" doesn't contain links !"
        echo " did you mean : "${pathRoot%?}" ?, then remove the ending '/' to use the link instead of the folder targeted"
    fi
    
    for f in $linkList; do

        if [ -L $f ]; then
            replaceLink.sh $f
            cr=$?
            if [ $cr -ne 0 ]; then
                nbTreatedLinks=$(($nbTreatedLinks+1))
            fi
        else
            echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$f
            exit 1
        fi
    done 
fi

# check if broken links exists
findBrokenLinks.sh $pathRoot
cr=$?
if [ $cr -ne 0 ]; then
    echo "Broken links found ! "
    cr=2
fi
echo "-----------------------------------------------------------------------"
if [ $cr -ge 2 ]; then
    echo " Done."
    echo " $nbTreatedLinks links treated"
else
    echo " Errors happens."    
fi
exit $cr
