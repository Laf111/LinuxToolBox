#!/bin/bash
##
## Install script of Linux ToolBox
##
################################################################################
# 18/11/15 LAF111 : creation version 1.0


# full path to the parent directory this script 
installScriptParentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# check if tools are already installed
envScriptFullPath=$installScriptParentDirFullPath/env.sh

isInstalled=$(more $HOME/.bashrc | grep $envScriptFullPath)
if [ "$isInstalled" == "" ]; then
    # sourcing linux tool box
    . $installScriptParentDirFullPath/env.sh
    # add to bashrc
    echo "" >> $HOME/.bashrc
    echo "# sourcing Linux ToolBox" >> $HOME/.bashrc
    echo ". "$envScriptFullPath >> $HOME/.bashrc
    echo "" >> $HOME/.bashrc
    # add an argument "-s" for silent mode
    if [ $# -ne 1 ]; then
        if [ "$1" != "" ]; then
            if [ $1 -eq "-s" ]; then
                # listing tool
                echo " listing tool : "
                echo "> Strike ENTER key to list available tools or CTRL+C to quit"
                read next
                clear
                listTools.sh
            fi
        fi
    fi
    exit 0
else
    echo " Linux ToolBox is alread installed ! clean your .bashrc first"
    exit 1
fi
