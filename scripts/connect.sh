connect(){
if [ $# -eq 0 ]; then echo connect!; exit 1; fi
if [ $# -eq 1 ]; then
	if [[ ! $1 =~ [^$validdir] ]] && [[ ! $1 =~ ^.*@$ ]] && [[ ! $1 =~ ^.*@@.*$ ]]; then
		IFS='@' read -ra ADDR <<< $1
		if [ ${#ADDR[@]} -gt 3 ]; then
			invalid 7
		else
		if [ ${#ADDR[@]} -eq 1 ]; then
			echo opening connection ${ADDR[0]}!
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
}
