#!/bin/bash

## INSTRUCTIONS
## This script check a path'files and folders names using filters on file and 
## regulars expressions defined in an optionnal external file given as 2nd argument. 
##
##
## USAGE : $0 [$checkedPath] [$regExpFile*] 
##
## $checkedPath  : full path to root folder to check without final '/'
## $regExpFile   : full path to the file defining files's patterns (optional)
##
## return code : 
##
##   cr = 0   : OK
##   cr =  1  : KO, files not match
##   cr =  2  : KO, folders not match
##   cr =  3  : KO, unexpected files found
##   cr =  4  : KO, missing files found
##   cr = 99 : invalid arguments 
##
## NOTES: 
##
## If only checkedPath is given, the following rules are applied : 
## 
## for folders : ^[a-zA-Z0-9_-]+$
## for files   : ^[A-Z0-9_-\:\.]+\.[A-Z0-9]+$
##
## WARNING : regular expressions expected are "grep" compliant one ! (not javascript one for example)
## 
## The main differences resides in :
##   - you have to escape (add ' \') at least the following caracters : {}.|*+^$
##   - replacing specials regExp characters as \d -> [0-9] ect...
##   - the '|' (OR operator in regExp javascript syntax) doesn't exist in grep syntax
##   you have to duplicate each regExp and separate them with the ';' character.
##   example : javascript regExp = ^[[ID1]|[ID2]|[ID3]]_[0-9]{7}_[0-9]{15}$
##   expected syntax (surrounded by "()") = ^ID1_[0-9]\{7\}_[0-9]\{15\}$;^ID2_[0-9]\{7\}_[0-9]\{15\}$
##
## Helpful sites : 
##   www.quentinc.net/testeur-expresssions-regulieres (javascript regExp checker)
##   www.robelle.com.smugbook/regexpr.html
##
cr=0

function Syntaxe
{
    echo "This script check a path'files and folders names using filters on file and regulars expressions defined in an optionnal external file given as 2nd argument."
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [checkedPath] [regExpFile*] "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- checkedPath  : full path to root folder to check without final '/'"
    echo "- regExpFile   : full path to the file defining files patterns (optional)"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr =  1  : KO, files not match"
    echo "   cr =  2  : KO, folders not match"
    echo "   cr =  3  : KO, unexpected files found"
    echo "   cr =  4  : KO, missing files found"
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

#
## Checking args
#
if [ $# -lt 1 ]
then
    Syntaxe
    exit  99
else 
    if [ $# -gt 2 ]
    then
        Syntaxe
        exit  99
    else
        if [ $# -eq 2 ]
        then
        
            # second arg = regExp file
            regExpFile=$2

            if [ ! -f "$regExpFile" ]; then
                echo "ERROR invalid regExpFile : ("$regExpFile") !"
                exit 99
            fi
        fi
    fi
fi

# checkedPath
checkedPath=$1

parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#getting full Path of checkedPath
GetDirectoryFullPath $checkedPath
cr=$?
if [ $cr -eq 0 ]; then
    checkedPath=$fullPath
else
    echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
    exit 99
fi


if [ "$regExpFile" != "" ]; then

    if [ ! -f "$regExpFile" ]; then
        echo "ERROR invalid regExpFile : ("$regExpFile") !"
        exit 99
    else
        # loading the file without comments and empty lines
        fileRegExp=$(sed /"^[#\|\\n]"/d "$regExpFile")
    fi
else
    # setting Default rules
    defaultFileRule="^[A-Z0-9_-\:\.]+\.[A-Z0-9]+$"
    defaultFolderRule="^[A-Z0-9_-\:\.]+\.[A-Z0-9]+$"
    fileRegExp="(*.*;*) "$defaultFileRule" (*/) "$defaultFolderRule""
fi

fileRegExpList=($fileRegExp)
nbElts=$(echo ${#fileRegExpList[@]})

echo "#######################################################################" 
echo " Checking files in "$checkedPath" with regular expression from "$regExpFile
echo "-----------------------------------------------------------------------" 

nbFilters=0
extSupported=""
for ((i=0; i<nbElts-1; i++)); do

    # treat only odd value of i
    if (( $i % 2 == 0  || i == 0 )); then
        # handling filters list
        tmp=${fileRegExpList[$i]}

        # replace parenthesis with '"'
        tmp=$(echo $tmp | sed s/\(/\"/g)
        filterList=$(echo $tmp | sed s/\)/\"/g)

        # check if it is a multiple filters selection (search for ';')
        mult=$(echo $filterList | grep ";")

        if [ "$mult" == "" ]; then

            # only one filter
            filter=$(echo ${filterList//[\"\"]})

            arrayFilter[$nbFilters]="$filter"
            extSupported=$extSupported" "$filter""

            j=$(($i+1))

            regExp=${fileRegExpList[$j]}

            arrayRegExp[$nbFilters]="$regExp"
            
#            echo " Filter : ($filter) with regExp : ($regExp)"
            
            nbFilters=$(($nbFilters+1))
        else

            # replace ';' by '" "' in the string
            tmp=$(echo $filterList | sed s/";"/"\" \""/g)

            filterSubList=($tmp)
            nbSubElts=$(echo ${#filterSubList[@]})

            j=$(($i+1))
            regExp=${fileRegExpList[$j]}

            for ((k=0; k<nbSubElts; k++)); do

                filter="${filterSubList[$k]}"
                extSupported=$extSupported" "$filter""
            
                arrayFilter[$nbFilters]="$filter"
                arrayRegExp[$nbFilters]="$regExp"

                echo " Filter : ($filter) with regExp : ($regExp)"
                nbFilters=$(($nbFilters+1))
            done

        fi

    fi

done

echo " Filters and regexp loaded"

tmp=$(echo $checkedPath | sed s/"\ "/"_"/g)
strParentDir=$(echo $tmp | sed s/"\/"/"-"/g)

parentDir=$(dirname $0)

if [ ! -f $parentDir/ignoredFiles$strParentDir".txt" ]; then
    touch $parentDir/ignoredFiles$strParentDir".txt"
else
echo " $parentDir/ignoredFiles"$strParentDir".txt exist, please check its content"
fi
echo "-----------------------------------------------------------------------" 

files=$(find -L "$checkedPath" -name "*.*")

for f in $files; do

    if [ -f $f -o -L $f -o -d $f ]; then

    #    echo " Checking "$f

            supported="NO"
            for ((i=0; (i<nbFilters && "$supported"=="KO"); i++)); do

                filter=${arrayFilter[$i]}
                regExp=${arrayRegExp[$i]}


                # TODO : check if "$filter" contain a "/"
                # NO -> folder find
                # YES -> file find

                # check based on filter search
                fil=$(echo ${filter//[\"\"]})

            #    fil='$(echo ${filter//[\"\"]}'
            #    fil=$filter        
        
                fileName=$(basename $f)
                parentDirPath=$(dirname $f)
        
                filesFound=$(find -L $parentDirPath -maxdepth 1 -iname "$fil")

                filtercheck=$(echo $filesFound | grep -i "$fileName")
                if [ "$filtercheck" != "" ]; then
                    regcheck=$(echo "$fileName" | grep -E "$regExp")

                    if [ "$regcheck" == "" ]; then
                    echo "invalid file : "$f" using regExp :"$regExp
                        supported="KO"            
                    setCr=$(echo $cr | grep 0) && cr=1
                    else
    #            echo "file "$f" : OK"
                        supported="OK"
                    fi        
                fi

            done
    
            if [ "$supported" == "KO" ]; then
        
                ignoreFile=$(more $parentDir/ignoredFiles"$strParentDir".txt | grep $f)

                if [ "$ignoreFile" == "" ]; then
#                 echo " Unexpected File : "$f " ? : do you want to add it to the "$parentDir"/ignoredFiles"$strParentDir".txt ?"
#                 echo " [y] to add"
#                 read ans
#                 if [ "$ans" == "y" ]; then
                    echo " Add "$f" to the ignore file list "$parentDir"/ignoredFiles"$strParentDir".txt !"
                       echo $f >> $parentDir"/ignoredFiles"$strParentDir".txt"
#            else
#                    echo " Unexpected File : "$f " ?"
                   setCr=$(echo $cr | grep 0) && cr=3
#                fi
            # already in the list : non error
            fi
        fi         

    else
        echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$f
        exit 1
    fi

done



#echo "-----------------------------------------------------------------------"

#echo " check folder names ..."
## check folders
#folderNamesToUpdate="METAX_EXPERTISE PSI MASK"
#listOfOldFolders=($folderNamesToUpdate)
#folderNamesUpdated="EXPERTISE IMG MSK"
#listOfFolders=($folderNamesUpdated)

#i=0
#for d in $folderNamesToUpdate; do

#    matchingFolders=$(find -L $checkedPath -name "*${listOfOldFolders[$i]}*" -type d)
#    if [ "$matchingFolders" != "" ]; then

#        for md in $matchingFolders; do
#            echo " Invalid Directory : "$md
#        done
#        i=$(($i+1))
#        setCr=$(echo $cr | grep 0) && cr=2
#    fi
#done
#echo "-----------------------------------------------------------------------"



echo "-----------------------------------------------------------------------" 
if [ "$cr" -eq 0 ]; then
    echo " RESULT = OK, exit "$cr
else
    echo " RESULT = KO, exit "$cr
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr =  1  : KO, files not match"
    echo "   cr =  2  : KO, folders not match"
    echo "   cr =  3  : KO, unexpected files found"
    echo "   cr =  4  : KO, missing files found"
    echo "   cr = 99 : invalid arguments "
fi
echo "#######################################################################" 




