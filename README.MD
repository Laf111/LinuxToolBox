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

**Launch listTools.sh to get the list**
