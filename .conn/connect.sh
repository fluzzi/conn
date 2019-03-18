connect(){
if [ $# -eq 0 ] || ( [ $# -eq 1 ] && [[ $1 =~ ^@.*$ ]] && [[ ! $1 =~ ^.*@$ ]] && [[ ! $1 =~ ^.*@@.*$ ]]); then
	IFS='@' read -ra ADDR <<< $1
	if [ ${#ADDR[@]} -gt 3 ]; then
		invalid 7
	else
		if [ ! -z ${ADDR[2]} ];	then fold2=\"${ADDR[2]}\"; fi
		if [ ! -z ${ADDR[1]} ];	then fold1=\"${ADDR[1]}\"; fi
		getconnections=(jq -r \'\.  \| \.$fold2  \| \.$fold1  \| paths as \$path \| select\(getpath\(\$path\) \=\= \"connection\"\) \| \$path \|  map\(select\(\. \!\= \"type\"\)\) \| join\(\"\@\"\)\' $DATADIR/connections.json)
		mapfile -t connections < <(eval ${getconnections[@]})
		if [ ${#connections[@]} -eq 0 ] && [ $# -eq 0 ] ; then invalid 26 ; fi
		if [ ${#connections[@]} -eq 0 ]; then invalid 25 $1 ; fi
		for i in ${!connections[@]}; do
		con=$(split_by ${connections[$i]} "@" -r)
		con="$(join_by "@" $con)"
		echo "$(($i + 1)) - $con"
		done
		inputrange Connection 1 $((i + 1))
		if [[ ! $valuerange =~ (^[0-9]+$) ]] ; then
			exit 1
		else 
			connections=(${connections[$(($valuerange -1))]})
			declare args
			get_values ${connections[0]} ${ADDR[1]} ${ADDR[2]}
		fi
	fi
else
if [ $# -eq 1 ]; then
	if [[ ! $1 =~ [^$validdir] ]] && [[ ! $1 =~ ^.*@$ ]] && [[ ! $1 =~ ^.*@@.*$ ]]; then
		IFS='@' read -ra ADDR <<< $1
		if [ ${#ADDR[@]} -gt 3 ]; then
			invalid 7
		else
		if [ ${#ADDR[@]} -le 3 ]; then
			if [ ! -z ${ADDR[2]} ];	then fold2=\"${ADDR[2]}\"; fi
			if [ ! -z ${ADDR[1]} ];	then fold1=\"${ADDR[1]}\"; fi
			getconnections=(jq -r \'\. \| \.$fold2 \| \.$fold1 \| paths as \$path \| select\(getpath\(\$path\) \=\= \"connection\"\) \| \$path \| select\(\.\[-2\] \=\= \"${ADDR[0]}\"\) \| \$path \|  map\(select\(\. \!\= \"type\"\)\) \| join\(\"\@\"\)\' $DATADIR/connections.json)
			mapfile -t connections < <(eval ${getconnections[@]})
			if [ ${#connections[@]} -eq 0 ]; then invalid 24 $1 ; fi
			if [ ${#connections[@]} -eq 1 ]; then
				declare args
				get_values ${connections[0]} ${ADDR[1]} ${ADDR[2]}
			else 
				for i in ${!connections[@]}; do
				con=$(split_by ${connections[$i]} "@" -r)
				con="$(join_by "@" ${connections[$i]})"
				echo "$(($i + 1)) - $con"
				done
				inputrange Connection 1 $((i + 1))
				if [[ ! $valuerange =~ (^[0-9]+$) ]] ; then
					exit 1
				else 
					connections=(${connections[$(($valuerange -1))]})
					declare args
					get_values ${connections[0]} ${ADDR[1]} ${ADDR[2]}
				fi
			fi
		fi
		fi
	else
		invalid 5
	fi
else       # Reset in case getopts has been used previously in the shell.
	declare -A flags
	vals=()
	while [ $# -gt 0 ]; do
		OPTIND=1
		tot=$OPTIND
		while getopts l:p:P:o:s opt; do
		  case "$opt" in
		   l) flags[user]="$OPTARG";;
		   p) flags[port]="$OPTARG";;
		   P) flags[protocol]="$OPTARG";;
		   o) flags[options]="$OPTARG";;
		   s) flags[password]="null";;
		   *) exit 1
		  esac
		done
		if [ $tot -eq $OPTIND ]; then vals+=("$1"); shift; else shift $((OPTIND-1)); fi
	done
	if [ ${#vals[@]} -eq 1 ]
		then
		if [[ ! ${vals[@]} =~ [^$validdir] ]] && [[ ! ${vals[@]} =~ ^@.*$ ]] && [[ ! ${vals[@]} =~ ^.*@$ ]] && [[ ! ${vals[@]} =~ ^.*@@.*$ ]]; then
			IFS='@' read -ra ADDR <<< ${vals[@]}
			if [ ${#ADDR[@]} -gt 3 ]; then
				invalid 7
			else
			if [ ${#ADDR[@]} -le 3 ]; then
				if [ ! -z ${ADDR[2]} ];	then fold2=\"${ADDR[2]}\"; fi
				if [ ! -z ${ADDR[1]} ];	then fold1=\"${ADDR[1]}\"; fi
				getconnections=(jq -r \'\. \| \.$fold2 \| \.$fold1 \| paths \| select\(\.\[-1\] \=\= \"${ADDR[0]}\"\) \| join\(\"\@\"\)\' $DATADIR/connections.json)
				mapfile -t connections < <(eval ${getconnections[@]})
				if [ ${#connections[@]} -eq 0 ]; then invalid 24 ${vals[@]} ; fi
				if [ ${#connections[@]} -eq 1 ]; then
					declare args
					get_values ${connections[0]} ${ADDR[1]} ${ADDR[2]}
				else 
					for i in ${!connections[@]}; do
					con=$(split_by ${connections[$i]} "@" -r)
					con="$(join_by "@" ${connections[$i]})"
					echo "$(($i + 1)) - $con"
					done
					inputrange Connection 1 $((i + 1))
					if [[ ! $valuerange =~ (^[0-9]+$) ]] ; then
						exit 1
					else 
						connections=(${connections[$(($valuerange -1))]})
						declare args
						get_values ${connections[0]} ${ADDR[1]} ${ADDR[2]}
					fi
				fi
			fi
			fi
		else
			invalid 5
		fi
		if [ ! -z "${flags[protocol]}" ]; then args[2]="${flags[protocol]}"; fi
		if [ ! -z "${flags[port]}" ]; then args[3]="${flags[port]}"; fi
		if [ ! -z "${flags[user]}" ]; then args[4]="${flags[user]}"; fi
		if [ ! -z "${flags[options]}" ]; then args[6]="${flags[options]}"; fi
		if [ ! -z "${flags[password]}" ] || [ ! -z "${flags[user]}" ]; then args[5]=""; fi
	else
		invalid 3
	fi
fi
fi
if [ ! -z ${args[5]} ] ; then
IFS='|' read -ra that <<< "${args[5]}"
	for t in ${that[@]}; do
	password+=(`echo -n $t| base64 --decode | openssl rsautl -inkey $DATADIR/.osk -decrypt`)
	done
else
	password=(${args[5]})
fi
hostname=${args[1]};protocol=${args[2]};port=${args[3]};user=${args[4]};options=${args[6]};eval logs=${args[7]}
if [ $protocol = "ssh" ]; then
	cmd="ssh $(join_by "@" $user $hostname) $options"
	if [ ! -z $port ]; then cmd="$cmd -p $port"; fi
	if [ ! -z "${password[0]}" ]; then wordpass="expect\
	\"(yes/no)\" { send \"yes\r\";exp_continue}\
	$wordpass \"assword:\"; send \"${password[0]}\r\"\
	"
	p=1
	while [ $p -lt "${#password[@]}" ] ; do
	wordpass="$wordpass ; expect \"assword:\"; send \"${password[$p]}\r\""
	((p++))
	done
	fi
	if [ ! -z $logs ]; then /usr/bin/expect -c "set timeout 60; log_user 0; eval spawn $cmd; log_user 1; $wordpass; interact" 2> /dev/null | tee >(sed -e "s,\x1B\[[?0-9;]*[a-zA-Z],,g" -e $'s/[^[:print:]\t]//g' -e "s/\]0;//g" > $logs);
	else /usr/bin/expect -c "set timeout 60; log_user 0; eval spawn $cmd; log_user 1; $wordpass; interact"  2> /dev/null; fi
elif [ $protocol = "telnet" ]; then
	cmd="telnet $hostname $port $options"
	if [ ! -z ${password[0]} ] ; then userpass="expect\
	\"sername:\" { send \"$user\r\";exp_continue}\
	\"assword:\"; send \"${password[0]}\r\"\
	"
	fi
	if [ ! -z $user ] && [ -z ${password[0]} ]; then userpass="expect\
	\"sername:\" { send \"$user\r\";exp_continue}\
	\"assword:\"; send \"${password[0]}\"\
	"
	fi
	if [ ! -z $logs ]; then /usr/bin/expect -c "set timeout 60; log_user 0; eval spawn $cmd; log_user 1; $userpass; interact"  2> /dev/null | tee >(sed -e "s,\x1B\[[?0-9;]*[a-zA-Z],,g" -e $'s/[^[:print:]\t]//g' -e "s/\]0;//g" > $logs) ;
	else /usr/bin/expect -c "set timeout 60; log_user 0; eval spawn $cmd; log_user 1; $userpass; interact"  2> /dev/null ; fi
else 
invalid 9 $protocol
fi

}
