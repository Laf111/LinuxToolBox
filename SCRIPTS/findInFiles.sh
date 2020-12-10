#!/bin/bash
##
## INSTRUCTIONS
##
## This script find -L a string in files or links from workingDirPath
##
## USAGE : $0  [$workingDirPath] "[fileFilter]" "[$expression]" [depth]* [-xml]*
##
## $workingDirPath : path of directory to be scanned
## fileFilter      : file filter surronded by'"' ("*" for all files)
## $expression     : string or regular expression surronded by'"'
## $depth (optionnal) : searching depth
## -xml (optionnal) : parsing xml file instead of grep
##
## RETURN CODE : 
##
##   cr = 0  : OK
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script find -L a string in files or links from workingDirPath"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [workingDirPath] \"[fileFilter]\" \"[expression]\" [depth]* [-xml]*"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- workingDirPath : path of directory to be scanned"
    echo "- fileFilter     : file filter surronded by'\"'"
    echo "- expression     : string or regular expression surronded by'\"'"
    echo "- depth (optionnal) : searching depth "
    echo "- -xml (optionnal) : parsing xml file instead of grep"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 99 : invalid arguments "
    echo " "
    echo "NOTES : "
    echo "   The string passed as arguments mustn't contain any reserved characters or they need to be escaped !"
    echo "-----------------------------------------------------------------------"
}
cr=0
parseXml=0

# Checking args
# -------------
if [ $# -lt 3 ]
then
	Syntaxe
	exit 99
else
    if [ $# -gt 5 ]
    then
	    Syntaxe
	    exit 99
    else
        # at least 3 args
        
        # workingDirPath
        workingDirPath=$(printf '%q' "$1")
        
        # file filter
        filter="$2"

        # expression
        expression="$3"

        if [ $# -eq 4 ]
        then
            if [ "$4" == "-xml" ]; then
                #parseXml
                parseXml=1
            else
                #depth
                depth=$4
            fi
        else 
            if [ $# -eq 5 ]; then

                if [ "$4" == "-xml" ]; then
                    #parseXml
                    parseXml=1
                else
                    #depth
                    depth=$4
                fi

                if [ "$5" == "-xml" ]; then
                    #parseXml
                    parseXml=1
                    #depth
                    depth=$4
                fi
            fi
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

## treating dot 
tmp=$(echo $expression | sed "s|\.|\\\.|g")
expression=$tmp

## treating '-' for grep
tmp=$(echo $expression | sed "s|-|\\\-|g")
expression=$tmp

if [ $parseXml -ne 1 ]; then

    cd $workingDirPath
    echo "#######################################################################" 
    echo " Matching files : "$(find -L ./ $depthOption -type f -name "$filter" -exec grep -l "$expression" {} \; | wc -l)
    find -L ./ $depthOption -type f -name "$filter" -exec grep -nH "$expression" {} \;
    echo " Matching links : "$(find -L ./ $depthOption -type l -name "$filter" -exec grep -l "$expression" {} \; | wc -l)
    find -L ./ $depthOption -type l -name "$filter" -exec grep -nH "$expression" {} \;
    echo " Matching folders names : "$(find -L ./ $depthOption -type d | grep -e "$expression$" | wc -l)
    find -L ./ $depthOption -type d -name "$filter" | grep "$expression"

else
    # use findInFilesAndParseXml
    findInFilesAndParseXml.sh "$workingDirPath" $filter "$expression" $depth
fi

# successfully exit
echo "#######################################################################" 
echo " Done successfully, exit 0"
exit 0



