#!/bin/bash
##
## INSTRUCTIONS
##
## This script gives information on pathRoot
##
## USAGE : $0  [$pathRoot]
##
## $pathRoot : path of directory to be scanned
##
## RETURN CODE : 
##
##   cr = 0     : OK
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script gives information on pathRoot"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [pathRoot]  "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot : path of directory to be scanned"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0     : OK"
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


# Checking args
# -------------
if [ $# -ne 1 ]
then
	Syntaxe
	exit 99
fi

# pathRoot
pathRoot=$1


parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#getting full Path of pathRoot
GetDirectoryFullPath $pathRoot
cr=$?
if [ $cr -eq 0 ]; then
    pathRoot=$fullPath
else
    echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
    exit 99
fi

cd $pathRoot

echo "#######################################################################" 
# files count
number=$(find ./ -type f | wc -l)
printf " Number of files : "$number"\n"

# links count and check
findBrokenLinks.sh $pathRoot

# folders count
number=$(find ./ -type d | wc -l)
printf " Number of folders : "$(($number-1))"\n"

# child folders size
echo " Child folders size (following symlinks) : "
find -L ./ -maxdepth 1 -type d -exec du -hLs {} \;


# successfully exit
echo "#######################################################################" 
echo " Done successfully, exit 0"
exit 0



