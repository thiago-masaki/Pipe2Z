# Pipe2Z - Usefull shell script for those who does not like mouse
# Copyright (C) 2017 Thiago Ribeiro Masaki
# 
# This file is part of Pipe2Z.
# 
# Pipe2Z is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Pipe2Z.  If not, see <http://www.gnu.org/licenses/>.

#Stack functions
function push {
	[ $# -lt 2 ] && echo "Usage: push <stack_name> <item_value>" && return
	eval "$1='$2|${!1}'"
}
function pop {
	[ $# -lt 2 ] && echo "Usage: pop <stack_name> <variable_to_receive_poped_value>" && return
	local sta=${!1}
	local ret="$(cut -d '|' -f1 <<<$sta)"
	if [ ${#ret} -ne 0 ]; then
		local len=${#sta}
		eval "$1='${sta:${#ret}+1}'"
		eval "$2='$ret'"
	else
		eval "$2=''"
	fi
}

#Save last command lines and show each line by a index number
function Pipe2Z() {
	local lastcommandresult=/tmp/.lastcommandresult 
	if [ -t 0 ]; then
		if [ "$1" == "-h" ];then
		         echo -e "Pipe2Z - Usefull shell script for those who does not like mouse\n"
		         echo -e "Usage:\n\$  <command> | Z   (Save command result)"
		         echo "\$  Z   (Show last command result with index numbers)"
		         echo "\$  Z  3 (Show the 3rd line of the last command result )"
		         echo "\$  Z  3 2 (Show the 2nd column of the 3rd line of the last command result )"
		         echo -e "\nShortcuts with examples"
		         echo -e "\$  ls <CTRL + ]>  (It will get the command you type and pipe to Z, as you typed ls | Z)"
		         echo -e "\$  cat <CTRL + />  (It will execute cat, show the last command result lines and ask you wich one you want to use as parameter for cat command)"
		elif [ "$1" != "" ];then
			 cat $lastcommandresult | tail -n $1 | head -1 |
		    if [ "$2" == "" ];then
			 cat
			 #cat /tmp/.lastcommandresult | tail -n $1 | head -1; 
		    elif [ "$2" == "l" ]; then
			 awk '{print $NF}' 
			 #cat /tmp/.lastcommandresult | tail -n $1 | head -1 | awk '{print $NF}' -
		    elif [ "$2" == "f" ]; then
			 awk '{print $1}' 
			 #cat /tmp/.lastcommandresult | tail -n $1 | head -1 | awk '{print $1}' -
		    else
			 awk -v col="$2" '{print $col}'
			 #col="$2";
			 #cat /tmp/.lastcommandresult | tail -n $1 | head -1 | awk -v col="$col" '{print $col}' -
			 #cat /tmp/.lastcommandresult | tail -n $1 | head -1 | awk -v col="$col" '{print $col}' "${@--}"
		    fi
		else	
		    totallines=$(wc -l $lastcommandresult);  
		    awk -vtotal="$totallines" '{ n=(total-NR+1); printf "(%d) %s\n",n, $0; }' $lastcommandresult
		fi
	else
		if [ "$1" != "" ];then
			#pipein=$(cat);
			#cat $pipein | tee /tmp/.lastcommandresult 
			cat | tee $lastcommandresult 
		else
			cat $* > $lastcommandresult 
		    	totallines=$(wc -l $lastcommandresult);
			awk -vtotal="$totallines" '{ n=(total-NR+1); printf "(%d) %s\n",n, $0; }' $lastcommandresult
		fi
	fi
}

alias Z="Pipe2Z";
bind  '"":"\C-u Z; read x < $(tty); \ \C-y $(Z $x) \"'
bind  '"":"\C-u \C-y | Z \"'

