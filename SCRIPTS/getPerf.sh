#!/bin/bash

## INSTRUCTIONS
## This script get cpuload, memory and io datas of a given process (id)
## It scan children process and log performances of executables with logPerf.sh launched 
## during the parent process execution
## If a patternList is given (4th arg oprionnal), it only log executable that the name match one of the given pattern
## It logs procId performance to the console output with the following line format : 
## Columns : delayFromStart totalCpuLoad totalMemory(Mo) memoryLoad(Ko) ioRead(Byte) ioWrite(Byte) ior_virt(Byte) iow_virt(Byte)
##
## USAGE : $0 [procId] [refreshStep] [outputFolder] [patternList*]
##
## $procId : id of thee process
## $refreshStep : time in seconds to scan process
## $outputFolder : output directory
## $patternList(optionnal) : list of pattern to filter process to log by name (given as a string surrounded by '\"'
##
## RETURN CODE : 
##
##   cr = 0  : results available
##   cr = 1  : results unavailable
##   cr = 99 : invalid arguments 
##
##

function Syntaxe
{
    echo "This script get cpuload, memory and io datas of a given process id"
    echo "It scan children process and log performances of executables with logPerf.sh launched "
    echo "during the parent process execution"
    echo "If a patternList is given (4th arg oprionnal), it only log executable that the name match one of the given pattern"
    echo "It logs procId performance to the console output with the following line format : "
    echo "Columns : delayFromStart totalCpuLoad totalMemory(Mo) memoryLoad(Ko) ioRead(Byte) ioWrite(Byte) ior_virt(Byte) iow_virt(Byte)"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [procId] [refreshStep] [outputFolder] [patternList*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- procId : id of thee process"
    echo "- refreshStep : time in seconds to scan process"
    echo "- outputFolder : output directory"
    echo "- patternList(optionnal) : list of pattern to filter process to log by name (given as a string surrounded by '\"'"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : results available"
    echo "   1 : results unavailable"
    echo "  99 : args error"
    echo "-----------------------------------------------------------------------"
    echo "  args ="$*
}

# recursive function to kill child process Tree
function SearchChildProcessToLog
{

    local pid=$1

    nbChilds=$(($nbChilds+1))
    childs=$(pgrep -P $pid)

    for c in $childs; do

        # recursive call
        SearchChildProcessToLog $c

        # c is a final process (no child at current time)
        check=$(echo $alreadyLogProcessList | grep $c)
        if [ "$check" == "" ]; then

            # verify if its match the patern
            
            # getting command line of $c
            cmd=$(ps --pid $c -o cmd h)

            # 2 formats :
            # /bin/sh /$shellFullPath/$shell-cso.sh args
            # /$exeFullPath/$exe args

            # ignoring shell, only focus on executable
            tmpPath=${cmd%%" "*}
            
            if [ "$tmpPath" != "" ]; then
                exeFilePath=$(readlink -f $tmpPath)

                check=$(echo $exeFilePath | grep -E "bin/(ba){0,1}sh" > /dev/null 2>&1)
                if [ "$check" == "" ]; then
                    
                    # ignoring created process with '[' in command line
                    check=$(echo $exeFilePath | grep "[" > /dev/null 2>&1)
                    if [ "$check" == "" ]; then
                    
                        # verify if process matchs a pattern
                        for p in $patternList; do
                        
                            # /$exeFullPath/$exe args
                            name=${exeFilePath##*"/"}

                            check=$(echo $name | grep -i $p)
                            if [ "$check" != "" ]; then
                                
                                cmdFilePath=${cmd#*" "}
                                cmdFileName=$(basename $cmdFilePath)
                                cmdFileName=${cmdFileName%%"."*}
                                
                                instant=$(date +"%Y_%m_%dT%H-%M-%S_%N")
                                
                                logFileName="pid-"${procId}"_"$instant"_"$name"_"$cmdFileName"_pid"$c".perf"
                                
                                logFile=$outputFolder/$logFileName
                                if [ -f $logFile ]; then
                                    rm -rf $logFile
                                fi
                                
                                # to avoid asynchronous problem, repeat check
                                check=$(echo $alreadyLogProcessList | grep $c)
                                if [ "$check" == "" ]; then
                                
                                    echo "# Logging process "$c" to "$logFile
                                    echo "# "$cmd" :" > $logFile
                                    echo "# " >> $logFile
                                    
                                    logPerf.sh $c $refreshStep $start >> $logFile 2>&1 &
                                    
                                    alreadyLogProcessList=$alreadyLogProcessList" "$c
                                fi
                            fi

                        done
                    fi
                fi
            fi
        else
            # process aleady log
            # echo to console only if all variables have been computed
            if [ -e /proc/$c ]; then
                # getting its CPU usage
                cpu=$(ps -u $USERNAME -o pid,%cpu | grep $c | awk '{cpu=$2} END {print cpu}')
                totalCpuLoad=$(echo "scale="$scale"; $totalCpuLoad + ($cpu / ($nbCpu*100))" | bc -q 2>/dev/null)
                
                # total mem in Mo (computed on each process used)
                totalMem=$(ps -p $c -O rss | gawk '{ sum+=$2}; END { print sum/1024 ;};')
            fi
        fi
    
    done

    return

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
# Default scale used by bc.
scale=2


if [ $# -lt 3 ]
then
    Syntaxe $*
    exit 99
else
    if [ $# -gt 4 ]
    then
        Syntaxe $*
        exit 99
    else
        procId=$1
        refreshStep=$2
        
        #getting full Path of outputFolder
        GetDirectoryFullPath $3
        cr=$?
        if [ $cr -eq 0 ]; then
            outputFolder=$fullPath
        else
            echo "ERROR invalid full outputFolder computed : ("$fullPath") !"
            exit 99
        fi
        
        # if a pattern list is given
        if [ $# -eq 4 ]
        then
            patternList="$4"
        fi
        
        # getting executable name (shell or binary file name)
        if [ ! -z ${procId} ]; then
        
            name=$(ps --pid $procId -o comm h)
            
            # getting startDate of the process
            startDate=$(ps -p $procId -o lstart=)
            start=$(date -d "$startDate" +'%s.%N')
        else
            exit 1
        fi
    fi
fi

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


# build path to file to analyse in proc table
memlog="/proc/${procId}/status"
iolog="/proc/${procId}/io"


ior_real="unavailable"
iow_real="unavailable"
ior_virt="unavailable"
iow_virt="unavailable"

stat="process "${procId}" is not running !\n"

# list of pattern to find -L process to log
alreadyLogProcessList=""

# get installed memory
installedMemory=$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}')
cpuStr=$(lscpu | grep "^CPU(s)")
nbCpu=$(echo ${cpuStr##*":"} | sed "s| ||g")

maxCpu=0
maxMem=0
minCpu=$(($nbCpu*100))
minMem=100


echo "#--------------------------------------------------------------------"
echo "# Host $HOSTNAME ($nbCpu cores, "$(($installedMemory/1048576))" Go RAM) "
echo "# Columns : delayFromStart totalCpuLoad(% on all cpu installed) totalMemory(Mo) memoryLoad(Ko) ioRead(Byte) ioWrite(Byte) ior_virt(Byte) iow_virt(Byte)"
echo "# (total means for this process and all of its childrens)"

while [ -e /proc/${procId} ]
do

    # initialize for current measure
    totalCpuLoad=0
    totalMem=0
    nbChilds=0

    # parse files
    if [ -f ${memlog} ]; then
        memNew=`grep VmRSS ${memlog}      | sed "s=VmRSS:==" | sed "s=kB=="`
        if [ "$memNew" != "" ]; then
            mem=$memNew
        fi
    fi

    if [ -f ${iolog} ]; then
        ior_realNew=`grep "^read_bytes" ${iolog}  | sed "s=read_bytes:=="`
        if [ "$ior_realNew" != "" ]; then
            ior_real=$ior_realNew
        fi
    fi

    if [ -f ${iolog} ]; then
        iow_realNew=`grep "^write_bytes" ${iolog} | sed "s=write_bytes:=="`
        if [ "$iow_realNew" != "" ]; then
            iow_real=$iow_realNew
        fi
    fi

    if [ -f ${iolog} ]; then
        ior_virtNew=`grep "^rchar" ${iolog}  | sed "s=rchar:=="`
        if [ "$ior_virtNew" != "" ]; then
            ior_virt=$ior_virtNew
        fi
    fi

    if [ -f ${iolog} ]; then
        iow_virtNew=`grep "^wchar" ${iolog} | sed "s=wchar:=="` 
        if [ "$iow_virtNew" != "" ]; then
            iow_virt=$iow_virtNew
        fi
    fi

    # search child processes that match the patern 
    SearchChildProcessToLog $procId
    if [ $nbChilds -eq 1 ]; then
    
        # getting its CPU usage
        
        tmp=$(ps -p ${procId} -o %cpu)
        arrayTmp=($tmp)
        
        percentOneCore=${arrayTmp[1]}
        totalCpuLoad=$(echo "scale=4; $percentOneCore / ($nbCpu*100)" | bc -q 2>/dev/null)

        # getting its memory usage
        # convert memory from Ko to Mo
        totalMem=$(echo "scale=4; ($mem / 1024)" | bc -q 2>/dev/null)
    fi

    maxCpuReached=0
    minCpuReached=0
    maxMemReached=0
    minMemReached=0

    if [ "$totalCpuLoad" != "" ]; then
        maxCpuReached=$(echo "scale=1; $totalCpuLoad > $maxCpu" | bc -q 2>/dev/null)
        maxCpuReached=${maxCpuReached%%"."*}
        if [ "$maxCpuReached" == "1" ]; then
            maxCpu=$totalCpuLoad
        fi

        minCpuReached=$(echo "scale=1; $totalCpuLoad < $minCpu" | bc -q 2>/dev/null)
        minCpuReached=${minCpuReached%%"."*}
        if [ "$minCpuReached" == "1" ]; then
            minCpu=$totalCpuLoad
        fi
    fi
    if [ "$totalMem" != "" ]; then
        maxMemReached=$(echo "scale=1; $totalMem > $maxMem" | bc -q 2>/dev/null)
        maxMemReached=${maxMemReached%%"."*}
        if [ "$maxMemReached" == "1" ]; then
            maxMem=${totalMem:0:3}
        fi

        minMemReached=$(echo "scale=1; $totalMem < $minMem" | bc -q 2>/dev/null)
        minMemReached=${minMemReached%%"."*}
        if [ "$minMemReached" == "1" ]; then
            minMem=${totalMem:0:3}
        fi
    fi
        
    stat="# min total CPU load percents = "${minCpu}"\n# max total CPU load percents = "${maxCpu}"\n# min total memory load Mo = "${minMem}"\n# max total memory load Mo = "${maxMem}"\n"

    now=$(date -u +"%s.%N")
    delayFromStart=$(echo "scale="$scale"; $now - $start" | bc -q 2>/dev/null)
    
    # echo to console only if all variables have been computed
    if [ -e /proc/${procId} ]; then
        
        echo $delayFromStart" "${totalCpuLoad}" "${totalMem}" "${mem}" "${ior_real}" "${iow_real}" "${ior_virt}" "${iow_virt}
    fi
    
    
    tmpList=$(ps --pid ${procId} -o etime)
    tmpArray=($tmpList)
    if [ "${tmpArray[1]}" != "" ]; then 
        timeLog="# process ellapsed time : "${tmpArray[1]}
    fi
    sleep $refreshStep

done



if [ "$stat" != "process "${procId}" is not running !\n" ]; then

    # redifining scale for bc (float precission)
    scale=6

    # Compute total IO stats in Mo
    totalIoRead=$(echo "scale="$scale"; ${ior_real} / 1048576" | bc -q 2>/dev/null)
    totalVirtualIoRead=$(echo "scale="$scale"; ${ior_virt} / 1048576" | bc -q 2>/dev/null)
    totalIoWrite=$(echo "scale="$scale"; ${iow_real} / 1048576" | bc -q 2>/dev/null)
    totalVirtualIoWrite=$(echo "scale="$scale"; ${iow_virt} / 1048576" | bc -q 2>/dev/null)

    # scan the outputFolder to compute total io statistics
    perfFiles=$(find -L $outputFolder/ -mindepth 1 -maxdepth 1 -name "*${procId}*.perf")
    
    for pf in $perfFiles; do
        # getting the last line of pf file
        lastLine=$(tac "$pf" | sed /"#"/d | sed /"grep"/d | sed -n '/^\s*$/!{p;q}' | grep -v "is not running")

        # lastLine could be empty if refreshStep is too low
        check=$(echo $lastLine | grep -v "^$");
        if [ "$check" != "" ]; then


            # list to array
            ioArray=($lastLine)

            iow_virt=${ioArray[7]}
            ior_virt=${ioArray[6]}
            iow_real=${ioArray[5]}
            ior_real=${ioArray[4]}
            
            # convert bytes to MegaBytes
            iow_virt=$(echo "scale="$scale"; $iow_virt / 1048576" | bc -q 2>/dev/null)
            ior_virt=$(echo "scale="$scale"; $ior_virt / 1048576" | bc -q 2>/dev/null)
            iow_real=$(echo "scale="$scale"; $iow_real / 1048576" | bc -q 2>/dev/null)
            ior_real=$(echo "scale="$scale"; $ior_real / 1048576" | bc -q 2>/dev/null)

            totalIoRead=$(echo "scale="$scale"; $totalIoRead + ${ior_real}" | bc -q 2>/dev/null)
            totalVirtualIoRead=$(echo "scale="$scale"; $totalVirtualIoRead + ${ior_virt}" | bc -q 2>/dev/null)
            totalIoWrite=$(echo "scale="$scale"; $totalIoWrite + ${iow_real}" | bc -q 2>/dev/null)
            totalVirtualIoWrite=$(echo "scale="$scale"; $totalVirtualIoWrite + ${iow_virt}" | bc -q 2>/dev/null)

        fi
    done

    echo "#--------------------------------------------------------------------"
    printf "$timeLog\n"
    stat=$stat"# total io_real_read Mo = "$totalIoRead"\n# total io_realwrite Mo = "$totalIoWrite"\n# total io_virt_read Mo = "$totalVirtualIoRead"\n# total io_virt_write Mo = "$totalVirtualIoWrite
    printf "$stat\n# (total means taking all children processes into account)\n"
    echo "#--------------------------------------------------------------------"
    
    # kill all child processes
    silentCmd=$(killProcessTree.sh $$ > /dev/null 2>&1 &)
    
else
    printf "$stat\n"
    exit 1
fi


