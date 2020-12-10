#!/bin/bash

## INSTRUCTIONS
## This script rename files in a folder.
## 
##
## USAGE : $0 [pathRoot] "[stringSrc]" "[stringTarget]" [depth]*
##
## stringSrc         : string to replace surronded by'"'
## stringTarget      : string replacement surronded by'"'
## depth (optionnal) : searching depth
##
## RETURN CODE : 
##
##   cr = 0   : OK
##   cr =  1  : error occurs
##   cr = 99 : invalid arguments 
##


function Syntaxe
{
    echo "This script rename files in a folder."
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pathRoot] \"[stringSrc]\" \"[stringTarget]\" [depth]*"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot    : root folder"
    echo "- stringSrc         : string to replace surronded by'\"'"
    echo "- stringTarget      : string replacement surronded by'\"'"
    echo "- depth (optionnal) : searching depth "
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr =  1  : error occurs"
    echo "   cr = 99 : invalid arguments "
    echo " "
    echo "-----------------------------------------------------------------------"
}
cr=0

# Checking args
# -------------
if [ $# -lt 3 ]
then
    Syntaxe
    exit 99
else
    if [ $# -gt 4 ]
    then
        Syntaxe
        exit 99
    else
        # at least 3 args
        pathRoot=$(printf '%q' "$1")
        stringSrc=$2
        stringTarget=$3
        if [ $# -eq 4 ]
        then
            depth=$4
        fi
    fi
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi

## treating dot 
tmp=$(echo $stringSrc | sed "s|\.|\\\.|g")
secureStringSrc=$tmp

## treating '-' for grep
tmp=$(echo $secureStringSrc | sed "s|-|\\\-|g")
secureStringSrcForGrep=$tmp

# get Files and links
files=$(find $pathRoot $depthOption -type f)
links=$(find $pathRoot $depthOption -type l)


allFiles="$files $links"

## treating dot 
tmp=$(echo $stringTarget | sed "s|\.|\\\.|g")
secureStringTarget=$tmp


confirm=0
nbRenFiles=0

for f in $allFiles; do

    if [ -L $f -o -f $f ]; then
        oldName=$(basename $f)

        # check if the file would be renamed
        
        forRenaming=$(echo $oldName | grep "$secureStringSrcForGrep")
        if [ "$forRenaming" != "" ]; then

            # rename file
            parentDir=$(dirname $f)

            newName=$(echo $oldName | sed "s|$secureStringSrc|$secureStringTarget|g")
            cr=$?
            
            if [ "$oldName" != "$newName" -a $cr -eq 0 ]; then
                echo $f" renamed "$newName
                mv $parentDir/$oldName $parentDir/$newName
                cr=$?
                nbRenFiles=$(($nbRenFiles+1))
            else
                echo " Pb with stringSrc : ("$stringSrc") ou with sed commande using sed s/$secureStringSrc/$secureStringTarget/g !"
            fi
        fi
    else
        echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$f
        exit 99
    fi

done


# exit
echo "#######################################################################" 
if [ $cr -ne 0 ]; then
    echo " Error! , last exit exit code : "$cr", exiting  1"
    cr= 1
else
    echo " Done successfully, exit 0"
    echo " $nbRenFiles files renamed"
fi

exit $cr
