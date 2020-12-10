#!/bin/bash

## INSTRUCTIONS
## This script find and extract a node in a xml document
##
##
## USAGE : $0 [$expression] [$checkedFile]  
##
## $expression   : xpath expression or node name (so without special caracters)
## $checkedFile  : path to XML document
##
## RETURN CODE : 
##
##    cr = 0   : OK
##    cr =  1  : ERROR : final node name exist but xpath doesn't match
##    cr =  2  : ERROR : final node name not found
##    cr =  3  : ERROR : node not found
##    cr = 11  : WARNING final node name exist but is empty
##    cr = 12  : WARNING xpath expression match nothing
##    cr = 99 : invalid arguments
##
## NOTES : in case of using '|' in xpath expression, only the first path is handle"
##         it belongs to you to split your xpath expression"
##
## Use xmlStartlet : ./xml sel -t -c "$expression" $checkedFile
## 
## RETURN CODE : 
cr=0

function Syntaxe
{
    echo "This script find and extract a node in a xml document"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [expression] [checkedFile] "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- expression   : xpath expression or node name (so without special caracters)"
    echo "- checkedFile  : path to XML document"
    echo " "
    echo "NOTES : in case of using '|' in xpath expression, only the first path is handle"
    echo "        it belongs to you to split your xpath expression"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr =  1  : ERROR : final node name exist but xpath doesn't match"
    echo "   cr =  2  : ERROR : final node name not found"
    echo "   cr =  3  : ERROR : node not found"
    echo "   cr = 11  : WARNING final node name exist but is empty"
    echo "   cr = 12  : WARNING xpath expression match nothing"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

function FormatFoundedLine
{
    # extract the first part
    pos=`expr index "$line" ":#"`
    lastState=${line:$pos}

    prefix=${line##*":_"}

    tmp=${lastState%$prefix}
  
    line=$(echo ${tmp//[:_]})
}



#///////////////////////////////////////////////////////////////////////////////
# Extract XML value of a node
# return : value
function ExtractValueFromNode
{
    tmp=${1#*">"}
    echo ${tmp%"<"*}
}



#
## Checking args
#
if [ $# -lt 1 ]
then
	Syntaxe
	exit  1
else 
    # 1st arg : checkedFile
    expression=$1

    if [ $# -eq 2 ]
    then
    
	    # second arg : checked file
	    checkedFile=$2

    fi
fi

if [ ! -f "$checkedFile" ]; then
    echo "ERROR invalid checkedFile : ("$checkedFile") !"
    exit 99
fi

# full path to the parent directory this script 
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
xmlStarletPath=$(dirname $parentDirFullPath)/bin

# check if a xpath or node name is given
# ---------------------------------------------
check=$(echo $expression | grep "/")
if [ "$check" == "" ]; then
    # node name 

    # create a global xpath syntax to match all nodes
    nodeName=$expression
    xpath="//"$expression

    # ? nb of grep ?

else
    
    # use xpath expression itself
    xpath=$expression
    
    # only use the first path in case of multiple path involved in expression
    check=$(echo $expression | grep "|")
    if [ "$check" != "" ]; then

        # getting position of '|' in the expression
        pos=`expr index "$expression" "|"`
        # extract only the first path
        xpath=${expression:$pos}
    fi

    subxpath=${xpath##*/}

    # try to get the first valid node in the leaving xpath expression (avoid '*')

    # check if '*' is present
    check=$(echo $subxpath | grep "*")
    while [ "$check" != "" ]; do
            subxpath=${subxpath##*/}
            check=$(echo $subxpath | grep "*")
    done

    if [ "$subxpath" != "" -a "$subxpath" != "/" ]; then
        # handling [] 

        check=$(echo $subxpath | grep "[")
        if [ "$check" != "" ]; then
            # getting position of '|' in the expression
            pos=`expr index "$expression" "["`
            # extract 
            subxpath=${subxpath:$pos}
        fi
        nodeName=$subxpath
    fi
fi

echo " Query "$expression" in "$checkedFile" :"

# if a node name has been found
if [ "$nodeName" != "" ]; then

    # verify that is found in the file
    founded=$(more $checkedFile | grep -nH "$nodeName")
    if [ "$founded" == "" ]; then
        if [ "$subxpath" != "" ]; then
            echo " ERROR : final node name ("$nodeName") in the given xpath not found, exit  2"
            exit  2
        else
            echo " ERROR : node name  ("$nodeName") not found, exit  3, exit  3"
            exit  3
        fi
    fi

    # getting the number of matching open blocks
    nbBlocks=$(more $checkedFile | grep -nH "<"$nodeName"[^\/]*>" | wc -l)

    openingLines=$(more $checkedFile | grep -nH "<"$nodeName".*>")
    openingLines=$(echo $openingLines | sed s/":\ "/":_"/g)

    openingLinesList=($openingLines)


    closingLines=$(more $checkedFile | grep -nH "</"$nodeName">")
    closingLines=$(echo $closingLines | sed s/":\ "/":_"/g)
    closingLinesList=($closingLines)

    # loop on the blocks
    for ((i=0; i<nbBlocks; i++)); do

        echo "-----------------------------------------------------------------------"
        line=${openingLinesList["$i"]}

        FormatFoundedLine
        startLine=$line

        line=${closingLinesList["$i"]}

        FormatFoundedLine
        endLine=$line

        echo " Found Block "$(($i+1))" from line "$startLine" to "$endLine
        echo ""

        
        # query on the xml doc using xmlstarlet
        ret=$($xmlStarletPath/xml sel -t -c "$xpath" "$checkedFile")
        if [ "$ret" == "" ]; then
            echo " ERROR : final node name ("$nodeName") exist but xpath ("$xpath")doesn't match, exit  1"
            exit  1
        else
            # check if xml ouput contains "><" (xmlstarlet concatenate blocks when more than one are founded)
            check=$(echo "$ret" | grep "><")
            if [ "$check" == "" ]; then

                printf "$ret""\n"

            else
                # create a list by replaceing "><" by "> <"

                ret=$(echo "$ret" | sed s/"><"/">\ <"/g)
                retList=($ret)

                printf "${retList["$i"]}""\n"

            fi

        fi

    done

    # getting the line number of empty matching nodes
    emptyBlockLines=\"$(more $checkedFile | grep -nH "<"$nodeName" .*>")\"
    emptyBlockLines=$(echo $emptyBlockLines | sed s/"\""//g)
    emptyBlockLines=$(echo $emptyBlockLines | sed s/"\ "/"_"/g)
    emptyBlockLines=$(echo $emptyBlockLines | sed s/">_"/">\ "/g)

    echo "-----------------------------------------------------------------------"

    for line in $emptyBlockLines; do

        FormatFoundedLine
        echo " Empty block founded line : "$line
    done


    if [ $nbBlocks -eq 0 -a "$emptyBlockLines" != "" ]; then
        echo "#######################################################################" 
        echo " WARNING : final node name ("$nodeName") exist but is empty, exit 11"
        exit 11
    fi

else
    # use xpath only

    # query on the xml doc using xmlstarlet
    ret=$($xmlStarletPath/xml sel -t -c "$xpath" "$checkedFile")
    if [ "$ret" == "" ]; then
        echo "#######################################################################" 
        echo " WARNING xpath expression ("$expression") match nothing, exit 12"
        exit 12
    else
        printf "$ret""\n"
    fi
fi

# successfully exit
echo "#######################################################################" 
exit 0



