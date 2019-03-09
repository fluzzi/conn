connect(){
if [ $# -eq 0 ] || ( [ $# -eq 1 ] && [[ $1 =~ ^@.*$ ]] && [[ ! $1 =~ ^.*@$ ]] && [[ ! $1 =~ ^.*@@.*$ ]]); then
	IFS='@' read -ra ADDR <<< $1
	if [ ${#ADDR[@]} -gt 3 ]; then
		invalid 7
	else
		if [ ! -z ${ADDR[2]} ];	then fold2=\"${ADDR[2]}\"; fi
		if [ ! -z ${ADDR[1]} ];	then fold1=\"${ADDR[1]}\"; fi
		getconnections=(jq -r \'\. \? \| \.$fold2 \? \| \.$fold1 \? \| paths as \$path \| select\(getpath\(\$path\) \=\= \"connection\"\) \| \$path \|  map\(select\(\. \!\= \"type\"\)\) \| join\(\"\@\"\)\' $DATADIR/connections.json)
		mapfile -t connections < <(eval ${getconnections[@]})
		if [ ${#connections[@]} -eq 0 ]; then invalid 25 $1 ; fi
		for i in ${!connections[@]}; do
		connections[$i]=$(split_by ${connections[$i]} "@" -r)
		connections[$i]="$(($i + 1)) - $(join_by "@" ${connections[$i]})"
		done
		printf '%s\n' "${connections[@]}"
	fi
	exit 1
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
			getconnections=(jq -r \'\. \? \| \.$fold2 \? \| \.$fold1 \? \| paths \| select\(\.\[-1\] \=\= \"${ADDR[0]}\"\) \| join\(\"\@\"\)\' $DATADIR/connections.json)
			mapfile -t connections < <(eval ${getconnections[@]})
			if [ ${#connections[@]} -eq 0 ]; then invalid 24 $1 ; fi
			if [ ${#connections[@]} -eq 1 ]; then
				declare args
				get_values ${connections[0]} ${ADDR[1]} ${ADDR[2]}
			else
				for i in ${!connections[@]}; do
				connections[$i]=$(split_by ${connections[$i]} "@" -r)
				connections[$i]="$(($i + 1)) - $(join_by "@" ${connections[$i]})"
				done
				printf '%s\n' "${connections[@]}"
				exit 1
			fi
		fi
		fi
	else
		invalid 5
	fi
else
	while (( $# )); do
		if [ $flag -eq 1 ]; then
			flag=0
			shift
			continue 2
		fi
	  case $1 in
		-a)   flags="$flags -a";flags="$flags $2"; flag=1 ;;
		-b)   flags="$flags -b";flags="$flags $2"; flag=1 ;;
		-c)   flags="$flags -c";flags="$flags $2"; flag=1 ;;
		-*)        invalid 8 $1;;
		*)         args+=( "$1" ); flag=0 ;;
	  esac
	  shift
	done
	set -- "${args[@]}"
	if [ ${#args[@]} -eq 1 ]
		then
		if [[ ! $1 =~ [^$validdir] ]] && [[ ! $1 =~ ^@.*$ ]] && [[ ! $1 =~ ^.*@$ ]] && [[ ! $1 =~ ^.*@@.*$ ]]; then
			IFS='@' read -ra ADDR <<< ${args[0]}
			if [ ${#ADDR[@]} -gt 3 ]; then
				invalid 7
			else
			if [ ${#ADDR[@]} -eq 1 ]; then
				echo opening connection ${ADDR[0]}  with options $flags!
			else 
			if [ ${#ADDR[@]} -eq 2 ]; then
				echo  opening connection ${ADDR[0]} of folder ${ADDR[1]}  with options $flags!
			else
				echo  opening connection ${ADDR[0]} of subfolder ${ADDR[1]} of folder ${ADDR[2]} with options $flags!
			fi
			fi
			fi
		else
			invalid 5
		fi
	else
		invalid 3
	fi
fi
fi
if [ ! -z ${args[5]} ] ; then
args[5]=`echo -n ${args[5]} | base64 --decode | openssl rsautl -inkey $DATADIR/.osk -decrypt`
fi
hostname=${args[1]};protocol=${args[2]};port=${args[3]};user=${args[4]};password=${args[5]};options=${args[6]};eval logs=${args[7]}
if [ $protocol = "ssh" ]; then
	cmd="ssh $(join_by "@" $user $hostname) $options"
	if [ ! -z $port ]; then cmd="$cmd -p $port"; fi
	if [ ! -z $password ]; then password="expect\
	\"(yes/no)\" { send \"yes\r\";exp_continue}\
	\"refused\" { exit 1}\
	\"timeout\" { puts  \"connection timeout\"; exit 1}\
	\"unavailable\" { puts \"connection timeout\"; exit 1}\
	\"closed\" { exit 1}\
	\"assword:\"; send \"$password\r\"\
	"
	fi
	if [ ! -z $logs ]; then /usr/bin/expect -c "set timeout 60; log_user 0; eval spawn $cmd; log_user 1; $password; interact" | tee >(sed -e "s,\x1B\[[?0-9;]*[a-zA-Z],,g" -e $'s/[^[:print:]\t]//g' -e "s/\]0;//g" > $logs) ;
	else /usr/bin/expect -c "log_user 0; eval spawn $cmd; log_user 1; $password; interact"; fi
fi
if [ $protocol = "telnet" ]; then
	cmd="telnet $hostname $port $options"
	if [ ! -z $password ] ; then userpass="expect\
	\"sername:\" { send \"$user\r\";exp_continue}\
	\"refused\" { exit 1}\
	\"timeout\" { puts  \"connection timeout\"; exit 1}\
	\"unavailable\" { puts \"connection timeout\"; exit 1}\
	\"closed\" { exit 1}\
	\"assword:\"; send \"$password\r\"\
	"
	fi
	if [ ! -z $user ] && [ -z $password ]; then userpass="expect\
	\"sername:\" { send \"$user\r\";exp_continue}\
	\"refused\" { exit 1}\
	\"timeout\" { puts  \"connection timeout\"; exit 1}\
	\"unavailable\" { puts \"connection timeout\"; exit 1}\
	\"closed\" { exit 1}\
	\"assword:\"; send \"$password\"\
	"
	fi
	if [ ! -z $logs ]; then /usr/bin/expect -c "set timeout 60; log_user 0; eval spawn $cmd; log_user 1; $userpass; interact" | tee >(sed -e "s,\x1B\[[?0-9;]*[a-zA-Z],,g" -e $'s/[^[:print:]\t]//g' -e "s/\]0;//g" > $logs) ;
	else /usr/bin/expect -c "log_user 0; eval spawn $cmd; log_user 1; $userpass; interact"; fi
fi
}
