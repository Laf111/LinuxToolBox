#!/bin/bash
##
## INSTRUCTIONS
##
## This script update the value of the XPATH = /*/HEADER/INTERFACE_SPECIFICATION/SCHEMA_VERSION in all .xml files under pathRoot
##
## USAGE : $0  [$pathRoot] [*depth]
##
## $pathRoot : path of directory containing xml or XML files to update
## $depth (optionnal) : searching depth
##
## NOTES :
##   Only files defining a valid XSD file in their XML header are updated !
##
## RETURN CODE : 
##
##  cr = 0 : OK
##  cr = 1  : WARNING at least one file is not associate to an xsd
##  cr = 2  : WARNING at least one file is invalid regarding its xsd
##  cr > 50 : ERROR
## cr > 100 : invalid arguments

function Syntaxe
{
    echo "This script update the value of the XPATH = /*/HEADER/INTERFACE_SPECIFICATION/SCHEMA_VERSION in all .xml files under pathRoot"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [pathRoot] [*depth]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot : path of directory containing xml or XML files to update"
    echo "- depth (optionnal) : searching depth"
    echo " "
    echo "NOTES :"
    echo "Only files defining a valid XSD file in their XML header are updated !"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 1  : WARNING at least one file is not associate to an xsd"
    echo "   cr = 2  : WARNING at least one file is invalid regarding its xsd"
    echo "   cr > 50  : ERROR"
    echo "   cr > 100 : invalid arguments"
    echo ""    
    echo "-----------------------------------------------------------------------"
}



function GetDirectoryFullPath
{

    # checking $1
    if [ ! -d "$1" ]; then
        echo "ERROR invalid path : ("$1") !"
        exit 100
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

cr=0

# full path to the parent directory this script 
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
xmlStarletPath=$(dirname $parentDirFullPath)/bin

# Checking args
# -------------
if [ $# -lt 1 ]
then
	Syntaxe
	exit 100
else
    if [ $# -gt 2 ]
    then
	    Syntaxe
	    exit 100
    else
        # at least 2 args
        
        # pathRoot
        pathRoot=$(printf '%q' "$1")
        
        if [ $# -eq 4 ]
        then
            #depth
            depth=$2
        fi

    fi
fi


#getting full Path of pathRoot
GetDirectoryFullPath $pathRoot
cr=$?
if [ $cr -eq 0 ]; then
    pathRoot=$fullPath
else
    echo "ERROR invalid full pathRoot computed : ("$fullPath") !"
    exit 101
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi

xPathRequest="/*/HEADER/INTERFACE_SPECIFICATION/SCHEMA_VERSION/text()"

# loop other all xml file found
xmlFile=$(find -L $pathRoot $depthOption -iname "*.XML")

for f in $xmlFile; do
    
    # try to get schema version from XML file
    oldVersionXsd=$($xmlStarletPath/xml sel -t -c "$xPathRequest" "$f")
    if [ "$oldVersionXsd" == "" ]; then
        echo "ERROR : file "$f" XPATH request ("$xPathRequest") failed !"
        exit 50
    else
        # get xsd file path (more easier with shell)
        tmp=$(more $f | grep "SchemaLocation=\"")
        tmp2=${tmp##*"SchemaLocation=\""}
        xsdFilePath=${tmp2%%"\""*}

        if [ "$xsdFilePath" == "" ]; then
            echo "WARNING : file "$f" is not associated to an XSD file"
            cr=1
        else

            # cd to f's parent directory (in case of relative path to xsd in XML file)
            parentDir=$(dirname $f)
            cd $parentDir

            # Checking file existance
            if [ ! -f "$xsdFilePath" -a ! -L "$xsdFilePath" ]; then
            
                echo "WARNING : XSD file not found : "$xsdFilePath
                cr=2
                # return under pathRoot
                cd $pathRoot
            else

                # get xsd file version (more easier with shell)
                tmp=$(more "$xsdFilePath" | grep "xs:schema" | grep "version=")
                tmp2=${tmp##*"version="}
                versionXsd=$(echo ${tmp2%%>*} | sed s/"\""/""/g)
                
                if [ "$versionXsd" == "" ]; then
                    echo "WARNING : no version found in xsd file "$xsdFilePath
                    cr=3
                else
                
                    if [ "$versionXsd" != "$oldVersionXsd" ]; then
                        # return under pathRoot
                        cd $pathRoot
                        
                        cp $f $f".tmp"
                        # update version in file
                        $xmlStarletPath/xml ed -u '/*/HEADER/INTERFACE_SPECIFICATION/SCHEMA_VERSION' -v $versionXsd $f".tmp" > $f
                        echo " - updating "$f
                        rm -rf $f".tmp"
                    else
                        echo "- no need to update "$f
                    fi
                fi
            fi
        fi
    fi 
done


if [ $cr -ne 0 ]; then        
    echo "WARNING : at least one xmlFile has not been updated"
    exit $cr
fi

echo "#######################################################################" 
echo " Done successfully, exit : "$cr
exit $cr




