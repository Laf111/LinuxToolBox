Here is my set of scripts i use under Linux.


#	PROMPT

![LinuxToolBox](LinuxToolBox.png)

# ALIASES

- h='history' 
- mkdir='mkdir -pv' 
- meminfo : (see env.sh) get memory informations and the first 10 most demanding processes 
- cpuinfo='lscpu'
- cpr='cpr.sh' 
- cpl='cp -rL' 
- getAllMyProc='ps -eaf | grep -v "grep" | grep '$USER 
- getAllMyChildProc='ps -eaf | grep -v "grep" | grep '$USER' | grep '$$
- getChildProc='pgrep -l -P '$$
- size='sudo du -hs' ( !!! sudo users only !!!)
- rexplorer='sudo nautilus --no-desktop --browser' ( !!! sudo users only !!!)
- clear : (see env.sh) clear console screen 

# AVAILABLE SCRIPTS

Launch listTools.sh to get the list bellow :

**checkPathContent.sh**

This script check a path'files and folders names using filters on file and regulars expressions defined in an optionnal external file given as 2nd argument.
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/checkPathContent.sh [checkedPath] [regExpFile*] 
-----------------------------------------------------------------------
WHERE :
- checkedPath  : full path to root folder to check without final '/'
- regExpFile   : full path to the file defining files patterns (optional)
 
RETURN CODE : 
cr = 0   : OK
cr =  1  : KO, files not match
cr =  2  : KO, folders not match
cr =  3  : KO, unexpected files found
cr =  4  : KO, missing files found
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
clean.sh

This script clean the given path's children folder from the following file's extension : '*.*~ *.diff.txt *.hdr'
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/clean.sh [workingDirPath]  
-----------------------------------------------------------------------
WHERE :
- workingDirPath : path of directory to be checked without final '/'
 
RETURN CODE : 
cr = 0  : OK
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
copyFilesTo.sh

This script copy all files (including liked files) present under srcDir to targetDir with creating relative path in targetDir if needed
It use cpr.sh so if file or link already exist in the targetDir, it will be rename with a suffix _n
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/copyFilesTo.sh [srcDir] [targetDir]
-----------------------------------------------------------------------
WHERE :
- srcDir     : srcDir path
- targetDir  : targetDir Path
 
RETURN CODE :
cr = 0  : OK
cr < 50 : WARNINGS
cr > 50 : ERRORS
cr > 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
cpr.sh

This script copy a file given with a relative path in a destination folder with creating (if needed) the relative path
If the file already exist (name file criteria) in the destination folder : the file is copied and renamed in the destination folder with a suffix created with the number of the same file already present.
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/cpr.sh [relativePathFile] [outputDir]
-----------------------------------------------------------------------
WHERE :
- relativePathFile : relative file path
- outputDir : full path of the destination folder
 
RETURN CODE :
   0 : no error
   1 : errors found
  99 : args error
-----------------------------------------------------------------------
=======================================================================
date_diffSec.sh

This script evaluate a differences in seconds nanoseconds (signed float) : t1 -t2
between 2 dates in the followinf format %Y-%m-%dT%H:%M:%S.%N (2006-10-01T23:59:58.102)
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/date_diffSec.sh [t1] [t2]
-----------------------------------------------------------------------
WHERE :
- t1 : first date in format %Y-%m-%dT%H:%M:%S.%N quoted with "
- t2 : second date in format %Y-%m-%dT%H:%M:%S.%N quoted with "
 
RETURN CODE : 
cr =0  : exit successfully
cr >0  : warnings happens
cr >49 : errors happens
cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
diffFile.sh

This script diff two files using csoTest* and output results to the console
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/diffFile.sh [ficRes] [ficRef] [confFile*]
-----------------------------------------------------------------------
WHERE :
- ficRes : path of file tested
- ficRef : path of reference file
- confFile is optionnal : path of a file containing patterns to exclude ASCII lines from comparison
 
RETURN CODE :
   0 : identical files
   1 : differences found
  98 : user interruption
  99 : args error
-----------------------------------------------------------------------
=======================================================================
diffFolder.sh

This script diff two directory trees
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/diffFolder.sh [testedDir] [ignoredItemsFilePath*] [refDir] [logFilePath*] [-k*] [-fncs*]
-----------------------------------------------------------------------
WHERE :
- testedDir : path of directory to be checked
- ignoredItemsFilePath is optionnal : path to the file defining files, folders, patterns line in ASCII file to ignore based on testedDir
- refDir : path of the reference directory
- logFilePath is optionnal : log file output path, output to console if not present
- -fncs is optionnal : case sensitive file name mode (insensitive by default)
- -k is optionnal : keep the results (./diffed* directory is delete by default)

IMPORTANT NOTE : respect arguments order !

RETURN CODE :
0 : folders match, no lonely files found
1 : folders match but lonely files found in tested dir
2 : folders match but lonely files found in ref dir
3 : folders match but lonely files found in both directories
4 : at least one file is different but no lonely files found
5 : folders dismatch ! (common files differents and/or lonely files found)
6 : folders dismatch at all ! no commons files found, only lonely files in the two folders
98 : user interruption
99 : args error
-----------------------------------------------------------------------
=======================================================================
exportCsvPerf.sh

This script export performances result in a cvs file
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/exportCsvPerf.sh [perfDir] [logPerfFile]
-----------------------------------------------------------------------
WHERE :
- perfDir : performance result folder
- logPerfFile : performance log file
 
RETURN CODE :
   0 : no error
   1 : errors found
  99 : args error
-----------------------------------------------------------------------
=======================================================================
findBrokenLinks.sh

This script find broken links in pathRoot and optionally delete them [-d*]
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/findBrokenLinks.sh [pathRoot] [depth*] [-d*]
-----------------------------------------------------------------------
WHERE :
- pathRoot : path of directory to be scanned
- depth : searching depth (optionnal)
- -d : delete results (optionnal)
 
RETURN CODE : 
cr = 0  : non nroken links found
cr = 1  : broken links founnd
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
findInFilesAndParseXml.sh

This script find -L a string in files or link from workingDirPath. It parse .XML and .CR file
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/findInFilesAndParseXml.sh [workingDirPath] "[fileFilter]" "[expression]" [depth]* 
-----------------------------------------------------------------------
WHERE :
- workingDirPath : path of directory to be scanned
- fileFilter     : file filter surronded by'"'
- expression     : string or regular expression surronded by'"'
- depth (optionnal) : searching depth 
 
RETURN CODE : 
cr = 0     : OK
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
findInFiles.sh

This script find -L a string in files or links from workingDirPath
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/findInFiles.sh [workingDirPath] "[fileFilter]" "[expression]" [depth]* [-xml]*
-----------------------------------------------------------------------
WHERE :
- workingDirPath : path of directory to be scanned
- fileFilter     : file filter surronded by'"'
- expression     : string or regular expression surronded by'"'
- depth (optionnal) : searching depth 
- -xml (optionnal) : parsing xml file instead of grep
 
RETURN CODE : 
cr = 0  : OK
cr = 99 : invalid arguments 
 
NOTES : 
   The string passed as arguments mustn't contain any reserved characters or they need to be escaped !
-----------------------------------------------------------------------
=======================================================================
findInXml.sh

This script find and extract a node in a xml document
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/findInXml.sh [expression] [checkedFile] 
-----------------------------------------------------------------------
WHERE :
- expression   : xpath expression or node name (so without special caracters)
- checkedFile  : path to XML document
 
NOTES : in case of using '|' in xpath expression, only the first path is handle
        it belongs to you to split your xpath expression
 
RETURN CODE : 
cr = 0   : OK
cr =  1  : ERROR : final node name exist but xpath doesn't match
cr =  2  : ERROR : final node name not found
cr =  3  : ERROR : node not found
cr = 11  : WARNING final node name exist but is empty
cr = 12  : WARNING xpath expression match nothing
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
float.sh

-----------------------------------------------------------------------
Usage:./ToolBoxLinux/SCRIPTS/float.sh [expression]
where :
- expression : expression to evaluate surrounded by "
 
Return code values :
RETURN CODE : 
  cr =0  : exit successfully
  cr >0  : warnings happens
  cr >49 : errors happens
  cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
getInfosPath.sh

This script gives information on pathRoot
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/getInfosPath.sh [pathRoot]  
-----------------------------------------------------------------------
WHERE :
- pathRoot : path of directory to be scanned
 
RETURN CODE : 
cr = 0     : OK
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
getMemPid.sh

This script give memory usage of a process taking into account all core used
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/getMemPid.sh [pid]  
-----------------------------------------------------------------------
WHERE :
- pid : pid of the process
 
RETURN CODE : 
cr = 0  : OK
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
getPerf.sh

This script get cpuload, memory and io datas of a given process id
It scan children process and log performances of executables with logPerf.sh launched 
during the parent process execution
If a patternList is given (4th arg oprionnal), it only log executable that the name match one of the given pattern
It logs procId performance to the console output with the following line format : 
Columns : delayFromStart totalCpuLoad totalMemory(Mo) memoryLoad(Ko) ioRead(Byte) ioWrite(Byte) ior_virt(Byte) iow_virt(Byte)
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/getPerf.sh [procId] [refreshStep] [outputFolder] [patternList*]
-----------------------------------------------------------------------
WHERE :
- procId : id of thee process
- refreshStep : time in seconds to scan process
- outputFolder : output directory
- patternList(optionnal) : list of pattern to filter process to log by name (given as a string surrounded by '"'
 
RETURN CODE :
   0 : results available
   1 : results unavailable
  99 : args error
-----------------------------------------------------------------------
  args =
=======================================================================
getProccessDetails.sh

This script extract information of given running process
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/getProccessDetails.sh [pid]
-----------------------------------------------------------------------
WHERE :
- pid : pid of the process
 
RETURN CODE : 
cr =0  : exit successfully
cr >0  : warnings happens
cr >49 : errors happens
cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
j2000_obtRef2str.sh

This script evaluate a date in format %Y-%m-%dT%H:%M:%S.%N from a timestamp in J2000
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/j2000_obtRef2str.sh [t] 
-----------------------------------------------------------------------
WHERE :
- t : timestamp in seconds as a float
 
RETURN CODE : 
cr =0  : exit successfully
cr >0  : warnings happens
cr >49 : errors happens
cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
j2000_str2jjfrac.sh

This script evaluate julian fractionnal date from a date in format %Y-%m-%dT%H:%M:%S.%N
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/j2000_str2jjfrac.sh [t] 
-----------------------------------------------------------------------
WHERE :
- t : date in format %Y-%m-%dT%H:%M:%S.%N quoted with "
 
RETURN CODE : 
cr =0  : exit successfully
cr >0  : warnings happens
cr >49 : errors happens
cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
j2000_str2jj.sh

This script evaluate julian date from a date in format %Y-%m-%dT%H:%M:%S.%N
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/j2000_str2jj.sh [t] 
-----------------------------------------------------------------------
WHERE :
- t : date in format %Y-%m-%dT%H:%M:%S.%N quoted with "
 
RETURN CODE : 
cr =0  : exit successfully
cr >0  : warnings happens
cr >49 : errors happens
cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
killProcessMatchingPattern.sh

This script kill processes with name matching a given pattern
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/killProcessMatchingPattern.sh [pattern] [gpid*]  [cmdPattern*] 
-----------------------------------------------------------------------
 
WHERE :
- pattern : pattern for searching on process name
- parentprocessId (optionnal) : id of a parent process
- cmdPattern (optionnal) : pattern for searching on whole command line
 
RETURN CODE :
   0 : OK
   1 : not a process of yours (no root)
  99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
killProcessTree.sh

This script kill a process tree (all of child processes and theirs child too) 
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/killProcessTree.sh [procId] 
-----------------------------------------------------------------------
 
WHERE :
- procId : id of thee process
 
RETURN CODE :
   0 : OK
   1 : not a process of yours (no root)
  99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
linkPathCreatingDirs.sh

This script create a similary tree of pathSrc in pathTarget only with links on file (recreate subfolders for folders 's link)
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/linkPathCreatingDirs.sh [pathSrc] [pathTarget] [ignoreDirs*] [-nrp*]
-----------------------------------------------------------------------
WHERE :
- pathSrc    : path of directory to be linked
- pathTarget : path of the destination directory (where create the links)
- ignoreDirs (optionnal): reg exp patern to ignore directory creation
- -nrp (optional) : non creating relatives path option (more speed) 
 
NOTES : 
 Don't forget to use replaceLink.sh or replaceLinks.sh if you want to modify a file in pathTarget !!!
 
cr = 0  : OK
cr = 1  : warnings
cr = 2  : broken links found
cr = 3  : errors
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
linkPath.sh

This script create a similary tree of pathSrc in pathTarget only with links (including folders links)
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/linkPath.sh [pathSrc] [pathTarget] [-nrp*]
-----------------------------------------------------------------------
WHERE :
- pathSrc         : path of directory to be linked
- pathTarget      : path of the destination directory (where create the links)
- -nrp (optional) : non creating relatives path option (more speed) 
 
NOTES : 
 Folders are also linked => if you modify or create file in pathTarget, you will modify pathSrc !!!
 Don't forget to use replaceLink.sh or replaceLinks.sh if you want to modify a file in pathTarget !!!
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : warnings
cr = 2  : broken links found
cr = 3  : errors
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
listSchemaXsdVersion.sh

This script extract the schema version from every xsd files in xsdDirPath
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/listSchemaXsdVersion.sh [xsdDirPath]
-----------------------------------------------------------------------
WHERE :
  - xsdDirPath   : path to the schema files directory
 
RETURN CODE : 
cr =0  : exit successfully
cr >0  : warnings happens
cr >49 : errors happens
cr >99 : error on given args
-----------------------------------------------------------------------
given args : ()
=======================================================================
logPerf.sh

This script log cpuload, memory and io datas of a given process id to the console output
with the following line format : delayFromRefDate delayFromStart cpuLoad memory(kB) ior_real(Byte) iow_real(Byte) ior_virt(Byte) iow_virt(Byte)
delayFromStart is computed in seconds and computed using system time start date of the process
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/logPerf.sh [procId] [refreshStep] [refDateStamp*]
-----------------------------------------------------------------------
WHERE :
- procId : id of thee process
- refreshStep : time in seconds to scan process
- refDateStamp (optionnal) : reference date time stamp (nb seconds since LINUX epoch 1970/01/01, return of the command : date -d date +'%s'
 
 NOTE : 
 
 '#' is used for comment lines in log.: by redirecting console output to a file, you
 can get only the data to plot with the command : more $logFile | grep -v \"#\"
 
RETURN CODE :
   0 : results available
   1 : results unavailable
  99 : args error
-----------------------------------------------------------------------
=======================================================================
lowerCaseFiles.sh

-----------------------------------------------------------------------
Usage:./ToolBoxLinux/SCRIPTS/lowerCaseFiles.sh [rootFolder] [depth*]
where :
- rootFolder : working directory full path expected for CHAIN-CSO (test directory)
- depth (optionnal) : searching depth 
 
Return code values :
RETURN CODE : 
  cr =0  : exit successfully
  cr >0  : warnings happens
  cr >49 : errors happens
  cr >99 : error on given args
-----------------------------------------------------------------------
=======================================================================
nonRegCreateTestsConfigFile.sh

This script create a non reg tests list config file from a testDir and a refDir
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/nonRegCreateTestsConfigFile.sh [testDir] [refDir] [expectedDiffFolderReturnCode]
-----------------------------------------------------------------------
WHERE :
- testDir : full path of directory to be checked
- refDir : full path of reference directory
- expectedDiffFolderReturnCode : return code value expected for successfull nonreg test
 
RETURN CODE :
   0 : OK
   1 : KO
  99 : args error
 
EXAMPLE : ./createTestsConfigFile.sh V2-2/OUTPUT V2-2/TV_OUTPUT > Sy2Dec_tests.conf
-----------------------------------------------------------------------
=======================================================================
nonReg.sh

This script launch a list of non reg tests read from a testsConfigFile.conf
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/nonReg.sh [testsConfigFile] [diffFolderConfFile*] [-k*] [-fncs*]
-----------------------------------------------------------------------
WHERE :
- testsConfigFile : path of non reg tests config file
- diffFolderConfFile is optionnal : path of diffFolder script's config file
- -fncs is optionnal : case sensitive file name mode (insensitive by default)
- -k is optionnal : keep the results (./diffed* under ./ToolBoxLinux/SCRIPTS is delete by default)
RETURN CODE :
   0 : OK all tests passed
   1 : KO at least one test failed
   2 : KO all tests failed
  97 : process error
  99 : args error
 
-----------------------------------------------------------------------
=======================================================================
renameFiles.sh

This script rename files in a folder.
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/renameFiles.sh [pathRoot] "[stringSrc]" "[stringTarget]" [depth]*
-----------------------------------------------------------------------
WHERE :
- pathRoot    : root folder
- stringSrc         : string to replace surronded by'"'
- stringTarget      : string replacement surronded by'"'
- depth (optionnal) : searching depth 
 
RETURN CODE : 
cr = 0   : OK
cr =  1  : error occurs
cr = 99 : invalid arguments 
 
-----------------------------------------------------------------------
=======================================================================
renameLinksWithTargetsNames.sh

This script rename links under pathRoot with their targets names
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/renameLinksWithTargetsNames.sh [pathRoot] [depth]*
-----------------------------------------------------------------------
WHERE :
- pathRoot          : path of directory where renaming links with their targets name
- depth (optionnal) : searching depth 
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : error when parsing pathRoot
cr = 2  : broken links found
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
renameLinkWithTargetName.sh

This script rename a link with its target name
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/renameLinkWithTargetName.sh [linkPath] 
-----------------------------------------------------------------------
WHERE :
- linkPath    : path of the link
 
RETURN CODE : 
cr = 0   : OK
cr = -99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
renameTargetsWithLinksNames.sh

This script rename targeted files by present links under pathRoot with their links names
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/renameTargetsWithLinksNames.sh [pathRoot] [depth]*
-----------------------------------------------------------------------
WHERE :
- pathRoot    : path to the directory where renaming links with their targets name
- depth (optionnal) : searching depth 
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : error when parsing pathRoot
cr = 2  : broken links found
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
renameTargetWithLinkName.sh

This script rename a target with its link name
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/renameTargetWithLinkName.sh [linkPath] 
-----------------------------------------------------------------------
WHERE :
- linkPath    : path of the link
 
RETURN CODE : 
cr = 0   : OK
cr <> 0  : KO
cr = -99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
replaceInFiles.sh

This script replace in files (without following links) from a folder using a file filter. 
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/replaceInFiles.sh [pathRoot] "[fileFilter]" "[stringSrc]" "[stringTarget]" [depth]*
-----------------------------------------------------------------------
WHERE :
- pathRoot          : root folder
- fileFilter        : file filter surronded by'"'
- stringSrc         : string to replace surronded by'"'
- stringTarget      : string replacement surronded by'"'
- depth (optionnal) : searching depth 
 
RETURN CODE : 
cr = 0   : OK
cr =  1  : error occurs
cr = 99 : invalid arguments 
 
EXAMPLE : replaceInFiles.sh $(pwd) "*.sh" "USAGE :\$0" "USAGE : \$0" 3
-----------------------------------------------------------------------
=======================================================================
replaceLink.sh

This script break a link and replace it by replacing it by its target
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/replaceLink.sh [linkPath] 
-----------------------------------------------------------------------
WHERE :
- linkPath    : path of the link
 
RETURN CODE : 
cr = 0   : OK
cr = -99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
replaceLinks.sh

This script replace links in pathRoot with their targets
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/replaceLinks.sh [pathRoot] [depth]*
-----------------------------------------------------------------------
WHERE :
- pathRoot    : path to the directory where replacing links with their targets 
- depth (optionnal) : searching depth 
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : error when parsing pathRoot
cr = 2  : broken links found
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
sortData.sh

This script sorts data in separate directories
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/sortData.sh [dirIn] [mess] [dirOut]
-----------------------------------------------------------------------
WHERE :
- dirIn   : path of input directory
- mess    : message to filter
- dirOut  : path of filtered directory 
 
RETURN CODE : 
cr = 0   : OK
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
tracePerf.sh

This script get memory and io info on a given process id
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/tracePerf.sh [procId] 
-----------------------------------------------------------------------
WHERE :
- procId : id of thee process
 
RETURN CODE :
   0 : results available
   1 : results unavailable
  99 : args error
-----------------------------------------------------------------------
=======================================================================
updateLink.sh

This script update link by replacing strOldPath with replacementPath in its targeted path
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/updateLink.sh [linkPath] [strOldPath] [replacementPath]
-----------------------------------------------------------------------
WHERE :
- linkPath        : full path of the link to be updated
- strOldPath      : string surrounded by  that contain the part of targeted paths to replace
- replacementPath : string surrounded by  that contain the replacement part of targeted paths
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : error when parsing linkPath
cr = 2  : broken links found
cr = 99 : invalid arguments 
 
-----------------------------------------------------------------------
=======================================================================
updateLinks.sh

This script update links under pathRoot by replacing strOldPath with replacementPath in its targeted path
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/updateLinks.sh [pathRoot] [strOldPath] [replacementPath] [depth*]
-----------------------------------------------------------------------
WHERE :
- pathRoot          : path of directory to be linked
- strOldPath        :  string surrounded by  that contain the part of targeted paths to replace
- replacementPath   :  string surrounded by  that contain the replacement part of targeted paths
- depth (optionnal) : searching depth
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : error when parsing pathRoot
cr = 2  : broken links found
cr = 99 : invalid arguments 
 
NOTES : 
   Strings passed as arguments mustn't contain any reserved characters or they need to be escaped !
-----------------------------------------------------------------------
=======================================================================
updateLinksWithFinalTargetPath.sh

This script update links under  by replacing immediate link path with final target Path.
It has no effect on symbolic links that have only one level of link.
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/updateLinksWithFinalTargetPath.sh [workingDir] [depth*]
-----------------------------------------------------------------------
WHERE :
- workingDir           : path of directory containing links to update
- depth (optionnal)    : searching depth
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : warnings
cr = 2  : broken links found
cr > 50 : errors
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
updateLinksWithRelativePath.sh

This script update links under workingDir by replacing full targeted path by a relative one
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/updateLinksWithRelativePath.sh [workingDir] [depth*]
-----------------------------------------------------------------------
WHERE :
- workingDir           : path of directory containing links to update
- depth (optionnal)    : searching depth
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : warnings
cr = 2  : broken links found
cr = 3  : errors
cr = 99 : invalid arguments 
-----------------------------------------------------------------------
=======================================================================
updatePath.sh

This script update targetDir by copying sourceDir files and links only if they are not present or different in the targetDir.
By using the optionnal parameter 'createdAfterFile', you can specify a file or directory to copy only files (or links) newer than the file specified 
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/updatePath.sh [sourceDir] [targetDir] [createdAfterFile]* [depth]*
-----------------------------------------------------------------------
WHERE :
- sourceDir                     : path to the source folder (to copy)
- targetDir                     : path to the target folder (to update)
- createdAfterFile  (optionnal) : refrence file, link or folder to copy only the newer elements
- depth (optionnal)             : searching depth
 
RETURN CODE : 
cr = 0   : OK
cr =  1  : error occurs
cr = 99 : invalid arguments 
 
NOTES : 
   Don't forget to sudo this script if needed !!! 
-----------------------------------------------------------------------
=======================================================================
updateSchemaVersionInXml.sh

This script update the value of the XPATH = /*/HEADER/INTERFACE_SPECIFICATION/SCHEMA_VERSION in all .xml files under pathRoot
-----------------------------------------------------------------------
USAGE : ./ToolBoxLinux/SCRIPTS/updateSchemaVersionInXml.sh [pathRoot] [*depth]
-----------------------------------------------------------------------
WHERE :
- pathRoot : path of directory containing xml or XML files to update
- depth (optionnal) : searching depth
 
NOTES :
Only files defining a valid XSD file in their XML header are updated !
 
RETURN CODE : 
cr = 0  : OK
cr = 1  : WARNING at least one file is not associate to an xsd
cr = 2  : WARNING at least one file is invalid regarding its xsd
cr > 50  : ERROR
cr > 100 : invalid arguments

-----------------------------------------------------------------------
=======================================================================
upperCaseFiles.sh

-----------------------------------------------------------------------
Usage:./ToolBoxLinux/SCRIPTS/upperCaseFiles.sh [rootFolder] [depth*]
where :
- rootFolder : working directory full path expected for CHAIN-CSO (test directory)
- depth (optionnal) : searching depth 
 
Return code values :
RETURN CODE : 
  cr =0  : exit successfully
  cr >0  : warnings happens
  cr >49 : errors happens
  cr >99 : error on given args
-----------------------------------------------------------------------
