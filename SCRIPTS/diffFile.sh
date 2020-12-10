#!/bin/bash

## INSTRUCTIONS
## This script diff two files using csoTest* and output results to the console
## on XML file nodes order is ignored ! (xsd reference too)
## 
## if the file is an ASCII one, csoTestASCII is used
## if the file is an raster image one, csoTestImage is used
## if the file is an binary one, csoTestBinary is used
## if the file is an vector image one, csoTestOGR is used
##
## USAGE : $0 [ficRes] [ficRef] [confFile*]
##
## $ficRes : path of file tested
## $ficRef : path of reference file
## $confFile is optionnal : full path of a file containing patterns to exclude ASCII lines from comparison
##
## RETURN CODE : 
##
##   cr = 0  : identical files
##   cr = 1  : differences found 
##   cr = 98 : user interruption
##   cr = 99 : invalid arguments 
##
##

# TODO : externaliser les outils a utiliser pour les diff a l'aide d'un filtre sur les fichiers
# definit dans le fichier de conf via une map [ filtre , outil de diff ]
# ex : *.LUM $toolsPath/bin/lumToolBox/lumcmp

function Syntaxe
{
    echo "This script diff two files using csoTest* and output results to the console"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [ficRes] [ficRef] [confFile*]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "- ficRes : path of file tested"
    echo "- ficRef : path of reference file"
    echo "- confFile is optionnal : path of a file containing patterns to exclude ASCII lines from comparison"
    echo " "
    echo "RETURN CODE :"
    echo "   0 : identical files"
    echo "   1 : differences found"
    echo "  98 : user interruption"
    echo "  99 : args error"
    echo "-----------------------------------------------------------------------"
}


# Clean modifications (trap action)
function CleanUp
{

    if [ "$flatFicRef" != "" ]; then
        rm -f $currentDir/*_"$ficResName"_*.xml > /dev/null 2>&1
        rm -f $currentDir/*_"$ficResName"_*.xml.* > /dev/null 2>&1
        rm -f $currentDir/*_"$ficRefName"_*.xml > /dev/null 2>&1
        rm -f $currentDir/*_"$ficRefName"_*.xml.* > /dev/null 2>&1
    fi
    
    # kill process's child
    $toolsPath/SCRIPTS/killProcessTree.sh $$
}


function RemoveXsdReference {

    echo '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>' > $1.0
    
    secondLine=$(more $1 | grep "xmlns")
    if [ "$secondLine" != "" ]; then
        check=$(echo $secondLine | grep " ")
        if [ "$check" != "" ]; then
            # extract node name
            tmp=${secondLine%%" "*}
            node=${tmp:1}
            echo "<$node>" >> $1.0
            $toolsPath/bin/xml fo -t $1 | grep -v "xmlns" | grep -v "?xml" >> $1.0
            
            
        else
            rm $1
            mv $1.0 $1
        fi
    fi    


    
#    $toolsPath/bin/xml fo -t $1 | grep -v "xmlns" > $1.0

#    secondLine=$(more $1.0 | grep "xmlns")
#    if [ "$secondLine" != "" ]; then
#        check=$(echo $secondLine | grep " ")
#        if [ "$check" != "" ]; then
#            # extract node name
#            tmp=${secondLine%%" "*}
#            node=${tmp:1}
#            # remplacement dans le fichier
#            more $1.0 | grep -v '<!--' | sed "s|$secondLine|<$node>|g" > $1
#            rm $1.0    
#
#        else
#            rm $1
#            mv $1.0 $1
#        fi
#    fi

}

# return code
cr=0

#
## Checking args
#
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
	    ficRes=$(printf '%q\n' "$1")
	    ficRef=$(printf '%q\n' "$2")
	    
		if [ $# -eq 3 ]
		then
			# third arg = ignore ASCII line patterns
			ignore_patterns_list_file="$3"
			if [ ! -f $ignore_patterns_list_file ]; then
                echo "Error : ignore_patterns_list_file ("$ignore_patterns_list_file") doesn't exist"
                exit 99    
            fi
		fi
	fi
fi

# full path to the parent directory this script 
parentDirFullPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

toolsPath=$(dirname $parentDirFullPath)


# setting LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$toolsPath/bin/nonReg/lib:$toolsPath/bin/gdal/lib:$toolsPath/bin/gdal/lib/gdalplugins:$toolsPath/bin/lumToolBox:$LD_LIBRARY_PATH
export PATH=$toolsPath/bin:$toolsPath/bin/nonReg/bin:$toolsPath/bin/gdal/bin:$toolsPath/bin/lumToolBox:$PATH
export GDAL_DRIVER_PATH=$$toolsPath/bin/gdal/lib/gdalplugins

# string pattern to search on results (initialise for csoTest tools)
strOK="(Pas de difference|Nb lines differents : 0)";


# check if this ficRes is given using relative path
pos=`expr index "$ficRes" "."`
if [ $pos -eq 1 ]; then
    # ficRes is given using relative path
    parentDirName=${ficRes:2}
    ficRes=$(pwd)/$parentDirName
fi

# check if this ficRef is given using relative path
pos=`expr index "$ficRef" "."`
if [ $pos -eq 1 ]; then
    # ficRef is given using relative path
    parentDirName=${ficRef:2}
    ficRef=$(pwd)/$parentDirName
fi

# check if this ignore_patterns_list_file is given using relative path
pos=`expr index "$ignore_patterns_list_file" "."`
if [ $pos -eq 1 ]; then
    # ficRef is given using relative path
    parentDirName=${ignore_patterns_list_file:2}
    ignore_patterns_list_file=$(pwd)/$parentDirName
fi


# handling links
if [ -L "$ficRes" ]; then
    ficRes=$(readlink -f "$1")
fi
if [ -L "$ficRef" ]; then
    ficRef=$(readlink -f "$2")
fi

if [ ! -f "$ficRes" ]; then
    echo "Error : ficRes ("$ficRes") doesn't exist"
    exit 99
fi
if [ ! -f "$ficRef" ]; then
    echo "Error : ficRef ("$ficRef") doesn't exist"
    exit 99    
fi


# catching kill signals (except kill -9 of course)
trap "CleanUp; echo ERROR : user interruption !; exit 98" SIGHUP SIGINT SIGTERM

# checking files nature (ASCII, Image raster, Image Vector)
resDir=$(dirname "$ficRes")
ficResName=$(basename "$ficRes")

currentDir=$(pwd)
cd $resDir
isASCII=$(file "$ficResName" | grep " text")
if [ "$isASCII" != "" -a "$check" == "" ]; then

    # check if ASCII file is an XML one : 
    isXml=$(more $ficRef | grep "<?xml")
    if [ "$isXml" != "" ]; then

        # clean if necessary
        rm -rf tmpRes_$ficResName*.xml
        rm -rf flatRes_$ficResName*.xml
        rm -rf tmpRef_$ficResName*.xml
        rm -rf flatRef_$ficResName*.xml

        now=$(date +"%Y_%m_%dT%H-%M-%S_%N")
        # overriding ficRes and ficRef
        ficResName=$(basename $ficRes)
        tmpFicRes=$currentDir/tmpRes_$ficResName"_"$now.xml
        cp -rf $ficRes $tmpFicRes
        # remove xsd reference if needed
        RemoveXsdReference $tmpFicRes            
        flatFicRes=$currentDir/flatRes_$ficResName"_"$now.xml
        
        now=$(date +"%Y_%m_%dT%H-%M-%S_%N")
        ficRefName=$(basename $ficRef)
        tmpFicRef=$currentDir/tmpRef_$ficRefName"_"$now.xml
        cp -rf $ficRef $tmpFicRef

        RemoveXsdReference $tmpFicRef            
        flatFicRef=$currentDir/flatRef_$ficRefName"_"$now.xml

        # convert xml file to a "flat one" sorted alphabetically
        # (add '-u' to sort to avoid identicals lines)
        # + convert xmlreduce output lines to to Xpath syntax
        $toolsPath/bin/xmlreduce/xmlreduce.sh $tmpFicRes | sort | sed "s| |_|g" | sed "s|,_|\"\]\[@|g" | sed "s|:|=\"|g" | sed "s|\[\[|\[@|g" | sed "s|\]\]|\"\]|g" | sed "s|\"\"|\"|g" > $flatFicRes
        $toolsPath/bin/xmlreduce/xmlreduce.sh $tmpFicRef | sort | sed "s| |_|g" | sed "s|,_|\"\]\[@|g" | sed "s|:|=\"|g" | sed "s|\[\[|\[@|g" | sed "s|\]\]|\"\]|g" | sed "s|\"\"|\"|g" > $flatFicRef

        # overriding ficRes & ficRef
#        ficRes=$flatFicRes
#        ficRef=$flatFicRef
    fi

    # ignored line file
    if [ -f "$ignore_patterns_list_file" ]; then
        # getting exclude patterns for ASCII lines
        patterns_list=($(more $ignore_patterns_list_file | grep -v "#"))
        patterns=${patterns_list[@]}
        nblines=$(echo ${#patterns_list[@]})
        
        #diff using csoTestASCII ignoring files 
        diffResults=$($toolsPath/bin/nonReg/bin/csoTestASCII $flatFicRef $flatFicRes --ignore-lines-with $nblines $patterns --overwriting-path-diff $currentDir | sed "s| ||g")
        
    else
        #diff using csoTestASCII without ignoring files
        diffResults=$($toolsPath/bin/nonReg/bin/csoTestASCII $flatFicRef $flatFicRes --overwriting-path-diff $currentDir | sed "s| ||g")
    fi

    check=$(echo $diffResults | grep -i "Pasdedifferenceentrelesfichiers")    
    if  [ "$check" == "" ]; then
        diffResults="/SharedFsLai/lai/outils/OUTILS/OXYGEN/Oxygen_Editor/diffFiles.sh $ficRef $ficRes"
    fi

    if [ "$flatFicRef" != "" ]; then
        rm -f $currentDir/*_"$ficResName"_*.xml > /dev/null 2>&1
        rm -f $currentDir/*_"$ficResName"_*.xml.* > /dev/null 2>&1
        rm -f $currentDir/*_"$ficRefName"_*.xml > /dev/null 2>&1
        rm -f $currentDir/*_"$ficRefName"_*.xml.* > /dev/null 2>&1
    fi
    
else

    # fast cmp diff
    diffResults=$(cmp -s $ficRef $ficRes);
    if [ $? -ne 0 ]; then

        # getting file extension
        name=$(basename "$ficRes")
        folderName=$(dirname "$ficRes")

        # getting extension
        ext=${name##*"."}
        # uppercase

        extension=$(echo $ext | tr '[:lower:]' '[:upper:]')

        # waiting for a gdal version that handle GML and KML 
        # check=$(echo $extension | grep -E "^(G|K)ML$")
        check=""

        # in fucntion of extension
        case $extension in
            # put here the command line of the tool you want to use to compare the files
            
            #    JPEG|JP2|TIF*|BMP|PNG) 
                # print command line to diff files instead of image difference (which can be big)
            #    diffResults="$toolsPath/bin/gdal/bin/gdalinfo $ficRef;$toolsPath/bin/gdal/bin/gdalinfo $ficRes";;
            
            *) 
                # PSI, PSIH, PSD, DASO, TMI, DEC ect...
                diffResults="diff -wb $ficRef $ficRes";;
        esac

    fi
fi

# evaluate the return code

if [ "$diffResults" == "" ]; then

        # files are identical
        cr=0
else
        cr=1
fi

if [ $cr -eq 1 ]; then    
    # files differ    
    echo "$diffResults"
fi

cd $currentDir

exit $cr

