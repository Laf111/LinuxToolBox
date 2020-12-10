#!/bin/bash
##
## INSTRUCTIONS
##
## This script find a string in files or link from workingDirPath. It parse .XML and .CR file
##
## USAGE : $0  [$workingDirPath] "[fileFilter]" "[$expression]" [depth]*
##
## $workingDirPath : path of directory to be scanned
## fileFilter      : file filter surronded by'"' ("*" for all files)
## $expression     : string or regular expression surronded by'"'
## $depth (optionnal) : searching depth
##
## RETURN CODE : 
##
##   cr = 0  : OK
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script find -L a string in files or link from workingDirPath. It parse .XML and .CR file"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [workingDirPath] \"[fileFilter]\" \"[expression]\" [depth]* "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- workingDirPath : path of directory to be scanned"
    echo "- fileFilter     : file filter surronded by'\"'"
    echo "- expression     : string or regular expression surronded by'\"'"
    echo "- depth (optionnal) : searching depth "
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0     : OK"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

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

        # workingDirPath
        workingDirPath=$(printf '%q' "$1")
        # file filter
        filter=$2
        # expression
        expression=$3
        
        if [ $# -eq 4 ]
        then
            #depth
            depth=$4
        fi
    fi
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi




# checking $workingDirPath
if [ ! -d "$workingDirPath" ]; then
    echo "ERROR invalid workingDirPath : ("$workingDirPath") !"
    exit 99
fi

cd $workingDirPath

files=$(find -L ./ $depthOption -type f -name "$filter")
links=$(find -L ./ $depthOption -type l -name "$filter")

allFiles="$files $links"

echo " Matching files :"
# loop on all files (including links)
for f in $allFiles; do

    fileName=$(basename $f)

    # checking file
    match=$(grep -nH "$expression" $f)
    if [ "$match" != "" ]; then
        
        # check if the matching file is a xml one)
        xmlFile=$(echo $fileName | grep -i '.XML')
        crFile=$(echo $fileName | grep -i '.CR')

        if [ "$xmlFile" != "" -o "$crFile" != "" ]; then
            # using findInXml.sh
            findInXml.sh "$expression" $f
        else
            echo $match
        fi

    fi

done

echo " Matching folders names :"
find -L ./ $depthOption -type d | grep "$expression"

# successfully exit
exit 0



