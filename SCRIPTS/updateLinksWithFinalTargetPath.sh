#!/bin/bash

## INSTRUCTIONS
## This script update links under $workingDir by replacing immediate link path with final target Path.
## It has no effect on symbolic links that have only one level of link.
##
## USAGE : $0 [workingDir] [depth*]
##
## $workingDir        : path of directory containing links to update
## $depth (optionnal) : searching depth
##
## return code : 
##
##   cr = 0   : OK
##   cr = 1   : warnings
##   cr = 2   : broken links found
##   cr > 50  : errors
##   cr = 99  : invalid arguments 
##

function Syntaxe
{
    echo "This script update links under $workingDir by replacing immediate link path with final target Path."
    echo "It has no effect on symbolic links that have only one level of link."
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [workingDir] [depth*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- workingDir           : path of directory containing links to update"
    echo "- depth (optionnal)    : searching depth"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 1  : warnings"
    echo "   cr = 2  : broken links found"
    echo "   cr > 50 : errors"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

function CheckArgs
{
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
            folder=$(printf '%q' "$1")

            if [ $# -eq 2 ]; then
                depth=$2
            fi
        fi
    fi
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


cr=0

# Check arguments
CheckArgs $*

parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi

# resolve links presents in $dir
if [ -L $folder ]; then
    workingDir=$(readlink -f $folder)
else
    workingDir=$folder
fi

#getting full Path of workingDir
GetDirectoryFullPath $workingDir
cr=$?
if [ $cr -eq 0 ]; then
    workingDir=$fullPath
else
    echo "ERROR invalid full workingDir computed : ("$fullPath") !"
    exit 99
fi

nbTreatedLinks=0
# get links list

linkList=$(find  $workingDir -type l $depthOption -name "*")

# loop over the list
for link in $linkList; do

    # get link's final target
    finalTarget=$(readlink -f $link)
    immediateTarget=$(readlink $link)
    
    if [ "$finalTarget" != "immediateTarget" ]; then
        # more than one level of links detected                
        unlink "$link"
        ln -s "$finalTarget" "$link"
        if [ $? -eq 0 ]; then
            echo " Link updated : "$link 
        else
            echo "ln command failed on $finalTarget for $link"
            cr=60  
        fi
        
        nbTreatedLinks=$(($nbTreatedLinks+1))
        
    fi

done 

# check if broken links exists in workingDir
check=$($parentDirFullPath/findBrokenLinks.sh $workingDir)
cr=$?
if [ $cr -ne 0 ]; then
    echo "Broken links found in ! "$workingDir
    cr=2
fi

echo "-----------------------------------------------------------------------"
if [ $cr -le 2 ]; then
    echo " Done."
    echo " $nbTreatedLinks links treated"
else
    echo " Errors happens, exit "$cr
fi
exit $cr
