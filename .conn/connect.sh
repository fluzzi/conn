connect(){
if [ $# -eq 0 ]; then echo connect!
else
if [ $# -eq 1 ]; then
	if [[ ! $1 =~ [^$validdir] ]] && [[ ! $1 =~ ^.*@$ ]] && [[ ! $1 =~ ^.*@@.*$ ]]; then
		IFS='@' read -ra ADDR <<< $1
		if [ ${#ADDR[@]} -gt 3 ]; then
			invalid 7
		else
		if [ ${#ADDR[@]} -eq 1 ]; then
			getconnections=(jq -r \'paths \| select\(\.\[-1\] \=\= \"${ADDR[0]}\"\) \| join\(\"\@\"\)\' $DATADIR/connections.json)
			mapfile -t connections < <(eval ${getconnections[@]})
			if [ ${#connections[@]} -eq 0 ]; then invalid 24 ${ADDR[0]} ; fi
			if [ ${#connections[@]} -eq 1 ]; then
				path=$(split_by ${connections[@]} "@")
				path=(jq -r \'.\"$(join_by -m "\".\"" $path)\"[]\' $DATADIR/connections.json)
				mapfile -t args < <(eval eval ${path[@]})
				for i in "${!args[@]}"; do
					if [ -z ${args[$i]} ] && [ $i -ge 2 ] && [ $i -le 3 ]; then
						this=(jq -r \'.\"default\".${arguments[$i]}\' $DATADIR/profiles.json)
						mapfile -t this < <(eval eval ${this[@]})
						args[$i]=${this[@]}
					fi
					if [[ ${args[$i]} =~ ^@.*$ ]]; then
						this=${args[$i]#?}
						this=(jq -r \'.\"$this\".${arguments[$i]}\' $DATADIR/profiles.json)
						mapfile -t this < <(eval eval ${this[@]})
						args[$i]=${this[@]}
					fi
				done
			else
			echo hay 2!
			fi
		else 
		if [ ${#ADDR[@]} -eq 2 ]; then
			if [[ $1 =~ ^@.*$ ]]; then
				echo opening connections of folder ${ADDR[1]}!
			else
				echo  opening connection ${ADDR[0]} of folder ${ADDR[1]}!
			fi
		else
			if [[ $1 =~ ^@.*$ ]]; then
				echo opening connections of subfolder ${ADDR[1]} of folder ${ADDR[2]}!
			else
				echo  opening connection ${ADDR[0]} of subfolder ${ADDR[1]} of folder ${ADDR[2]}!
			fi
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
	if [ ! -z $password ]; then password="expect \"(yes/no)\" { send \"yes\r\";exp_continue} \"assword:\"; send \"$password\r\""; fi
	if [ ! -z logs ]; then /usr/bin/expect -c "log_user 0; eval spawn $cmd; send \"\r\"; $password; interact" | tee >(sed -e "s,\x1B\[[?0-9;]*[a-zA-Z],,g" -e $'s/[^[:print:]\t]//g' -e "s/\]0;//g" > $logs) ;
	else /usr/bin/expect -c "log_user 0; eval spawn $cmd; send \"\r\"; $password; interact"; fi
fi
}
