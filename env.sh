#!/bin/bash
##
## Linux ToolBox environnement
##
################################################################################
# 18/11/15 LAF111 : creation version 1.0

# full path to the parent directory this script 
envScriptParentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function printFolderTools
{
    scripts=$(find -L $envScriptParentDirFullPath/$folder -type f -name "*.sh" -exec basename {} \; | sort)
    echo "  - "$scripts
}


# setting terminal colors
# -----------------------
export GREP_OPTIONS='--color=auto'
red=$(tput setaf 1)
blue=$(tput setaf 4)
black=$(tput setaf 9)
purple=$(tput setaf 5)
bold=$(tput bold)
reset=$(tput sgr0)

PS1="\\[$bold\]\[$red\]<\[$blue\][\[$purple\]\u\[$red\]@\[$black\]\h\[$blue\]]\[$red\]\W\[$blue\](\[$purple\]pid\[$black\]=\[$red\]$$\[$black\]:\[$purple\]cr\[$black\]=\[$red\]\$?\[$blue\])\[$red\]>\[$black\]\\$\[$reset\] "

# BUG LINUX : if username exceed 8 characters (9 including empty string), ps used $UID instead of $USER in its first column)
nbCharUserName=$(echo $USER | wc -m)
if [ $nbCharUserName -gt 9 ]; then
    # compute UID
    str=$(getent passwd $USER)
    str=${str#*':'}
    str=${str#*':'}
    USERNAME=${str%%':'*}
else
    USERNAME=$USER
fi

# setting LD_LIBRARY_PATH to use tools (adding at the end of LD_LIBRARY_PATH)
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$envScriptParentDirFullPath/bin/nonReg/lib


# loading Toolbox if needed
check=$(echo $PATH | grep ToolBox)
if [ "$check" == "" ]; then


    # setting environnement (adding at the end of PATH)
    # ---------------------

    # setting PATH to use tools 
    export PATH=$PATH:/sbin:$envScriptParentDirFullPath/SCRIPTS:$envScriptParentDirFullPath/bin
fi
    
# common alliases
alias h='history' 
#alias ls='ls -lah' 
alias mkdir='mkdir -pv' 
alias meminfo='echo "======================================================================="; 
free -m -l -t; 
echo "======================================================================="; 
echo $bold" Effective memory"$reset" (used / total / left) : "'$red$bold$(cat /proc/meminfo | grep Active: | awk '{print $2}')'$reset" / "'$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}')'" / "'$purple$bold$[ $(cat /proc/meminfo | grep MemTotal: | awk '{print $2}') - $(cat /proc/meminfo | grep Active: | awk '{print $2}') ]'$reset;
echo "=======================================================================";
echo " Top 10 processes by memory usage : "; 
echo "-----------------------------------"$red;
ps -A --sort -rss -o user,pid,pmem,args | head -n 11; 
echo $reset"======================================================================="'
alias cpuinfo='lscpu'

alias cpr='cpr.sh' 
alias cpl='cp -rL' 
alias getAllMyJob='qstat -ext -t -s r -u '$USER
alias getAllMyProc='ps -eaf | grep -v "grep" | grep '$USERNAME 
alias getAllMyChildProc='ps -eaf | grep -v "grep" | grep '$USERNAME' | grep '$$
alias getChildProc='pgrep -l -P '$$

#sudo
alias size='sudo du -bhs' 
alias rexplorer='sudo nautilus --no-desktop --browser' 

# miscallenous alias
alias clear="clear; \
echo $red"==============================================================================" \
"

if [ -f $0 ]; then

    check=$(dirname $0)
    if [ "$check" != "." ]; then

        echo "======================================================================="
        echo " LinuxToolBox : this script needs to be sourced"
        echo "======================================================================="
        echo " Alias added : "
        echo "  - h=history"
        echo "  - mkdir=mkdir -pv"
        echo "  - meminfo=free -m -l -t"
        echo "  - cpuinfo=lscpu"
        echo "  - cpr='cpR.sh' "
        echo "  - cpl='cp -rL' "
        echo "  - getAllMyProc = ps -eaf | grep "$USERNAME
        echo "  - getAllMyProc = ps -eaf | grep "$USERNAME" | grep \$\$"
        echo "  - getChildProc = 'pgrep -l -P \$\$"

        #sudo
        echo "  - size='sudo du -bhs' "
        echo "  - rexplorer='sudo nautilus --no-desktop --browser' "

        echo "-----------------------------------------------------------------------"
        echo " scripts list :"
        folder=SCRIPTS
        printFolderTools
        echo "  - xml starlet 1.5.0"
        echo "  - XmlCheck (verif XSD)"
        echo "======================================================================="
    fi
fi
