#!/bin/sh
##
## INSTRUCTIONS
##
## This script copy all files (including liked files) present under srcDir to targetDir with creating relative path in targetDir if needed
## It use cpr.sh so if file or link already exist in the targetDir, it will be rename with a suffix _n
##
## USAGE : $0 [$srcDir] [$targetDir]
##
## $srcDir     : srcDir path
## $targetDir  : targetDir Path
##
## NOTES : 
##
##
## RETURN CODE : 
##
##   cr = 0  : OK
##   cr < 50 : WARNINGS
##   cr > 50 : ERRORS
##   cr > 99 : invalid arguments 
##

function Syntaxe
{
    echo "This script copy all files (including liked files) present under srcDir to targetDir with creating relative path in targetDir if needed"
    echo "It use cpr.sh so if file or link already exist in the targetDir, it will be rename with a suffix _n"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [srcDir] [targetDir]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- srcDir     : srcDir path"
    echo "- targetDir  : targetDir Path"
    echo " "
    echo "RETURN CODE :"
    echo "   cr = 0  : OK"
    echo "   cr < 50 : WARNINGS"
    echo "   cr > 50 : ERRORS"
    echo "   cr > 99 : invalid arguments "
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

parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#
## Verification de la presence d'arguments
#
if [ $# -lt 2 ]
then
    Syntaxe
    exit 100
fi

srcDir=$1
#getting full Path of srcDir
GetDirectoryFullPath $srcDir
cr=$?
if [ $cr -eq 0 ]; then
    srcDir=$fullPath
else
    echo " ERROR invalid full srcDir computed : ("$fullPath") !"
    exit 102
fi

targetDir=$2
#getting full Path of targetDir
GetDirectoryFullPath $targetDir
cr=$?
if [ $cr -eq 0 ]; then
    targetDir=$fullPath
else
    echo " ERROR invalid full targetDir computed : ("$fullPath") !"
    exit 102
fi

# backup working dir location
cwd=$(pwd)

# cd to srcDir to get relative Path
cd $srcDir

# HANDLING FILES : 
files=$(find -L ./ -type f)

for f in $files; do
    # using cpr.sh
    cmdCpr=$($parentDirFullPath/cpr.sh $f $targetDir \;)
    if [ $? -ne 0 ]; then
        printf " ERROR when copying the file "$f" : \n $cmdCpr\n"
        # return to current working dir
        cd $cwd
        exit 50
    fi


done

# HANDLING FILES LINKED : 
links=$(find -L ./ -type l)

for l in $links; do
    # getting final target    
    finalTarget=$(readlink -f $l)
    # getting immediate (first level) target    
    target=$(readlink $l)
    
    # copy only if final target is a file
    if [ -f $finalTarget ]; then
    
        # check if target is a relative path
        check=$(echo $target | grep "\./")
        if [ "$check" != "" ]; then
            # $target is given with a relative path     
            if [ ! -f $outpDir"/"$target ]; then                
                # recreating full path link in targetDir
                name=$(basename $l)
                relativeParentDir=$(dirname $l)
                rd=${relativeParentDir:2}
                mkdir -p $targetDir/$rd
                ln -s $finalTarget $targetDir/$rd/$name
            else
                # not creating a broken link : OK
                cmdCpr=$($parentDirFullPath/cpr.sh $l $targetDir)
                if [ $? -ne 0 ]; then
                    printf " ERROR when copying the link "$l" : \n $cmdCpr\n"
                    # return to current working dir
                    cd $cwd
                    exit 52
                fi
            fi
         else
            # full path : not creating a broken link
            cmdCpr=$($parentDirFullPath/cpr.sh $l $targetDir)
            if [ $? -ne 0 ]; then
                printf " ERROR when copying the link "$l" : \n $cmdCpr\n"
                # return to current working dir
                cd $cwd
                exit 51
            fi
         fi         
         
    fi
done

# return to current working dir
cd $cwd

exit $cr
