#!/bin/bash

## INSTRUCTIONS
## This script get memory and io info on a given process id
## 
##
## USAGE : $0 [procId]
##
## $procId : id of thee process
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
    echo "This script get memory and io info on a given process id"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [procId] "
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- procId : id of thee process"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : results available"
    echo "   1 : results unavailable"
    echo "  99 : args error"
    echo "-----------------------------------------------------------------------"
}

procId=$1

#measure period in millisecond
period=500

if [ -z ${procId} ]
then 
  Syntaxe
  exit 99;
 fi

while [ -z ${procId} ]
do
  :
done
 


# build path to file to analyse in proc table
memlog="/proc/${procId}/status"
iolog="/proc/${procId}/io"

mem="unavailable"
ior_real="unavailable"
iow_real="unavailable"
ior_virt="unavailable"
iow_virt="unavailable"
stat="unavailable"

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

    if [ -e /proc/${procId} ]; then
        stat=" memory(kB)="${mem}"\n io_real_read(Byte)="${ior_real}"\n io_realwrite(Byte)="${iow_real}"\n io_virt_read(Byte)="${ior_virt}"\n io_virt_write(Byte)="${iow_virt}
    fi

    usleep $period
done

if [ "$stat" != "" ]; then
    printf "$stat"
else
    exit 1
fi

