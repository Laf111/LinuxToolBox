#!/bin/bash
##
## INSTRUCTIONS
##
## This script list all the available tools
##
## USAGE : $0 
##
## RETURN CODE : 
##
##   cr = 0   : OK

# define colors
red=$(tput setaf 1)
blue=$(tput setaf 4)
black=$(tput setaf 9)
purple=$(tput setaf 5)
bold=$(tput bold)
reset=$(tput sgr0)

# full path to the parent directory this script 
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
rootPath=$(dirname $parentDirFullPath)

function printHelpTools
{
    scripts=$(find -L $rootPath/$folder -type f -name "*.sh" | grep -v "listTools" | sort)
    for s in $scripts; do
        if [ "$s" != "$0" ]; then
            echo $red"======================================================================="$bold
            echo $(basename $s)
            echo $reset
            $s
        fi
    done
}

clear
folder=SCRIPTS
printHelpTools
echo $black"======================================================================="$reset
echo "  - "$red$bold"xml starlet 1.5.0"$reset
echo "  - "$red$bold"XmlCheck "$reset"(verif XSD)"
echo $black"-----------------------------------------------------------------------"$reset$bold
echo " Alias list :"
echo ""
more $rootPath/env.sh | grep "^alias"
echo $black"======================================================================="$reset

