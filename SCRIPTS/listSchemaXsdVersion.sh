#!/bin/bash
##
## INSTRUCTIONS
##
## This script extract the schema version from every xsd files in xsdDirPath
##
## USAGE : $0  [$xsdDirPath]
##
## $xsdDirPath : path to the schema files directory
##
## return code values :
##
##    0  : exit successfully
##   >0  : warnings happens
##   >49 : errors happens
##   >99 : error on given args
##
## Notes : 
##
################################################################################
## HISTORIQUE :
## 22/03/2016 CGR : creation du fichier
## FIN-HISTORIQUE
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# LOCAL FUNCTIONS
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#///////////////////////////////////////////////////////////////////////////////
# Display how to use this script
function Syntaxe
{
    echo "This script extract the schema version from every xsd files in xsdDirPath"
    echo "-----------------------------------------------------------------------"
    echo "USAGE : $0 [xsdDirPath]"
    echo "-----------------------------------------------------------------------"
    echo "WHERE :"
    echo "  - xsdDirPath   : path to the schema files directory"
    echo " "
    echo "RETURN CODE : "
    echo "   cr =0  : exit successfully"
    echo "   cr >0  : warnings happens"
    echo "   cr >49 : errors happens"
    echo "   cr >99 : error on given args"
    echo "-----------------------------------------------------------------------"
    echo "given args : ("$*")"
}

#///////////////////////////////////////////////////////////////////////////////
# Checking args
function CheckArgs
{
    if [ $# -ne 1 ]
    then
        Syntaxe
        exit 100
    else
        xsdDirPath="$1"
        # check that file (or link) exist
        if [ ! -d $xsdDirPath -a ! -L $xsdDirPath ]; then
            echo "ERROR : ("$(basename $0)"), invalid xsdDirPath file path : "$xsdDirPath
            exit 101
        fi
    fi
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# MAIN PROGRAM
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cr=0

# Checking args
CheckArgs $*


xsdFiles=$(find -L $xsdDirPath -iname "*.xsd" | sort)


for f in $xsdFiles; do

    #getXsdName
    name=$(basename $f)

    # get xsd file version (more easier with shell)
                tmp=$(more "$f" | grep "xs:schema" | grep "version=")
                tmp2=${tmp##*"version="}
                versionXsd=$(echo ${tmp2%%>*} | sed s/"\""/""/g)
                
                if [ "$versionXsd" == "" ]; then
                    echo "WARNING : no version found in xsd file "$f
                    cr=3
                fi
    echo $name $versionXsd

done
exit $cr




