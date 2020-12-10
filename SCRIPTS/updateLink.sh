#!/bin/bash
## INSTRUCTIONS
## This script update link by replacing $strOldPath with $replacementPath in its targeted path
##
## USAGE : $0 [$linkPath] [$strOldPath] [$replacementPath] [-f*]
##
## $linkPath   : full path of the link to be updated
## $strOldPath :  string surrounded by "" that contain the part of targeted paths to replace
## $replacementPath :  string surrounded by "" that contain the replacement part of targeted paths
## -f : force updating lin even if its new target is not valid
##
## return code : 
##
##   cr = 0   : OK
##   cr = 1  : error when parsing linkPath
##   cr = 2  : broken links found
##   cr = 99 : invalid arguments 
cr=0

function Syntaxe
{
    echo "This script update link by replacing strOldPath with replacementPath in its targeted path"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [linkPath] [strOldPath] [replacementPath]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- linkPath        : full path of the link to be updated"
    echo "- strOldPath      : string surrounded by "" that contain the part of targeted paths to replace"
    echo "- replacementPath : string surrounded by "" that contain the replacement part of targeted paths"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 1  : error when parsing linkPath"
    echo "   cr = 2  : broken links found"
    echo "   cr = 99 : invalid arguments "
    echo " "
    echo "-----------------------------------------------------------------------"
}

# Checking args
# -------------
if [ $# -ne 3 ]
then
	Syntaxe
	exit 99
else
    # at least 3 args
    linkPath=$(printf '%q' "$1")

    strOldPath="$2"
    replacementPath="$3"
    
fi

## treating dot 
tmp=$(echo $strOldPath | sed "s|\.|\\\.|g")
secureStringSrc=$tmp

## treating '-' for grep
tmp=$(echo $secureStringSrc | sed "s|-|\\\-|g")
secureStringSrcForGrep=$tmp

## treating dot 
tmp=$(echo $replacementPath | sed "s|\.|\\\.|g")
secureStringTarget=$tmp

workingDir=$(pwd)

if [ -L $linkPath ]; then
    rootDir=$(printf '%q\n' "$(dirname $linkPath)")

    # link target
    target=$(readlink $linkPath)
    
    isConcerned=$(echo $target | grep "$secureStringSrcForGrep")
    if [ "$isConcerned" != "" ]; then
    
        newTargetedPath=$(echo $target | sed "s|$secureStringSrc|$secureStringTarget|g" | sed "s|//|/|g" )
        crSed=$?
        cd $rootDir
        
        if [ "$newTargetedPath" != "$target" -a $crSed -eq 0 ]; then
        
            # check if the target is valid 
#            if [ -f $newTargetedPath -o -d $newTargetedPath -o -L $newTargetedPath ]; then
                # unlink f
                rm -f $(printf '%q\n' "$linkPath")

                # recreate link 
                ln -s "$newTargetedPath" "$linkPath"
                if [ $? -eq 0 ]; then
                    echo " Link updated : "$linkPath 
                else
                    echo "ln command failed on $newTargetedPath for $linkPath"
                    cr=60  
                fi
#            else
#                echo " Not updating : new target for "$linkPath" does not exist or is a broken link ("$newTargetedPath")"
#                cr=1
#            fi
        fi
    fi
else
    echo "ERROR invalid linkPath (does not exist : "$linkPath") or file/folder as 1st argument"
    cr=50
fi
cd $workingDir
exit $cr
