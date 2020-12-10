#!/bin/bash
## INSTRUCTIONS
## This script create a non reg tests list config file from a testDir and a refDir
##
## NOTES :
##
## USAGE : $0 [testDir] [refDir] [expectedDiffFolderReturnCode]
##
## $testDir : path of directory to be checked
## $refDir : path of reference directory
## $expectedDiffFolderReturnCode : return code value expected for successfull nonreg test
##
## return code values :
##    0 : OK
##    1 : KO
##   99 : args error
################################################################################
# HISTORIQUE :
# 01/09/15 FAU : Creation du script

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# PROGRAM FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Syntaxe
{
    echo "This script create a non reg tests list config file from a testDir and a refDir"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [testDir] [refDir] [expectedDiffFolderReturnCode]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- testDir : full path of directory to be checked"
    echo "- refDir : full path of reference directory"
    echo "- expectedDiffFolderReturnCode : return code value expected for successfull nonreg test"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : OK"
    echo "   1 : KO"
    echo "  99 : args error"
    echo " "
    echo "EXAMPLE : ./createTestsConfigFile.sh V2-2/OUTPUT V2-2/TV_OUTPUT > Sy2Dec_tests.conf"
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
                cd $checkedPath
                if [ $? -eq 0 ]; then
                    # relative path without ./, building full path
                    fullPath=$(pwd)
                fi
                # return to working dir
                cd $(pwd)
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
#
## Checking args :
#

if [ $# -ne 3 ]
then
    Syntaxe
    exit 99
else
    if [ -d $1 ]; then
        testDir=$1
    else
        echo $1" doesn't exist ! "
        Syntaxe
        exit 99
    fi
    if [ -d $2 ]; then
        refDir=$2
    else
        echo $2" doesn't exist ! "
        Syntaxe
        exit 99
    fi
    expectedDiffFolderReturnCode=$3
fi

# checking $testDir
#getting full Path of testDir
GetDirectoryFullPath $testDir
cr=$?
if [ $cr -eq 0 ]; then
    testDir=$fullPath
else
    echo "ERROR invalid full pathTarget computed : ("$fullPath") !"
    exit 99
fi
# checking $refDir
#getting full Path of refDir
GetDirectoryFullPath $refDir
cr=$?
if [ $cr -eq 0 ]; then
    refDir=$fullPath
else
    echo "ERROR invalid full pathTarget computed : ("$fullPath") !"
    exit 99
fi

# creating list of tests with all subfolder of testDir
testsFilePathList=$(find -L $testDir -mindepth 1 -maxdepth 1 -type d | sort)

testsFilePathTab=($testsFilePathList)
nbTest=$(echo ${#testsFilePathTab[@]})


for (( i=0; i<nbTest; i++ )) do
    resTest=${testsFilePathTab[$i]}

    # getting directory name
    testName=$(basename $resTest)

    # checking existence of reference test
    if [ -d $refDir/$testName ]; then

        echo $resTest" "$refDir/$testName" "$expectedDiffFolderReturnCode
    else
        # add comment : '#'
        echo "# "$testName" ignored : test doesn't exist under "$refDir" !"
    fi

done

exit 0


