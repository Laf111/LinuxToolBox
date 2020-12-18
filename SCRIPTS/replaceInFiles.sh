#!/bin/bash

## INSTRUCTIONS
## This script replace in files (without following links) from a folder using a file filter. 
## 
##
## USAGE : $0 [pathRoot] "[fileFilter]" "[stringSrc]" "[stringTarget]" [depth]*
##
## pathRoot          : root folder
## fileFilter        : file filter surronded by'"' ("*" for all files)
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
    echo "This script replace in files (without following links) from a folder using a file filter. "
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pathRoot] \"[fileFilter]\" \"[stringSrc]\" \"[stringTarget]\" [depth]*"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot          : root folder"
    echo "- fileFilter        : file filter surronded by'\"'"
    echo "- stringSrc         : string to replace surronded by'\"'"
    echo "- stringTarget      : string replacement surronded by'\"'"
    echo "- depth (optionnal) : searching depth "
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0   : OK"
    echo "   cr =  1  : error occurs"
    echo "   cr = 99 : invalid arguments "
    echo " "
    echo 'EXAMPLE : replaceInFiles.sh $(pwd) "*.sh" "USAGE :\$0" "USAGE : \$0" 3'
    echo "-----------------------------------------------------------------------"
}
cr=0

# Checking args
# -------------
if [ $# -lt 4 ]
then
	Syntaxe
	exit 99
else
    if [ $# -gt 5 ]
    then
	    Syntaxe
	    exit 99
    else
        # at least 4 args
        pathRoot=$(printf '%q' "$1")
        filter="$2"
        stringSrc="$3"
        replacementStr="$4"
        if [ $# -eq 5 ]
        then
            depth=$5
        fi
    fi
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi


# checking $pathRoot
if [ ! -d "$pathRoot" -a ! -L "$pathRoot" ]; then
    echo "ERROR invalid pathRoot : ("$pathRoot") !"
    exit 99
fi

## treating dot 
tmp=$(echo $stringSrc | sed "s|\.|\\\.|g")
secureStringSrc=$tmp

## treating '-' for grep
tmp=$(echo $secureStringSrc | sed "s|-|\\\-|g")
secureStringSrcForGrep=$tmp

fileList=$(find -L $pathRoot $depthOption -name "$filter" -exec grep -l "$secureStringSrcForGrep" {} \;)

## treating dot 
tmp=$(echo $replacementStr | sed "s|\.|\\\.|g")
secureReplacementStr=$tmp

nbTreatedFiles=0

for f in $fileList; do

    if [ -f $f ]; then

        check=$(echo check | sed "s|$secureStringSrc|$secureReplacementStr|g")
        cr=$?
        if [ $cr -eq 0 ]; then
        
            sed -i -c "s|$secureStringSrc|$secureReplacementStr|g" $f
            echo " File updated : "$f
            nbTreatedFiles=$(($nbTreatedFiles+1))
            extension=${f##*"."}
            check=$(echo $extension | grep "sh")
            if [ "$check" != "" ]; then
                cmd=$(chmod 770 $f)
                if [ $? -ne 0 ]; then
                    echo " Fail to modify permission on file : "$f", you have to do it by yourself !"
                fi
            fi
        else
            echo " Sed command failed using sed s|$secureStringSrc|$secureReplacementStr|g !"
        fi

    else
        if [ ! -d $f ]; then
            echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$f
            exit 1
        fi
    fi
done 

echo "-----------------------------------------------------------------------"
if [ $cr -eq 0 ]; then
    echo " Done."
    echo " $nbTreatedFiles files treated"
else
    echo " Errors happens."    
fi
exit $cr
