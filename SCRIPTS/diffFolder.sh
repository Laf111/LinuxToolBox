#!/bin/bash

## INSTRUCTIONS
## This script diff two directory trees.
##
## NOTES : 
##      - results are deleted (you can kepp them by adding the '-k' option)
##      - insensitive file name case mode (to activate sensitive file name case mode, add the '-fncs' option)
## 
## USAGE : $0 [testedDir] [ignoredItemsFilePath*] [refDir] [logFilePath*] [-fncs*] [-k*]
##
## $testedDir : path of directory to be checked
## $ignoredItemsFilePath is optionnal : path to the file defining files, folders, patterns line in ASCII file to ignore based on testedDir content
## $refDir  : path of the reference directory
## $logFilePath is optionnal : log file output path, output to console if not present
## -fncs is optionnal : case sensitive file name mode (insensitive by default)
## -k is optionnal : keep the results (./diffed* directory is delete by default)
##
## return code values :
##    0 : folders match, no lonely files found
##    1 : folders match but lonely files found in tested dir
##    2 : folders match but lonely files found in ref dir
##    3 : folders match but lonely files found in both directories
##    4 : at least one file is different but no lonely files found
##    5 : folders dismatch ! (common files differents and/or lonely files found)
##    6 : folders dismatch at all ! no commons files found, only lonely files in the two folders
##   98 : user interruption
##   99 : args error
# HISTORIQUE :
# 27/08/15 FAU : - ajout du mode "insensible a la casse" par defaut, ajout d un argument
#                  pour activer le mode "sensible a la casse"
#                - ajout d'un argument optionnel en 2eme position pour passer un fichier
#                  definissant les répertoires et fichiers a ignorer ainsi que les pattern
#                  a ignorer dans les fichiers ASCII. Le fichier optionnel attendu par $parentDirFullPath/diffFile.sh 
#                  est construit dans ce cas (on utilise pas celui present au meme niveau que ce script)
# 15/10/2015 FAU : ajout d'une methode de determination du chemin absolu
# 10/11/2016 FAU : ajout du comptage des matches dans le cas ou les fichiers different mais pas avec le diff "intelligent" en excluant des balises

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# PROGRAM LOCAL PARAMETERS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# nombre maximum de fichier differents avant de desactiver le log des differences
nbDiffLog=3


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# PROGRAM FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# function to write msg to user
function writeLog
{
    if [ "$logFilePath" != "" ]; then
        echo $* >> $logFilePath 2>&1
    else
        echo $*
    fi
}



function Syntaxe
{
    writeLog "This script diff two directory trees"
    writeLog "-----------------------------------------------------------------------"
    writeLog "USAGE : $0 [testedDir] [ignoredItemsFilePath*] [refDir] [logFilePath*] [-k*] [-fncs*]"
    writeLog "-----------------------------------------------------------------------"
    writeLog "WHERE :"
    writeLog "- testedDir : path of directory to be checked"
    writeLog "- ignoredItemsFilePath is optionnal : path to the file defining files, folders, patterns line in ASCII file to ignore based on testedDir "
    writeLog "- refDir  : path of the reference directory"
    writeLog "- logFilePath is optionnal : log file output path, output to console if not present"
    writeLog "- -fncs is optionnal : case sensitive file name mode (insensitive by default)"
    writeLog "- -k is optionnal : keep the results (./diffed* directory is delete by default)"
    writeLog " "    
    writeLog "IMPORTANT NOTE : respect arguments order !"    
    writeLog " "    
    writeLog "RETURN CODE :"
    # diff OK
    writeLog "   0 : folders match, no lonely files found"
    writeLog "   1 : folders match but lonely files found in tested dir"
    writeLog "   2 : folders match but lonely files found in ref dir"
    writeLog "   3 : folders match but lonely files found in both directories"
    # diff KO
    writeLog "   4 : at least one file is different but no lonely files found"
    writeLog "   5 : folders dismatch ! (common files differents and/or lonely files found)"
    writeLog "   6 : folders dismatch at all ! no commons files found, only lonely files in the two folders"
    # diff ERROR
    writeLog "  98 : user interruption"
    writeLog "  99 : args error"
    writeLog "-----------------------------------------------------------------------"
}

# Clean modifications (trap action)
function CleanUp
{
    # delete diffed folder
    if [ $keepResults -eq 0 ]; then
        rm -rf $diffResultsHomeDir > /dev/null 2>&1
    fi
    
    # Deleting all diff.txt files allready present in testedDir
    tmpDiffFiles=$(eval "find "$testedDir" -type f -name \"*diff*.*\" "$ignoredFoldersCmd)
    for f in $tmpDiffFiles; do
        # in case where the tmp directory is inside testedDir
        name=$(basename "$f")
        if [ "$name" != "diffFile.conf" ]; then
            rm -rf "$f"  > /dev/null 2>&1
        fi
    done
    
    # kill process's child
    $parentDirFullPath/killProcessTree.sh $$    
}

# identify optionnal argument $arg
function checkFinalOptionalArg
{
    # nothing to do if arg doesn't exist
    if [ "$arg" != "" ]; then
    
        # boolean 
        found=0
    
        if [ "$arg" == "-k" ]; then
            keepResults=1
            found=1
        else
            if [ "$arg" == "-fncs" ]; then
                fncs=1
                found=1
            else
            
                logFilePath=$arg
                # delete it
                rm -rf $logFilePath
                exec > >(tee $logFilePath)
                exec 2>&1
                found=1
            fi
        fi

        # check identifying success
        if [ $found -ne 1 ]; then
            Syntaxe
            exit 99
        fi

    fi
}

# this function parse the file pointed by ignoredItemsFilePath to create ignore files, dirs list and the
# diffFile.conf file (used by $parentDirFullPath/diffFile.sh)
function parseIgnoredPatternFile
{   
    # flag used to know if a pattern file is used : 
    # - it could be a user pattern file if given throught arguments
    # - a default pattern file coming with diffFiles.sh script (located at under the same
    # directoy of this script
    DiffFilePatternIsUsed=0
    
    if [ "$ignoredItemsFilePath" != "" ]; then
        # getting ignored files list
        ignoredFiles=$(more $ignoredItemsFilePath | grep -v "#" | grep -v "<" | grep ".\.")

        # getting ignored directories list
        ignoredDirs=$(more $ignoredItemsFilePath | grep -v "#" | grep -v "<" | grep -v ".\.")

        # check if some node/line have to be excluded on ASCII file diff
        # getting ignored node/line item
        nodes=$(more $ignoredItemsFilePath | grep -v "#" | grep "<")
        # if there any : creating the diffFile.conf for script $parentDirFullPath/diffFile.sh under $diffResultsHomeDir
        check=$(echo $nodes | grep -E "[<>]")
        if [ "$check" != "" ]; then
            for n in $nodes; do
                # remove '<' and '>' from node
#                pattern=$n
                pattern=$(echo $n | sed s/">"/""/g | sed s/"<"/""/g)
                echo $pattern >> $diffResultsHomeDir/diffFile.conf
            done
        fi
        DiffFilePatternIsUsed=1
    else
        # using default diff file silently
        if [ -f "$parentDirFullPath/diffFile_default.conf" ]; then
            DiffFilePatternIsUsed=1
            $(cp "$parentDirFullPath/diffFile_default.conf" "$diffResultsHomeDir/diffFile.conf")
        fi
    fi
    
}

# this fucntion build a find syntax option to ignore dirs
function buildIgnoredDirsOption
{
    if [ "$ignoredDirs" != "" ]; then
        # bui
        ignoredFoldersCmd=" | grep -vi \".svn\""
        for d in $ignoredDirs; do
            ignoredFoldersCmd="$ignoredFoldersCmd"" | grep -vi \""$d"\""
        done
    fi
}

# checking if content folders to check match exactly
function isfolderContentDiffer
{
    # deleting file lists if they exist
    if [ -f $diffResultsHomeDir/testFilesToDiff ]; then
        rm -rf $diffResultsHomeDir/testFilesToDiff
    fi
    if [ -f $diffResultsHomeDir/refFilesToDiff ]; then
        rm -rf $diffResultsHomeDir/refFilesToDiff
    fi

    cd $testedDir

    testFiles=$(eval "find ./ -type f "$ignoredFoldersCmd)
    tmp="$testFiles "$(eval "find ./ -type l "$ignoredFoldersCmd)
    testLinkandFiles=$(echo "$tmp" | sort)

    for f in $testLinkandFiles; do
        
        # checking if file has to be ignored
        check=$(echo $ignoredFiles | grep $f)
        if [ "$check" == "" ]; then
            # file is not ignored, treating file    
            echo $f >> $diffResultsHomeDir/testFilesToDiff
        fi
    done

    #infoRefDir=$(getInfosPath.sh $refDir)

    cd $currentDir
    cd $refDir
    refFiles=$(eval "find ./ -type f "$ignoredFoldersCmd)
    tmp="$refFiles "$(eval "find ./ -type l "$ignoredFoldersCmd)
    refLinkandFiles=$(echo "$tmp" | sort)

    for f in $refLinkandFiles; do
        
        # checking if file has to be ignored
        check=$(echo $ignoredFiles | grep $f)
        if [ "$check" == "" ]; then
            # file is not ignored, treating file    
            echo $f >> $diffResultsHomeDir/refFilesToDiff
        fi
    done
    cd $currentDir


    if [ $keepResults -eq 1 ]; then
    
        writeLog " INFO : files to compare lists are dumped to $diffResultsHomeDir/testFilesToDiff and $diffResultsHomeDir/refFilesToDiff"
    fi

    folderContentDiffer=1
    check=$(diff $diffResultsHomeDir/testFilesToDiff $diffResultsHomeDir/refFilesToDiff)
    if [ "$check" == "" ]; then
        folderContentDiffer=0
    else
        writeLog " INFO : folders contents seems to be not fully identical !"
    fi
    
    writeLog "-----------------------------------------------------------------------"
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
                here=$(dirname "$here")
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
                here=$currentDir
                cd $checkedPath
                if [ $? -eq 0 ]; then
                    # relative path without ./, building full path
                    fullPath=$currentDir
                fi
                # return to working dir
                cd $here
            else
                fullPath=$checkedPath
            fi
        else
            fullPath=$currentDir
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

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# return code 
cr=99
# full path to the parent directory this script 
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
toolsPath=$(dirname "$parentDirFullPath")

currentDir=$(pwd)

#
## Checking args : 
#

# init
keepResults=0
fncs=0

if [ $# -lt 2 ]
then
    Syntaxe
    exit 99
else 
    if [ $# -gt 6 ]
    then
        Syntaxe
        exit 99
    else
        if [ $# -ge 3 ]
        then
            # identifying the 3 first args
            testedDir=$1
        
            if [ $# -ge 3 ]; then
                # treating second args
                if [ -f $2 ]; then
                    ignoredItemsFilePath=$2
                    refDir=$3
                else
                    if [ -d $2 ]; then
                        # ARGS ORDER is to be respected !
                        refDir=$2
                        arg=$3
                        checkFinalOptionalArg
                    else
                        echo "ignoredItemsFilePath : "$2" doesnt't exist !"
                        exit 99
                    fi
                fi
            fi
            if [ $# -ge 4 ]; then
                arg=$4
                checkFinalOptionalArg
            fi
            if [ $# -ge 5 ]; then
                arg=$5
                checkFinalOptionalArg
            fi
            if [ $# -ge 6 ]; then
                arg=$6
                checkFinalOptionalArg
            fi
        else 
            # only 2 args
            testedDir=$1
            refDir=$2
        fi
    fi
fi

# Checking testedDir
# -------------
if ! [ -d $testedDir ]
then
    writeLog "ERROR first directory doesn't exist : ("$testedDir")"
    exit 99
fi

#getting full Path of testedDir
#GetDirectoryFullPath $testedDir
#cr=$?
#if [ $cr -eq 0 ]; then
#    testedDir=$fullPath
#else
#    echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
#    exit 99
#fi

# Checking refDir
# -------------
if ! [ -d $refDir ]
then
    writeLog "ERROR second directory doesn't exist : ("$refDir")"
    exit 99
fi

#getting full Path of refDir
#GetDirectoryFullPath $refDir
#cr=$?
#if [ $cr -eq 0 ]; then
#    refDir=$fullPath
#else
#    echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
#    exit 99
#fi

# Checking ignoredItemsFilePath if needed
# -------------
if ! [ -f $ignoredItemsFilePath ]
then
    writeLog "ERROR ignoredItemsFilePath doesn't exist : ("$ignoredItemsFilePath")"
    exit 99
fi

# DEBUG
#echo "---------------------------------------"
#echo $0 $*
#echo "---------------------------------------"
#echo testedDir=$testedDir
#echo ignoredItemsFilePath=$ignoredItemsFilePath
#echo refDir=$refDir
#echo logFilePath=$logFilePath
#echo keepResults=$keepResults
#echo fncs=$fncs
#echo "---------------------------------------"
#echo pwd=$pwd
#echo parentDirFullPath=$parentDirFullPath
#read stop

now=$(date +"%Y_%m_%dT%H-%M-%S_%N")

if [ "$logFilePath" == "" ]; then
    diffResultsHomeDir=$currentDir/diffed_$now
else

    logParentDir=$(dirname "$logFilePath")
    
    #getting full Path of logParentDir
    GetDirectoryFullPath $logParentDir
    cr=$?
    if [ $cr -eq 0 ]; then
        logParentDir=$fullPath
    else
        echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
        exit 99
    fi
    
    diffResultsHomeDir=$logParentDir/$(basename "$logFilePath")_$now
fi

# Could put some sort of warning here
if [ -d $diffResultsHomeDir ]; then
   rm -r $diffResultsHomeDir
fi
mkdir $diffResultsHomeDir

# catching kill signals (except kill -9 of course)
trap "CleanUp; echo ERROR : user interruption !; exit 98" SIGHUP SIGINT SIGTERM

# parsing the ignoredItemsFilePath
parseIgnoredPatternFile

# build the find option to ignore dirs
buildIgnoredDirsOption

# Deleting all diff.txt files allready present in testedDir
tmpDiffFiles=$(eval "find "$testedDir" -type f -name \"*diff*.*\" "$ignoredFoldersCmd)
for f in $tmpDiffFiles; do
    # in case where the tmp directory is inside testedDir
    name=$(basename "$f")
    if [ "$name" != "diffFile.conf" ]; then
        rm -rf $f
    fi
done


writeLog "#######################################################################" 
writeLog " Comparing folders : " 
writeLog "-----------------------------------------------------------------------"


writeLog $testedDir" : "
if [ "$logFilePath" == "" ]; then
    ls -la $testedDir
else
    ls -la $testedDir >> $logFilePath 2>&1
fi

writeLog "-----------------------------------------------------------------------"
writeLog $refDir" : "
if [ "$logFilePath" == "" ]; then
    ls -la $refDir
else
    ls -la $refDir >> $logFilePath 2>&1
fi

# cd to tested dir
cd $testedDir
if [ "$ignoredItemsFilePath" != "" ]; then

    writeLog "-----------------------------------------------------------------------"
    writeLog " Ignoring the folowing items : "
    writeLog "     - list of ignored subfolders : .svn ""$ignoredDirs"
    writeLog "     - list of ignored files : ""$ignoredFiles"
    writeLog "     - list of ignored pattern in ASCII file : ""$nodes"
    
fi

writeLog "#######################################################################"

# checking if content folders to check match exactly
isfolderContentDiffer


# COM CGR 2016-10-04 : pour traiter en masse tous les répertoires test du PE de maniere automatique sans intervention manuelle
#if [ "$logFilePath" == "" ]; then
#    echo " Strike any key to continue / (CTRL + C) to cancel"
#    read continue
#fi
writeLog " Comparing ..."
writeLog " "

# number of matching files treated
nbFiles=0
# number of matching files treated
nbMatchingFiles=0
# number of non matching files treated
nbUnmatchingFiles=0
# number of lonely files found in testedDir
nbLonelyFilesInTestedDir=0
# number of lonely files found in refDir
nbLonelyFilesInRefDir=0

# cd to tested dir
cd $testedDir
allFiles=$(eval "find ./ -type f "$ignoredFoldersCmd)
tmp="$allFiles "$(eval "find ./ -type l "$ignoredFoldersCmd)
allFiles=$(echo "$tmp" | sort)

for f in $allFiles; do

    # checking if file has to be ignored
    check=$(echo $ignoredFiles | grep "$f")
    if [ "$check" == "" ]; then
        # file is not ignored, treating file
        nbFiles=$(($nbFiles+1))
        # getting filemame of f in $testedDir
        testedFileName=$(echo "${f##*/}")
        
        # init refFileName to testedFileName
        # if name file differs (even in case mismatch), they shall be identify as lonely files
        refFileName="$testedFileName"

        # getting supposed relative path
        tmp=$(dirname "$f")
        relativePath=${tmp:1} 
        
        # case insensitive handling : default insensitive
        if [ $fncs -eq 0 ]; then
            if [ -d $refDir/$relativePath ]; then
                # getting filemame of f in $refDir (case insensitive)
                searchedFile=$(find $refDir/$relativePath -mindepth 1 -maxdepth 1 -iname "$testedFileName")
                if [ "$searchedFile" != "" ]; then
                    tmp=$(basename "$searchedFile")
                    if [ "$tmp" != "" ]; then
                        refFileName=$(echo "${tmp##*/}")
                    fi
                fi
            fi
        fi

        if [ "$relativePath" != "" ]; then
            resFile="$testedDir/$relativePath/$testedFileName"
            refFile="$refDir/$relativePath/$refFileName"
        else
            resFile="$testedDir/$testedFileName"
            refFile="$refDir/$refFileName"
        fi

        if [ -f "$refFile"  -o  -L "$refFile" ]; then

            # Have to check if there is a difference between files
            diff -qwb "$resFile" "$refFile" > /dev/null
            if [ $? != 0 ]; then

                if [ $DiffFilePatternIsUsed -eq 1 ]; then
                     noDiff=$($parentDirFullPath/diffFile.sh "$resFile" "$refFile" $diffResultsHomeDir/diffFile.conf | grep "Pasdedifferenceentrelesfichiers")   
                else
                     noDiff=$($parentDirFullPath/diffFile.sh "$resFile" "$refFile" | grep "Pasdedifferenceentrelesfichiers")   
                fi
                if [ "$noDiff" == "" ]; then
                    # creating diffed relative path in diff temporary folder
                    mkdir -p $diffResultsHomeDir/$relativePath/

                    if [ $DiffFilePatternIsUsed -eq 1 ]; then
                        # echo "Writing diff between $testedDir/$relativePath/"$testedFileName" and $refDir/$relativePath/"$refFileName""
                        $parentDirFullPath/diffFile.sh "$resFile" "$refFile" $diffResultsHomeDir/diffFile.conf > "$diffResultsHomeDir/$relativePath/$testedFileName".diffed 2>&1
                    else
                        $parentDirFullPath/diffFile.sh "$resFile" "$refFile" > "$diffResultsHomeDir/$relativePath/$testedFileName".diffed 2>&1
                    fi

                    # avoid ing bug of empty diffed files
                    nonEmptyLines=0
                    nonEmptyLines=$(grep -vc "^$" "$diffResultsHomeDir/$relativePath/$testedFileName".diffed)
                    if [ $nonEmptyLines -eq 0 ]; then
                         rm -rf "$diffResultsHomeDir/$relativePath/$testedFileName".diffed
                         echo "$f" >> $diffResultsHomeDir/matches
                         nbMatchingFiles=$(($nbMatchingFiles+1))
                    else
                        nbUnmatchingFiles=$(($nbUnmatchingFiles+1))
                        echo "$f" >> $diffResultsHomeDir/unmatches
                    fi
                    
                    # delete dir is it is empty 
                    subFiles=$(find "$diffResultsHomeDir/$relativePath" -type f)
                    if [ "$subFiles" == "" ]; then
                        rm -rf "$diffResultsHomeDir/$relativePath"
                    fi
                    
                 else
                     # files matches
                     echo "$f" >> $diffResultsHomeDir/matches
                     # counting matching files
                     nbMatchingFiles=$(($nbMatchingFiles+1))
                 fi
            else
                echo "$f" >> $diffResultsHomeDir/matches
                # counting matching files
                nbMatchingFiles=$(($nbMatchingFiles+1))

            fi
        else
           echo "$f" >> $diffResultsHomeDir/onlyInTestedDir
           nbLonelyFilesInTestedDir=$(($nbLonelyFilesInTestedDir+1))
        fi
    fi

done


# Ending with refDir
cd $refDir


extraFiles=$(eval "find ./ -type f "$ignoredFoldersCmd)
tmp="$extraFiles "$(eval "find ./ -type l "$ignoredFoldersCmd)
extraFiles=$(echo "$tmp" | sort)

# Now have to do the reverse for refDir to testedDir, but only have to check if they are present or not

for f in $extraFiles; do

    # checking if file has to be ignored
    check=$(echo $ignoredFiles | grep "$f")
    if [ "$check" == "" ]; then
        # file is not ignored, treating file

        # getting filemame of f in $testedDir
        refFileName=$(echo "${f##*/}")

        # init testedFileName to refFileName
        # if name file differs (even in case mismatch), they shall be identify as lonely files
        testedFileName="$refFileName"

        # getting supposed relative path
        tmp=$(dirname "$f")
        relativePath=${tmp:1}
        
        # case insensitive handling : default insensitive
        if [ $fncs -eq 0 ]; then
            if [ -d $testedDir/$relativePath ]; then
                # getting filemame of f in $refDir (case insensitive)
                searchedFile=$(find "$testedDir/$relativePath" -mindepth 1 -maxdepth 1 -iname "$refFileName")
                if [ "$searchedFile" != "" ]; then
                    tmp=$(basename "$searchedFile")
                    if [ "$tmp" != "" ]; then
                        testedFileName=$(echo "${tmp##*/}")
                    fi
                fi
            fi
        fi

        if [ -f "$resFile" -o -L "$resFile" ]; then
            # Have to figure out how not to do something here
            echo stuff > /dev/null
        else
            echo "$f" >> $diffResultsHomeDir/onlyInRefDir
            nbLonelyFilesInRefDir=$(($nbLonelyFilesInRefDir+1))

        fi
    fi
    
done

# return to currentDir
cd $currentDir

writeLog " done : "
writeLog " "
writeLog " >Number of files treated : "$nbFiles
writeLog " >Number of matching files : "$nbMatchingFiles
writeLog " >Number of non matching files : "$nbUnmatchingFiles
writeLog " >Number of lonely files in "$testedDir" : "$nbLonelyFilesInTestedDir
writeLog " >Number of lonely files in "$refDir" : "$nbLonelyFilesInRefDir
writeLog "-----------------------------------------------------------------------"

# Deleting all diff.txt files allready present in testedDir
tmpDiffFiles=$(eval "find "$testedDir" -type f -name \"*diff*.*\" "$ignoredFoldersCmd)
for f in $tmpDiffFiles; do
    # in case where the tmp directory is inside testedDir
    name=$(basename "$f")
    if [ "$name" != "diffFile.conf" ]; then
        rm -rf "$f"
    fi
done

# matching files
if [ -f $diffResultsHomeDir/matches ]; then
    writeLog "----> "$nbMatchingFiles" files match : "
    if [ "$logFilePath" == "" ]; then
        more $diffResultsHomeDir/matches
# CGR 2016-10-06 pour alleger le fichier de sortie
    else
        more $diffResultsHomeDir/matches >> $logFilePath 2>&1
    fi
    writeLog "-----------------------------------------------------------------------"
fi

# if lonely files in $testedDir
if [ -f $diffResultsHomeDir/onlyInTestedDir ]; then
    writeLog "----> "$nbLonelyFilesInTestedDir" Lonely files in "$testedDir" : "
    if [ "$logFilePath" == "" ]; then
        more $diffResultsHomeDir/onlyInTestedDir
    else
        more $diffResultsHomeDir/onlyInTestedDir >> $logFilePath 2>&1
    fi
    writeLog "-----------------------------------------------------------------------"
fi
# if lonely files in $refDir
if [ -f $diffResultsHomeDir/onlyInRefDir ]; then
    writeLog "----> "$nbLonelyFilesInRefDir" Lonely files in "$refDir" : "
    if [ "$logFilePath" == "" ]; then
        more $diffResultsHomeDir/onlyInRefDir
    else
        more $diffResultsHomeDir/onlyInRefDir >> $logFilePath 2>&1
    fi
    writeLog "-----------------------------------------------------------------------"
fi


diffed_files=$(find $diffResultsHomeDir -name "*.diffed")
if [ "$diffed_files" != "" ]; then
    writeLog "#######################################################################"
    writeLog "----> "$nbUnmatchingFiles" non matching files : "

    if [ $keepResults -eq 0 ]; then
        if [ $nbUnmatchingFiles -gt $nbDiffLog ]; then
            writeLog "more than "$nbDiffLog" files differs, only listing them (and force keeping results) :"
            keepResults=1
        fi
    fi
    
    if [ $keepResults -eq 0 ]; then
    
        if [ $nbUnmatchingFiles -le $nbDiffLog ]; then
        
            for diff_file in $diffed_files; do
                writeLog "-----------------------------------------------------------------------"
                writeLog $diff_file" : "
                if [ "$logFilePath" == "" ]; then
                    more $diff_file
                else
                    more $diff_file >> $logFilePath 2>&1
                fi
            done
        else
        
            if [ "$logFilePath" == "" ]; then
                more $diffResultsHomeDir/unmatches 
            else
                more $diffResultsHomeDir/unmatches >> $logFilePath 2>&1
            fi
        fi
    else
    
        if [ "$logFilePath" == "" ]; then
            more $diffResultsHomeDir/unmatches
        else
            more $diffResultsHomeDir/unmatches >> $logFilePath 2>&1
        fi
    fi

else
    # clear subfolders under $diffResultsHomeDir
    find $diffResultsHomeDir/ -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;
fi

writeLog "#######################################################################"
if [ $keepResults -eq 1 ]; then
    writeLog " Keeping results under : "$diffResultsHomeDir
    writeLog "-----------------------------------------------------------------------"
fi

if [ "$logFilePath" != "" ]; then
    writeLog " Log file path : "$logFilePath
    writeLog "-----------------------------------------------------------------------"
fi

# NOTE : in the following, do not remove or move exit calls ! (useful for results interpretation)

# Does Folder have common file (in function of the case sensitive filename mode)
if [ $nbMatchingFiles -eq 0 -a $nbUnmatchingFiles -eq 0 ]; then

    writeLog "RESULT - Folders dismatch at all! no commons files found, only lonely files in the two directories : return 6"
    writeLog "#######################################################################"
    if [ $keepResults -ne 1 ]; then
        rm -rf $diffResultsHomeDir
    fi
    exit 6

fi

# existing non matching files ?
if [ "$diffed_files" == "" ]; then

    # lonely files in tested dir ?
    if [ -f $diffResultsHomeDir/onlyInTestedDir ]; then

        # with lonely files in refDir ?
        if [ -f $diffResultsHomeDir/onlyInRefDir ]; then
            writeLog "RESULT - Folders match on "$nbMatchingFiles" files but lonely files found. "$nbLonelyFilesInTestedDir" in "$testedDir" and "$nbLonelyFilesInRefDir" in "$refDir" : return 3"
            if [ $keepResults -ne 1 ]; then
                rm -rf $diffResultsHomeDir
            fi
            writeLog "#######################################################################"
            exit 3
        else
            # lonely files only in tested dir
            writeLog "RESULT - Folders match on "$nbMatchingFiles" files but "$nbLonelyFilesInTestedDir" lonely files found in "$testedDir" : return 1"
            writeLog "#######################################################################"
            if [ $keepResults -ne 1 ]; then
                rm -rf $diffResultsHomeDir
            fi
            exit 1
        fi
    fi

    # lonely files only in ref dir ?
    if [ -f $diffResultsHomeDir/onlyInRefDir ]; then
        writeLog "RESULT - Folders match on "$nbMatchingFiles" files but "$nbLonelyFilesInRefDir" lonely files found in "$refDir" : return 2"
        writeLog "#######################################################################"
        if [ $keepResults -ne 1 ]; then
            rm -rf $diffResultsHomeDir
        fi
        exit 2
    fi

    # folders contents matchs exactly
    writeLog "RESULT - Folders match, no lonely files found and "$nbMatchingFiles" files matching : return 0"
    writeLog "#######################################################################"
    if [ $keepResults -ne 1 ]; then
        rm -rf $diffResultsHomeDir
    fi
    exit 0

else

    # non matching files exits, so folder content have common files (names and relative path)
    if [ $folderContentDiffer -eq 0 ]; then
        # folders content (tree) are identical, only common files mismatch
        writeLog "RESULT - Folders dismatch ! no lonely files found but "$nbUnmatchingFiles" files are differents (on "$nbFiles" tested) : return 4"
        writeLog "#######################################################################"
        if [ $keepResults -ne 1 ]; then
            rm -rf $diffResultsHomeDir
        fi
        exit 4
        
    else
    
        # 5 : folders dismatch (file content and/or tree mismatch)
        writeLog "RESULT - Folders dismatch ! return 5 "
        writeLog "       - "$nbUnmatchingFiles" files are differents (on "$nbFiles" tested)"
        writeLog "       - "$nbLonelyFilesInTestedDir" lonely files found in "$testedDir
        writeLog "       - "$nbLonelyFilesInRefDir" lonely files found in "$refDir
        writeLog "#######################################################################"
        if [ $keepResults -ne 1 ]; then
            rm -rf $diffResultsHomeDir
        fi
        exit 5
    
    fi
fi

# DEAD CODE : exiting with an unkown code (no reason to get there)
exit 98
