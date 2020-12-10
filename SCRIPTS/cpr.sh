#!/bin/sh
##
## INSTRUCTIONS
##
## This script copy a file given with a relative path in a destination folder with creating (if needed) the relative path ## If the file already exist (name file criteria) in the destination folder : the file is copied and renamed in the destination folder with a suffix created with the number of the same file already present.
##
## USAGE : $0 [$relativePathFile] [outputDir]
##
## $relativePathFile     : relative path of the file
## $outputDir : rfull path of the destination folder
##
## NOTES : 
##
##
## RETURN CODE : 
##
##   cr = 0  : OK
##   cr = 99 : invalid arguments 
##

function Syntaxe
{
    echo "This script copy a file given with a relative path in a destination folder with creating (if needed) the relative path"
    echo "If the file already exist (name file criteria) in the destination folder : the file is copied and renamed in the destination folder with a suffix created with the number of the same file already present."
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [relativePathFile] [outputDir]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- relativePathFile : relative file path"
    echo "- outputDir : full path of the destination folder"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : no error"
    echo "   1 : errors found"
    echo "  99 : args error"
    echo "-----------------------------------------------------------------------"
}

function GetDirectoryFullPath
{

    # checking $1
    if [ ! -d "$1" ]; then
        echo "ERROR invalid path : ("$1") !"
        return 99
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
#
## Verification de la presence d'arguments
#
if [ $# -lt 2 ]
then
    Syntaxe
    exit 100
fi
relativePathFile=$1

# check relativePathFile
if [ ! -f $relativePathFile -o -L $relativePathFile ]; then
    echo " ERROR : "$relativePathFile" does not exist"
    exit 101
fi

outputDir=$2
#getting full Path of outputDir
GetDirectoryFullPath $outputDir
cr=$?
if [ $cr -eq 0 ]; then
    outputDir=$fullPath
else
    echo " ERROR invalid full outputDir computed : ("$fullPath") !"
    exit 102
fi


file_loc=${relativePathFile#*'/./'}
dir_loc=${file_loc%'/'*}

mkdir -p $outputDir/$dir_loc

# strip path, if any
fname="${relativePathFile##*/}"


if [ -f "$outputDir/$file_loc" ]; then
    n=2
    while [ -f "$outputDir/$dir_loc/${fname%.*}_${n}.${fname##*.}" ] ; do
        let n+=1
    done
    cp "$relativePathFile" "$outputDir/$dir_loc/${fname%.*}_${n}.${fname##*.}"
    cr=$?
    if [ $cr -ne 0 ]; then 
        exit 50
    fi
else
    cp "$relativePathFile" "$outputDir/$dir_loc"
    cr=$?
    if [ $cr -ne 0 ]; then 
        exit 51
    fi
fi

exit $cr
