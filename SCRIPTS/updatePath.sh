#!/bin/bash

## INSTRUCTIONS
## This script update targetDir by copying sourceDir files and links only if they are not present or different in the targetDir. 
## By using the optionnal parameter "createdAfterFile", you can specify a file or directory to copy only
## files (or links) newer than the file specified 
## 
## USAGE : $0 [sourceDir] [targetDir] [createdAfterFile]* [depth]*
##
## sourceDir                     : path to the source folder (to copy)
## targetDir                     : path to the target folder (to update)
## createdAfterFile  (optionnal) : refrence file, link or folder to copy only the newer elements
## depth (optionnal)             : searching depth
##
## RETURN CODE : 
##
##   cr = 0   : OK
##   cr =  1  : error occurs
##   cr = 99 : invalid arguments 
##

function Syntaxe
{
    echo "This script update targetDir by copying sourceDir files and links only if they are not present or different in the targetDir."
    echo "By using the optionnal parameter 'createdAfterFile', you can specify a file or directory to copy only files (or links) newer than the file specified "
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [sourceDir] [targetDir] [createdAfterFile]* [depth]*"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- sourceDir                     : path to the source folder (to copy)"
    echo "- targetDir                     : path to the target folder (to update)"
    echo "- createdAfterFile  (optionnal) : refrence file, link or folder to copy only the newer elements"
    echo "- depth (optionnal)             : searching depth"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr =  1  : error occurs"
    echo "   cr = 99 : invalid arguments "
    echo " "
    echo "NOTES : "
    echo "   Don't forget to sudo this script if needed !!! "
    echo "-----------------------------------------------------------------------"
}
cr=0

# Checking args
function CheckArgs
{
    if [ $# -lt 2 ]
    then
	    Syntaxe
	    exit 99
    else
        if [ $# -gt 4 ]
        then
	        Syntaxe
	        exit 99
        else
            # at least 2 args
            sourceDir=$(printf '%q' "$1")
            targetDir=$(printf '%q' "$2")
            if [ $# -ge 3 ]
            then
                # checking third argument
                if [ -d $3 -o -f $3 -o -L $3 ]; then
                    createdAfterFile=$(printf '%q' "$3")
                    if [ $# -eq 4 ]
                    then
                        depth=$4
                    fi
                else
                    depth=$3
                    if [ $# -eq 4 ]
                    then
                        createdAfterFile=$(printf '%q' "$4")
                    fi
                fi
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


function copyFilesIfNeeded
{
    for f in $files; do
        relativeParentDir=$(dirname $f)
        relativeParentDir=${relativeParentDir:2}
        name=$(basename $f)
        mkdir -p $targetDirFullPath/$relativeParentDir
        fileRelativePath=${f:2}
        if [ -f $targetDirFullPath/$relativeParentDir/$name -o -L $targetDirFullPath/$relativeParentDir/$name ]; then
            diffFile=$(diff -qwb $sourceDirFullPath/$fileRelativePath $targetDirFullPath/$relativeParentDir/$name)
            if [ $? != 0 ]; then
                # files differs : overwritting file in target dir
                cp -f $sourceDirFullPath/$fileRelativePath $targetDirFullPath/$relativeParentDir/$name
                cr=$?
            fi
        else
            cp $sourceDirFullPath/$fileRelativePath $targetDirFullPath/$relativeParentDir/$name
            cr=$?

        fi
    done
}

cr=0
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check arguments
CheckArgs $*

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi
if [ "$createdAfterFile" != "" ]; then
    newerOption=" -newer "$createdAfterFile
fi

# full path to the directories

#getting full Path of sourceDir
GetDirectoryFullPath $sourceDir
cr=$?
if [ $cr -eq 0 ]; then
    sourceDirFullPath=$fullPath
else
    echo "ERROR invalid full sourceDir computed : ("$fullPath") !"
    exit 99
fi

#getting full Path of targetDir
GetDirectoryFullPath $targetDir
cr=$?
if [ $cr -eq 0 ]; then
    targetDirFullPath=$fullPath
else
    echo "ERROR invalid full targetDir computed : ("$fullPath") !"
    exit 99
fi


cd $sourceDirFullPath
files=$(find -L ./ $depthOption -type f $newerOption)
copyFilesIfNeeded
files=$(find -L ./ $depthOption  -type l $newerOption)
copyFilesIfNeeded
echo "done"
exit $cr
