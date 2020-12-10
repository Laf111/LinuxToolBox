#!/bin/bash
##
## INSTRUCTIONS
##
## This script find broken links in pathRoot and optionally delete them [-d*]
##
## USAGE : $0  [$pathRoot] [depth*] [-d*]
##
## $pathRoot : path of directory to be scanned
## $depth (optionnal) : searching depth
## -d : delete results (optionnal)
##
## RETURN CODE : 
##
##   cr = 0     : OK
##   cr = 1 : broken links exists
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script find broken links in pathRoot and optionally delete them [-d*]"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [pathRoot] [depth*] [-d*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- pathRoot : path of directory to be scanned"
    echo "- depth : searching depth (optionnal)"
    echo "- -d : delete results (optionnal)"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : non nroken links found"
    echo "   cr = 1  : broken links founnd"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

cr=0

# Checking args
# -------------
if [ $# -lt 1 ]
then
	Syntaxe
	exit 99
else
    if [ $# -gt 3 ]
    then
	    Syntaxe
	    exit 99
    else
        # pathRoot
        pathRoot=$1
        if [ $# -eq 2 ]
        then
            # optional arg
            arg=$2
            
            if [ "$arg" == "-d" ]; then
                delete=$arg
            else 
                depth=$arg
            fi
        fi
        if [ $# -eq 3 ]
        then
            # optional arg
            arg=$3
            
            if [ "$arg" == "-d" ]; then
                delete=$arg
            else 
                depth=$arg
            fi
        fi
    fi
fi

if [ "$depth" != "" ]; then
    depthOption=" -maxdepth "$depth
fi


# checking $pathRoot
if [ ! -d "$pathRoot" ]; then
    echo "ERROR invalid pathRoot : ("$pathRoot") !"
    exit 99
fi

cd $pathRoot
# links count
number=$(find ./ $depthOption -type l | wc -l)

if [ $number -ne 0 ]; then

    fileLinksFound=0
    folderLinksFound=0
    fullPathLinksFound=0
    relPathLinksFound=0
    
    links=$(find ./ $depthOption -type l)
    for l in $links; do

        if [ -L $l ]; then

            finalTarget=$(readlink -f $l)
            target=$(readlink $l)

            # check if the link is a full path to the finalTarget
            check=${target%%"/"*}
            if [ "$check" == "" ]; then
                # count link with full path
                fullPathLinksFound=$(($fullPathLinksFound+1))
                
            else
                # count link with relative path
                relPathLinksFound=$(($relPathLinksFound+1))
            fi

            if [ "$finalTarget" == "" ]; then

                echo " File broken link : "$l
                fileLinksFound=$(($fileLinksFound+1))
                if [ "$delete" != "" ]; then
                    rm -rf $l
                fi
                cr=1

            else
                # case of folder link
                if [  -d $l  -a  ! -d $finalTarget  ]; then
                    echo " Folder broken link : "$l" to "$finalTarget
                    folderLinksFound=$(($folderLinksFound+1))

                    if [ "$delete" != "" ]; then
                        rm -rf $l
                    fi
                    cr=1
                else
                    if [ ! -f $finalTarget -a  ! -d $finalTarget ]; then

                        echo " Broken link : "$l" pointing to "$finalTarget
                        fileLinksFound=$(($fileLinksFound+1))
                        if [ "$delete" != "" ]; then
                            rm -rf $l
                        fi
                        cr=1
                    fi

                fi
            fi
        else
            echo "ERROR invalid pathRoot : check if character ' ' (space) is not present in the tree!, error come with : "$l
            exit 99
        fi
    done
    
    
    if [ $fileLinksFound -ne 0 -o $folderLinksFound -ne 0 ]; then
        echo " Number of file broken links found : "$fileLinksFound
        echo " Number of folder broken links found : "$folderLinksFound
        echo "-----------------------------------------------------------------------"
    else
        echo " No broken links found"
        echo "-----------------------------------------------------------------------"
    fi
    
    printf " Number of links : "$number"\n"
    echo " -> ("$fullPathLinksFound") with full paths"
    echo " -> ("$relPathLinksFound") with relative paths"

fi

# exit
exit $cr



