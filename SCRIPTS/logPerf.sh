#!/bin/bash

## INSTRUCTIONS
## This script log cpuload, memory and io datas of a given process id to the console output
## with the following line format : delayFromRefDate delayFromStart cpuLoad memory(kB) ior_real(Byte) iow_real(Byte) ior_virt(Byte) iow_virt(Byte)
## delayFromStart is computed in seconds and use system time start date of the process
## delayFromRefDate = delayFromStart if no refDateStamp is given (optionnal 3rd arg)
##
## USAGE : $0 [procId] [refreshStep] [refDateStamp*]
##
## $procId : id of thee process
## $refreshStep : time in seconds to scan process
## $refDateStamp (optionnal) : reference date time stamp (nb seconds since LINUX epoch 1970/01/01, return of the command 'date -d "$date" +"%s"')
##
## NOTE : 
##
## '#' is used for comment lines in log.: by redirecting console output to a file, you
## can get only the data to plot with the command : more $logFile | grep -v "#"
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
    echo "This script log cpuload, memory and io datas of a given process id to the console output"
    echo "with the following line format : delayFromRefDate delayFromStart cpuLoad memory(kB) ior_real(Byte) iow_real(Byte) ior_virt(Byte) iow_virt(Byte)"
    echo "delayFromStart is computed in seconds and computed using system time start date of the process"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [procId] [refreshStep] [refDateStamp*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- procId : id of thee process"
    echo "- refreshStep : time in seconds to scan process"
    echo "- refDateStamp (optionnal) : reference date time stamp (nb seconds since LINUX epoch 1970/01/01, return of the command : date -d date +'%s'"
    echo " "
    echo " NOTE : "
    echo " "
    echo " '#' is used for comment lines in log.: by redirecting console output to a file, you"
    echo ' can get only the data to plot with the command : more $logFile | grep -v \"#\"'
    echo " "
    echo "RETURN CODE :"
    echo "   0 : results available"
    echo "   1 : results unavailable"
    echo "  99 : args error"
    echo "-----------------------------------------------------------------------"
}

# Default scale used by bc.
scale=12



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
    
        procId=$1

        #measure refreshStep in millisecond
        refreshStep=$2

        if [ -z ${procId} ]
        then 
          Syntaxe
          exit 99;
        else
            # getting startDate of the process
            startDate=$(ps -p $procId -o lstart=)
            start=$(date -d "$startDate" +'%s.%N')
            # default
            refDate=$start
        fi
        if [ $# -eq 3 ]; then
            refDate=$3
        fi
    fi
fi

# build path to file to analyse in proc table
memlog="/proc/${procId}/status"
iolog="/proc/${procId}/io"

mem="unavailable"
ior_real="unavailable"
iow_real="unavailable"
ior_virt="unavailable"
iow_virt="unavailable"
stat="process "${procId}" is not running !\n"

# get installed memory
installedMemory=$(cat /proc/meminfo | grep MemTotal: | awk '{print $2}')
cpuStr=$(lscpu | grep "^CPU(s)")
nbCpu=$(echo ${cpuStr##*":"} | sed "s| ||g")

maxCpu=0
maxMem=0
minCpu=$(($nbCpu*100))
minMem=100

lastDuration=""

echo "# Host $HOSTNAME"
echo "# Columns : delayFromRefDate delayFromStart cpuLoad memory(kB) ior_real(Byte) iow_real(Byte) ior_virt(Byte) iow_virt(Byte)"

while [ -e /proc/${procId} ]
do
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


    tmp=$(ps -p ${procId} -o %cpu)
    arrayTmp=($tmp)
    percentOneCore=${arrayTmp[1]}
    cpuLoad=$(echo "scale=4; $percentOneCore / ($nbCpu*100) " | bc -q 2>/dev/null)

    
    now=$(date -u +"%s.%N")
    delayFromStart=$(echo "scale="$scale"; $now - $start" | bc -q 2>/dev/null)
    delayFromRefDate=$(echo "scale="$scale"; $now - $refDate" | bc -q 2>/dev/null)

    # echo to console only if all variables have been computed
    if [ -e /proc/${procId} ]; then
        echo $delayFromRefDate" "$delayFromStart" "${cpuLoad}" "${mem}" "${ior_real}" "${iow_real}" "${ior_virt}" "${iow_virt}

        maxCpuReached=0
        minCpuReached=0
        maxMemReached=0
        minMemReached=0
        
        maxCpuReached=$(echo "scale=1; $cpuLoad > $maxCpu" | bc -q 2>/dev/null)
        maxCpuReached=${maxCpuReached%%"."*}
        if [ "$maxCpuReached" == "1" ]; then
            maxCpu=$cpuLoad
        fi

        maxMemReached=$(echo "scale=1; $mem > $maxMem" | bc -q 2>/dev/null)
        maxMemReached=${maxMemReached%%"."*}
        if [ "$maxMemReached" == "1" ]; then
            maxMem=$(echo $mem | sed "s| ||g")
        fi

        minCpuReached=$(echo "scale=1; $cpuLoad < $minCpu" | bc -q 2>/dev/null)
        minCpuReached=${minCpuReached%%"."*}
        if [ "$minCpuReached" == "1" ]; then
            minCpu=$cpuLoad
        fi

        minMemReached=$(echo "scale=1; $mem < $minMem" | bc -q 2>/dev/null)
        minMemReached=${minMemReached%%"."*}
        if [ "$minMemReached" == "1" ]; then
            minMem=$(echo $mem | sed "s| ||g")
        fi
        
        stat="# min CPU load = "${minCpu}"\n# max CPU load = "${maxCpu}"\n# min memory load (kB) = "${minMem}"\n# max memory load (kB) = "${maxMem}"\n# io_real_read(Byte) = "${ior_real}"\n# io_real_write(Byte) = "${iow_real}"\n# io_virt_read(Byte) = "${ior_virt}"\n# io_virt_write(Byte) = "${iow_virt}

        tmpList=$(ps --pid ${procId} -o etime)
        tmpArray=($tmpList)
        if [ "${tmpArray[1]}" != "" ]; then 
            timeLog="# process ellapsed time : "${tmpArray[1]}
        fi


    fi

    sleep $refreshStep

done

if [ "$stat" != "process "${procId}" is not running !\n" ]; then
    echo "#--------------------------------------------------------------------"
    printf "$timeLog\n"
    printf "$stat\n"
    echo "#--------------------------------------------------------------------"
else
    printf "$stat\n"
    exit 1
fi

