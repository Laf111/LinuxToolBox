#!/bin/bash
##
## INSTRUCTIONS
##
## This script clean the given path's children folder from the following file's extension : "*.*~ *.diff.txt *.hdr"
##
## USAGE : $0 [$workingDirPath] 
##
## $workingDirPath : path of directory to be checked without final '/'
##
## RETURN CODE : 
##
##   cr = 0  : OK
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script clean the given path's children folder from the following file's extension : '*.*~ *.diff.txt *.hdr'"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : "$0" [workingDirPath]  "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- workingDirPath : path of directory to be checked without final '/'"
    echo " "
    echo "RETURN CODE : "
    echo "   cr = 0  : OK"
    echo "   cr = 99 : invalid arguments "
    echo "-----------------------------------------------------------------------"
}

# Checking args
# -------------
if [ $# -ne 1 ]
then
	Syntaxe
	exit 99
fi

# workingInputDirFullPath
workingDirPath=$1

# checking $workingDirPath
if [ ! -d "$workingDirPath" ]; then
    echo "ERROR invalid workingDirPath : ("$workingDirPath") !"
    exit 99
fi


# file extensions to clean 
filesExt="*.*~ *.diff.txt *.hdr *.gfs"
filesExtList=($filesExt)
nbExts=$(echo ${#filesExtList[@]})

# parent directory
parentDir=$(dirname $0)
echo "#######################################################################" 
echo " Cleaning form "$filesExt" ..."

for ((i=0; i<nbExts; i++)); do

    ext="${filesExtList[i]}"
    echo cleaning $ext files
    find $workingDirPath -iname "$ext" -exec rm -rf {} \;

done

# successfully exit
echo "#######################################################################" 
echo " Done successfully, exit 0"
exit 0

