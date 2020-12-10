#!/bin/bash

## INSTRUCTIONS
## This script launch a list a non reg tests read from a testsConfigFile.conf
##
## NOTES :
##
## USAGE : $0 [testsConfigFile] [diffFolderConfFile*] [-k*] [-fncs*]
##
## $testsConfigFile : path of tests config file
## $diffFolderConfFile is optionnal : path of diffFolder script's config file
## -fncs is optionnal : case sensitive file name mode (insensitive by default)
## -k is optionnal : keep the results (delete by default)
##
## return code values :
##    0 : OK all tests passed
##    1 : KO at least one test failed
##    2 : KO all tests failed
##   97 : process error
##   99 : args error
################################################################################
# HISTORIQUE :
# 01/09/15 FAU : Creation du script

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# PROGRAM LOCAL PARAMETERS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# maximal number of umatching file to list
nbMaxUnmatchingFilesToList=6


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# PROGRAM FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Syntaxe
{
    echo "This script launch a list of non reg tests read from a testsConfigFile.conf"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [testsConfigFile] [diffFolderConfFile*] [-k*] [-fncs*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- testsConfigFile : path of non reg tests config file"
    echo "- diffFolderConfFile is optionnal : path of diffFolder script's config file"
    echo "- -fncs is optionnal : case sensitive file name mode (insensitive by default)"
    echo "- -k is optionnal : keep the results (./diffed* under "$(dirname $0)" is delete by default)"
    echo "RETURN CODE :"
    echo "   0 : OK all tests passed"
    echo "   1 : KO at least one test failed"
    echo "   2 : KO all tests failed"
    echo "  97 : process error"
    echo "  99 : args error"
    echo " "
    echo "-----------------------------------------------------------------------"
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#
## Checking args :
#
# init 
keepResults=""
fncs=""
diffFolderConfFile=""

if [ $# -gt 4 ]
then
    Syntaxe
    exit 99
else
    if [ $# -lt 1 ]
    then
        Syntaxe
        exit 99
    else
        if [ -f $1 ]; then
            testsConfigFile=$1
        else
            echo $1"doesn't exist ! "
            Syntaxe
            exit 99
        fi
        
        if [ $# -ge 2 ]; then
            if [ "$2" == "-k" ]; then
                keepResults="-k"
            else
                if [ "$2" == "-fncs" ]; then
                    fncs="-fncs"
                else
                    diffFolderConfFile=$2
                fi
            fi
        fi
        if [ $# -ge 3 ]; then
            if [ "$3" == "-k" ]; then
                keepResults="-k"
            else
                if [ "$3" == "-fncs" ]; then
                    fncs="-fncs"
                fi
            fi
        fi
        if [ $# -eq 4 ]; then
            if [ "$4" == "-k" ]; then
                keepResults="-k"
            else
                if [ "$4" == "-fncs" ]; then
                    fncs="-fncs"
                fi
            fi
        fi
    fi
fi


# check args

# Checking testsConfigFile
# -------------
if ! [ -f $testsConfigFile ]
then
    echo "ERROR testsConfigFile doesn't exist : ("$testsConfigFile")"
    exit 99
fi

# Checking diffFolderConfFile
# -------------
if [ "$diffFolderConfFile" != "" ]; then
    if [ ! -f $diffFolderConfFile ]; then
        echo "ERROR testsConfigFile doesn't exist : ("$diffFolderConfFile")"
        exit 99
    fi
fi

# parsing the tests config file
testsConfigList=$(more $testsConfigFile | grep -v "#")
ignoreTests=$(more $testsConfigFile | grep "#")


echo "#######################################################################" 
if [ "$ignoreTests" != "" ]; then
    echo "# WARNING : disabled tests and/or comments founds in test config file "$testsConfigFile" :"
    echo "# "
    more $testsConfigFile | grep "#"
    echo "#-----------------------------------------------------------------------"
fi

echo "# Launching the following non regression tests : "
echo "# Syntax : "
echo "TestId;result;identicals;differents;return_codes;differents files list" 
echo "#-----------------------------------------------------------------------"


testsConfigItems=($testsConfigList)
nbItems=$(echo ${#testsConfigItems[@]})

# number of tests launched
nbTests=0
# number of test KO
nbTestsKO=0

t=$(date +"%Y_%m_%dT%H-%M-%S_%N")
mkdir ./nonReg_$t

for (( i=0; i<nbItems; i=i+3 )) do
    # getting test coniguration
    resDirPath=${testsConfigItems[$i]}
    refDirPath=${testsConfigItems[$(($i+1))]}
    expectedReturn=${testsConfigItems[$(($i+2))]}

    
    
    # naming a log file with test name
    testName=$(basename $resDirPath)
    logFile=$resDirPath/nonReg/$testName.nonreglog
    mkdir -p $resDirPath/nonReg
    ln -s $resDirPath/nonReg ./nonReg_$t/$testName

    # cleaning old results folders
    
    rm -rf $resDirPath/nonReg/*

    printf "%s;" $testName

    # launching diffFolders.sh script
    diffFolder.sh "$resDirPath" "$diffFolderConfFile" "$refDirPath" "$logFile" "$keepResults" "$fncs"
    cr=$?
    
    # getting number of matching files
    line=$(more $logFile | grep ">Number of matching")
    
    if [ "$line" != "" ]; then
    
        nbMatchingFiles=${line##*" : "}
        # getting number of non matching files
        line=$(more $logFile | grep ">Number of non matching")
        nbUnmatchingFiles=${line##*" : "}
        
        # getting non matching files list
    #    unmatchingFilesListPath=$(more $logFile | grep "diffed :" | sed s/".diffed :"/""/g)

        unmatchingFilesListPath=$(find -L $resDirPath/nonReg/ -name "*.diffed" | sed s/".diffed"/""/g)
        unmatchingFilesTab=($unmatchingFilesListPath)

        nb=$(echo ${#unmatchingFilesTab[@]})

        if [ $nb -ne $nbUnmatchingFiles ]; then
            echo "Error, inconsistency between diffed files found and number of non matching files ! "
            exit 97
        fi
        
        if [ $nbUnmatchingFiles -le $nbMaxUnmatchingFilesToList ]; then
            # creating a file name list of non matching files
            unmacthingFilesNamesList=""
            
            for (( j=0; j<nb; j++ )) do
                # getting test coniguration
                filePath=${unmatchingFilesTab[$j]}
                fileName=${filePath##*"/"}
                
                unmacthingFilesNamesList=$unmacthingFilesNamesList" "$fileName
            done
        fi

        if [ $cr -le $expectedReturn ]; then
            printf "%s;%s;%s;%s%d%s%d%s\n" "OK" $nbMatchingFiles $nbUnmatchingFiles "cr=" $cr " (<=" $expectedReturn ")"
        else
            printf "%s;%s;%s;%s%d%s%d%s" "KO" $nbMatchingFiles $nbUnmatchingFiles "cr=" $cr " (>" $expectedReturn ")"
            if [ $nbUnmatchingFiles -le $nbMaxUnmatchingFilesToList ]; then
                printf ";%s\n" "$unmacthingFilesNamesList"
            else
                printf ";%s\n" "more than "$nbMaxUnmatchingFilesToList" files don't match, consult log file : "$(basename $logFile)
            fi
            nbTestsKO=$(($nbTestsKO+1))
        fi
    else
        echo "ERROR treating diffFolder log : "$logFile" !"
    fi
    # counting number of tests launched
    nbTests=$(($nbTests+1))

done

echo "#######################################################################" 
if [ $nbTestsKO -eq $nbTests ]; then
    echo " All non regression tests failed ! exit 2"
    exit 2
else
    if [ $nbTestsKO -ge 1 ]; then
        echo " At least one non regression test failed ! exit 1"
        exit 1
    else
        echo " All tests passed  : OK, exit 0" 
        echo "#######################################################################" 
        exit 0
    fi
fi

