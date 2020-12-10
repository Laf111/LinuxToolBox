#!/bin/bash
## INSTRUCTIONS
## This script create a similary tree of pathSrc in pathTarget only with links (including folders links)
##
## NOTES : 
## - Existants links are copied in pathTarget
## - by default : relative links are created for files sharing at least the firts folder of their path 
##   (present on a same HDD) else full path are created
##
## USAGE : $0 [$pathSrc] [$pathTarget] [-nrp*]
##
## $pathSrc        : path of directory to be linked
## $pathTarget     : path of the destination directory (where create the links)
## -nrp (optional) : non creating relatives path option (more speed) 
##
## IMPORTANT NOTE :
## Folders are also linked => if you modify or create file in pathTarget, you will modify pathSrc !!!
## Don't forget to use replaceLink.sh or replaceLinks.sh if you want to modify a file in pathTarget !!!
##
## return code : 
##
##   cr = 0   : OK
##   cr = 1   : warnings
##   cr = 2   : broken links found
##   cr = 3   : errors
##   cr = 99  : invalid arguments 
cr=0

function Syntaxe
{
    echo "This script create a similary tree of pathSrc in pathTarget only with links (including folders links)"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pathSrc] [pathTarget] [-nrp*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathSrc         : path of directory to be linked"
    echo "- pathTarget      : path of the destination directory (where create the links)"
    echo "- -nrp (optional) : non creating relatives path option (more speed) "
    echo " "
    echo "NOTES : "
    echo " Folders are also linked => if you modify or create file in pathTarget, you will modify pathSrc !!!"
    echo " Don't forget to use replaceLink.sh or replaceLinks.sh if you want to modify a file in pathTarget !!!"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 1  : warnings"
    echo "   cr = 2  : broken links found"
    echo "   cr = 3  : errors"
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

################################################################################
# MAIN PROGRAM                                                                  
################################################################################


# by default, creating relative links
buildRelativePath=1


# Checking args
# -------------
if [ $# -lt 2 ]
then
    Syntaxe
    exit 99
else
    if [ $# -gt 3 ]
    then
        Syntaxe
        exit 99
    else

        # pathSrc
        pathSrc=$1

        # pathTarget
        pathTarget=$2

        if [ $# -eq 3 ]; then
            if [ $3 == "-nrp" ]; then
                buildRelativePath=0
            fi
        fi

    fi
fi

cr=0
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#getting full Path of PathSrc
GetDirectoryFullPath $pathSrc
cr=$?
if [ $cr -eq 0 ]; then
    pathSrc=$fullPath
else
    echo "ERROR invalid full PathSrc computed : ("$fullPath") !"
    exit 99
fi

#getting full Path of pathTarget
GetDirectoryFullPath $pathTarget
cr=$?
if [ $cr -eq 0 ]; then
    pathTarget=$fullPath
else
    echo "ERROR invalid full pathTarget computed : ("$fullPath") !"
    exit 99
fi

# create empty sub folders under INPUT and OUTPUT if needed
subFolderList=$(find -L $pathSrc -mindepth 1 -maxdepth 2 -empty -type d )

for sf in $subFolderList; do
    if [ -d $sf ]; then
        # create subfolder
        rootDir=$(dirname $sf)

        pathSrcExp=$(echo $pathSrc | sed 's/\//\\\//g')
        tmp=${rootDir#$pathSrcExp}
        relativeDir=${tmp:1}

        mkdir -p $pathTarget/$relativeDir
    fi
done


# handling files
fileList=$(find $pathSrc -type f)

for f in $fileList; do
    if [ -f $f ]; then

        rootDir=$(dirname $f)

        pathSrcExp=$(echo $pathSrc | sed 's/\//\\\//g')
        tmp=${rootDir#$pathSrcExp}
        relativeDir=${tmp:1}
        
        filename=$(basename $f)

        mkdir -p $pathTarget/$relativeDir

        ln -s $pathSrc/$relativeDir/$filename $pathTarget/$relativeDir/$filename
    else
        echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree !, error come with : "$f
        exit 99
    fi
done

# handling links
linkList=$(find $pathSrc -type l)

for f in $linkList; do

    if [ -L $f ]; then
        rootDir=$(dirname $f)

        pathSrcExp=$(echo $pathSrc | sed 's/\//\\\//g')
        tmp=${rootDir#$pathSrcExp}
        relativeDir=${tmp:1}

        if  [ ! -d $pathTarget/$relativeDir ]; then
            mkdir -p $pathTarget/$relativeDir
        fi

        target=$(readlink -f $f)
        if [ "$target" == "" ]; then
            echo " WARNING : link "$f" is broken ! ignore it !"
        else
            filename=$(basename $f)
        
            # check if immediate target is pointed with a relative path
            immediateTarget=$(readlink $f)
            check=${immediateTarget%%"/"*}
            if [ "$check" != "" ]; then
                # relative path : recreate a full path link
                unlink $f
                ln -s $target $pathTarget/$relativeDir/$filename
            else
                # full path : copy the link            
                cp -d $f $pathTarget/$relativeDir/$filename
            fi
        fi
    else
        echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$f
        exit 99
    fi

done

if [ $buildRelativePath -eq 1 ]; then
    ## transform full Link to relative one
    cmd=$(updateLinksWithRelativePath.sh $pathTarget)
    cr=$?
fi

exit $cr
