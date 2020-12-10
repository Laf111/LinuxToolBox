#!/bin/bash

## INSTRUCTIONS
## This script create a similary tree of pathSrc in pathTarget only with links on file (recreate subfolders for folders's link)
##
## NOTES : 
## - Existants links are copied in pathTarget
## - by default : relative links are created for files sharing at least the firts folder of their path 
##   (present on a same HDD) else full path are created
## - Parent folders of file links are recreated (not linked)
##
## USAGE : $0 [$pathSrc] [$pathTarget] [ignoreDirs*] [-nrp*]
##
## $pathSrc    : path of directory to be linked
## $pathTarget : path of the destination directory (where create the links)
## $ignoreDirs (optionnal): reg exp patern to ignore directory creation
# -nrp (optional) : non creating relatives path option (more speed) 
##
## IMPORTANT NOTE : 
## Don't forget to use replaceLink.sh or replaceLinks.sh if you want to modify a file in pathTarget !!!
##
## return code : 
##
##   cr = 0   : OK
##   cr = 1   : warnings
##   cr = 2   : broken links found
##   cr = 3   : errors
##   cr = 99  : invalid arguments 

function Syntaxe
{
    echo "This script create a similary tree of pathSrc in pathTarget only with links on file (recreate subfolders for folders 's link)"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [pathSrc] [pathTarget] [ignoreDirs*] [-nrp*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathSrc    : path of directory to be linked"
    echo "- pathTarget : path of the destination directory (where create the links)"
    echo "- ignoreDirs (optionnal): reg exp patern to ignore directory creation"
    echo "- -nrp (optional) : non creating relatives path option (more speed) "
    echo " "
    echo "NOTES : "
    echo " Don't forget to use replaceLink.sh or replaceLinks.sh if you want to modify a file in pathTarget !!!"
    echo " "
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
            here=$(pwd)
            while [ "$check" != "" ]; do
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
if [ $# -gt 4 ]
then
	Syntaxe
	exit 99
else

    if [ $# -lt 2 ]
    then
	    Syntaxe
	    exit 99
    fi

    if [ $# -ge 2 ]; then
        # pathSrc
        pathSrc=$1

        # pathTarget
        pathTarget=$2
        
    fi
    
    # more args
    if [ $# -ge 3 ]; then
        if [ $3 == "-nrp" ]; then
            buildRelativePath=0
        else
            # 3 args
            ignoreDirs="$3"
        fi
        
        if [ $# -eq 4 ]; then
            if [ $4 == "-nrp" ]; then
                buildRelativePath=0
            else
                ignoreDirs="$4"
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

if [ "$ignoreDirs" == "" ]; then
    echo "Linking source path ("$pathSrc") in target ("$pathTarget") with creating directories ..."
else
    echo "Linking source path ("$pathSrc") in target ("$pathTarget") with creating directories but ignoring those matching the patern "$ignoreDirs"..."
fi

if [ $buildRelativePath -eq 0 ]; then
    echo "Non creating relative paths mode"
fi


# create empty sub folders under INPUT and OUTPUT if needed
subFolderList=$(find -L $pathSrc -mindepth 1 -maxdepth 2 -empty -type d )

for sf in $subFolderList; do
    # create subfolder
    rootDir=$(dirname $sf)

    pathSrcExp=$(echo $pathSrc | sed 's/\//\\\//g')
    tmp=${rootDir#$pathSrcExp}
    relativeDir=${tmp:1}

    name=$(basename $sf)
    mkdir -p $pathTarget/$relativeDir/$name
    
done

# handling files
fileList=$(find -L $pathSrc -type f)

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
linkList=$(find -L $pathSrc -type l)

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
            # file or dir name
            filename=$(basename $f)
            
            if [ -d $target ]; then

                # check if the directory has to be copied or link
                if [ "$ignoreDirs" != "" ]; then
                    check=$(echo $filename | grep "$ignoreDirs")
                    
                    if [ "$check" == "" ]; then 
                        # dir is not ignored : create the directory
                        mkdir -p $pathTarget/$relativeDir/$filename
                        $parentDirFullPath/linkPath.sh $target $pathTarget/$relativeDir/$filename -nrp
                    else
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

                    # dir : create the directory
                    mkdir -p $pathTarget/$relativeDir/$filename
                    $parentDirFullPath/linkPath.sh $target $pathTarget/$relativeDir/$filename -nrp
                fi

            else
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
        fi
    else
        echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$f
        exit 99
    fi

done

if [ $buildRelativePath -eq 1 ]; then
    ## transform full Link to relative one
    cmd=$($parentDirFullPath/updateLinksWithRelativePath.sh $pathTarget)
    cr=$?
fi
exit $cr
