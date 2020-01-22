adm(){
  if [ $1 = "add" ]; then
	  connection=$2
	  folder=$3
	  subfolder=$4
	  if [ ! -z $folder ]
		then fold=\"$folder\" 
		mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
		if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  fi
	  if [ ! -z $subfolder ]
		then subf=\"$subfolder\" 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
	    mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
	  fi
	  getconnections=(jq -r \'\. \| \.$fold \| \.$subf \| keys\[\]\' $DATADIR/connections.json)
	  mapfile -t connections < <(eval ${getconnections[@]})
	  if [ ! -z $(isinarray $connection ${connections[@]}) ]; then invalid 20 $(join_by @ $connection $subfolder $folder); fi
	  echo Adding connection $(join_by @ $connection $subfolder $folder)
	  echo
	  echo you can use the configured setting in a profile using @profilename
	  inputregex Hostname/IP '(^.+$)'
	  host=$valueregex
	  echo
	  echo do you want to set a protocol for this connection? if empty it will use the default profile setting
	  echo options: ssh,telnet
	  echo you can use the configured setting in a profile using @profilename
	  inputregex Protocol '(^ssh$|^telnet$|^$|^@.+$)'
	  protocol=$valueregex
	  echo
	  if [ -z $protocol ]; then
		  echo do you want to set a port for this connection? if empty it will use the default profile setting
		  echo options: 1-65535
		  echo you can use the configured setting in a profile using @profilename
		  inputrange Port 1 65535
		  port=$valuerange
	  else
		echo do you want to set a port for this connection? if $protocol default just leave empty
		  echo options: 1-65535
		  echo you can use the configured setting in a profile using @profilename
		  inputrange Port 1 65535
		  port=$valuerange
		  if [ $protocol = "ssh" ] && [ -z "$port" ]; then port=22; fi
		  if [ $protocol = "telnet" ] && [ -z "$port" ]; then port=23; fi
	  fi
	  echo
	  echo do you want to set a user for this connection? if not, please leave empty
	  echo you can use the configured setting in a profile using @profilename
	  inputregex User '.*'
	  user=$valueregex
	  echo
	  echo do you want to set a password for this connection? if not, please leave empty
	  echo you can use the configured setting in a profile using @profilename
	  echo if your password start with @, you can duplicate the @ to escape profile names. 
	  echo Example: @@password will work as @password and not a profile name
	  echo if you need to pass multiple passwords \(ex. using jumphost\) you can use profiles:
	  echo Example: \@profile1\|\@profile1\|\@profile2
	  while true; do
	      echo -n Password:
		  read -s password
		  IFS='|' read -ra that <<< $password
		  for ti in "${!that[@]}"; do that[$ti]="${that[$ti]:1}"; done
		  if [[ $password =~ (^@.+$) ]] && [[ ! $password =~ (^@@.+$) ]] && [ -z $(isinarray -m ${#that[@]} ${that[@]} ${allprofiles[@]}) ]; then echo; echo profile \"$(join_by "|" ${that[@]})\" not found, please try again; echo;
		  elif [ ! -z $password ] && ( [[ ! $password =~ (^@.+$) ]] || [[ $password =~ (^@@.+$) ]] ); then
			if [[ $password =~ (^@@.+$) ]]; then password=${password:1}; fi
			password=`echo $password | openssl rsautl -inkey $DATADIR/.osk -encrypt -out >(base64 -w 0)`;break; else break; echo; fi
	  done
	  echo 
	  echo
	  echo do you want to set other options for this connection? if not, please leave empty
	  echo you can pass extra ssh or telnet options to the session like -X, -L or combined options
	  echo you can use the configured setting in a profile using @profilename
	  inputregex Options '.*'
	  options=$valueregex
	  echo
	  echo do you want to save the session logs for this connection? if not, please leave empty
	  echo set the location and file name, you can use Date command to add timestamp
	  echo 'you can also use the following variables ${hostname}, ${id}, ${port} and ${user}'
	  echo example: '/home/user/logs/${hostname}_$(date '"'"'+%Y-%M-%d_%T'"'"').log'
	  echo you can use the configured setting in a profile using @profilename
	  inputregex Logging '.*'
	  logs=$valueregex
	  case $# in
		2)
		jq -r ". | . + {\"$connection\":{\"type\":\"connection\", \"host\":\"$host\", \"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
		3)
		sub="$(jq -c .\"$folder\" $DATADIR/connections.json)"
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub,\"$connection\":{\"type\":\"connection\", \"host\":\"$host\", \"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
		4)
		sub1="$(jq -c .\"$folder\".\"$subfolder\" $DATADIR/connections.json)"
		sub1=${sub1:1:-1}
		sub=(jq -c \'.\"$folder\" \| \. \+ \{\"$subfolder\"\:\{$sub1\, \"$connection\"\:\{\"type\"\:\"connection\"\, \"host\"\:\"$host\"\, \"protocol\"\:\"$protocol\"\, \"port\"\:\"$port\"\, \"user\"\:\"$user\"\, \"password\"\:\"$password\"\, \"options\"\:\"$options\"\, \"logs\"\:\"$logs\"\}\}\}\'  $DATADIR/connections.json)
		sub=$(eval ${sub[@]})
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
	  esac
	  echo
	  echo Connection \"$(join_by @ $connection $subfolder $folder)\" added correctly
  exit 0; fi
  if [ $1 = "del" ]; then
	  connection=$2
	  folder=$3
	  subfolder=$4
	  if [ ! -z $folder ]
		then fold=\"$folder\" 
		mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
		if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  fi
	  if [ ! -z $subfolder ]
		then subf=\"$subfolder\" 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
	    mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
	  fi
	  getconnections=(jq -r \'\. \| \.$fold \| \.$subf \| \. as \$object\ \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"connection\"\)\?\' $DATADIR/connections.json)
	  mapfile -t connections < <(eval ${getconnections[@]})
	  if [ -z $(isinarray $connection ${connections[@]}) ]; then invalid 24 $(join_by @ $connection $subfolder $folder); fi
		jq -r "del( . | .$fold | .$subf | .\"$connection\")" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  echo Connection \"$(join_by @ $connection $subfolder $folder)\" deleted
  exit 0; fi
  if [ $1 = "mod" ]; then 
	  connection=$2
	  folder=$3
	  subfolder=$4
	  if [ ! -z $folder ]
		then fold=\"$folder\" 
		mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
		if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  fi
	  if [ ! -z $subfolder ]
		then subf=\"$subfolder\" 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
	    mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
	  fi
	  getconnections=(jq -r \'\. \| \.$fold \| \.$subf \| \. as \$object\ \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"connection\"\)\?\' $DATADIR/connections.json)
	  mapfile -t connections < <(eval ${getconnections[@]})
	  if [ -z $(isinarray $connection ${connections[@]}) ]; then invalid 24 $(join_by @ $connection $subfolder $folder); fi
	  getoldvalues=(jq -r \'\. \| \.$fold \| \.$subf \| \.\"$connection\"\[\]\' $DATADIR/connections.json)
	  mapfile -t oldvalues < <(eval ${getoldvalues[@]})
	  echo editing connection $(join_by @ $connection $subfolder $folder)
	  echo
	  if [ ! -z $(modify Hostname) ]; then
		  echo
		  echo current hostname: ${oldvalues[1]}
	      echo you can use the configured setting in a profile using @profilename
		  inputregex Hostname/IP '(^.+$)'
		  host=$valueregex
	  else
	      host=${oldvalues[1]}
	  fi
	  echo
	  if [ ! -z $(modify Protocol) ]; then
		  echo
		  echo do you want to set a protocol for this connection? if empty it will use the default profile setting
		  echo options: ssh,telnet
		  echo you can use the configured setting in a profile using @profilename
		  echo current protocol: ${oldvalues[2]}
		  inputregex Protocol '(^ssh$|^telnet$|^$|^@.+$)'
		  protocol=$valueregex
	  else
	      protocol=${oldvalues[2]}
	  fi
	  echo
	  if [ ! -z $(modify Port) ]; then
		  echo
		  if [ -z $protocol ]; then
		  echo do you want to set a port for this connection? if empty it will use the default profile setting
			echo options: 1-65535
			echo you can use the configured setting in a profile using @profilename
			echo current port: ${oldvalues[3]}
			inputrange Port 1 65535
			port=$valuerange
		  else
			echo do you want to set a port for this connection? if $protocol default just leave empty
			echo you can use the configured setting in a profile using @profilename
			echo options: 1-65535
			echo current port: ${oldvalues[3]}
			inputrange Port 1 65535
			port=$valuerange
			if [ $protocol = "ssh" ] && [ -z "$port" ]; then port=22; fi
			if [ $protocol = "telnet" ] && [ -z "$port" ]; then port=23; fi
		  fi
	  else
	      port=${oldvalues[3]}
	  fi
	  echo
	  if [ ! -z $(modify User) ]; then
		  echo
		  echo do you want to set a user for this connection? if not, please leave empty
		  echo you can use the configured setting in a profile using @profilename
		  echo current user: ${oldvalues[4]}
		  inputregex User '.*'
		  user=$valueregex
	  else
	      user=${oldvalues[4]}
	  fi
	  echo
	  if [ ! -z $(modify Password) ]; then
		  echo
		  echo do you want to set a password for this connection? if not, please leave empty
		  echo you can use the configured setting in a profile using @profilename
		  echo if your password start with @, you can duplicate the @ to escape profile names.
		  echo Example: @@password will work as @password and not a profile name
		  echo if you need to pass multiple passwords \(ex. using jumphost\) you can use profiles:
		  echo Example: \@profile1\|\@profile1\|\@profile2
		  while true; do
			  echo -n Password:
			  read -s password
			  IFS='|' read -ra that <<< $password
			  for ti in "${!that[@]}"; do that[$ti]="${that[$ti]:1}"; done
			  if [[ $password =~ (^@.+$) ]] && [[ ! $password =~ (^@@.+$) ]] && [ -z $(isinarray -m ${#that[@]} ${that[@]} ${allprofiles[@]}) ]; then echo; echo profile \"$(join_by "|" ${that[@]})\" not found, please try again; echo;
			  elif [ ! -z $password ] && ( [[ ! $password =~ (^@.+$) ]] || [[ $password =~ (^@@.+$) ]] ); then
				if [[ $password =~ (^@@.+$) ]]; then password=${password:1}; fi
				password=`echo $password | openssl rsautl -inkey $DATADIR/.osk -encrypt -out >(base64 -w 0)`;break; else break; echo; fi
		  done
	  else
	      password=${oldvalues[5]}
	  fi
	  echo
	  if [ ! -z $(modify Options) ]; then
		  echo
		  echo do you want to set other options for this connection? if not, please leave empty
		  echo you can pass extra ssh or telnet options to the session like -X, -L or combined options
		  echo you can use the configured setting in a profile using @profilename
		  echo current options: ${oldvalues[6]}
		  inputregex Options '.*'
		  options=$valueregex
	  else
	      options=${oldvalues[6]}
	  fi
	  echo
	  if [ ! -z $(modify Logs) ]; then
		  echo
		  echo do you want to save the session logs for this connection? if not, please leave empty
		  echo set the location and file name, you can use Date command to add timestamp
		  echo 'you can also use the following variables ${hostname}, ${id}, ${port} and ${user}'
		  echo example: '/home/user/logs/${hostname}_$(date '"'"'+%Y-%M-%d_%T'"'"').log'
		  echo you can use the configured setting in a profile using @profilename
		  echo current options: ${oldvalues[7]}
		  inputregex Logging '.*'
		  logs=$valueregex
	  else
	      logs=${oldvalues[7]}
	  fi
	  newvalues=("${oldvalues[0]}" "$host" "$protocol" "$port" "$user" "$password" "$options" "$logs")
	  old=${oldvalues[@]}
	  new=${newvalues[@]}
	  if [ "$old" == "$new" ] ; then
		echo
		echo nothing to do here.
	  else
		  case $# in
			2)
			jq -r ". | . + {\"$connection\":{\"type\":\"connection\", \"host\":\"$host\", \"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
			;;
			3)
			sub="$(jq -c .\"$folder\" $DATADIR/connections.json)"
			sub=${sub:1:-1}
			jq -r ". | . + {\"$folder\":{$sub,\"$connection\":{\"type\":\"connection\", \"host\":\"$host\", \"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
			;;
			4)
			sub1="$(jq -c .\"$folder\".\"$subfolder\" $DATADIR/connections.json)"
			sub1=${sub1:1:-1}
			sub=(jq -c \'.\"$folder\" \| \. \+ \{\"$subfolder\"\:\{$sub1\, \"$connection\"\:\{\"type\"\:\"connection\"\, \"host\"\:\"$host\"\, \"protocol\"\:\"$protocol\"\, \"port\"\:\"$port\"\, \"user\"\:\"$user\"\, \"password\"\:\"$password\"\, \"options\"\:\"$options\"\, \"logs\"\:\"$logs\"\}\}\}\'  $DATADIR/connections.json)
			sub=$(eval ${sub[@]})
			sub=${sub:1:-1}
			jq -r ". | . + {\"$folder\":{$sub}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
			;;
		  esac
		  echo
		  echo Connection \"$(join_by @ $connection $subfolder $folder)\" edited correctly
		fi
  exit 0; fi
  if [ $1 = "ren" ]; then
	  oldconnection=$2
	  newconnection=$3
	  folder=$4
	  subfolder=$5
	  if [ ! -z $folder ]
		then fold=\"$folder\" 
		mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
		if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  fi
	  if [ ! -z $subfolder ]
		then subf=\"$subfolder\" 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
	    mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
	  fi
	  getconnections=(jq -r \'\. \| \.$fold \| \.$subf \| \. as \$object\ \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"connection\"\)\?\' $DATADIR/connections.json)
	  mapfile -t connections < <(eval ${getconnections[@]})
	  geteverything=(jq -r \'\. \| \.$fold \| \.$subf \| \. as \$object\ \| keys\[\] \' $DATADIR/connections.json)
	  mapfile -t everything < <(eval ${geteverything[@]})
	  if [ -z $(isinarray $oldconnection ${connections[@]}) ]; then invalid 24 $(join_by @ $oldconnection $subfolder $folder); fi
	  if [ ! -z $(isinarray $newconnection ${everything[@]}) ]; then invalid 20 $(join_by @ $newconnection $subfolder $folder); fi
	  case $# in
		3)
		jq -r "with_entries(if .key == \"$oldconnection\" then .key = \"$newconnection\" else . end)" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
		4)
		sub="$(jq -c ".\"$folder\" | with_entries(if .key == \"$oldconnection\" then .key = \"$newconnection\" else . end)" $DATADIR/connections.json)"
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
		5)
		sub="$(jq -c ".\"$folder\" | .\"$subfolder\" | with_entries(if .key == \"$oldconnection\" then .key = \"$newconnection\" else . end)" $DATADIR/connections.json)"
		sub1="$(jq -c ".\"$folder\" | del(.\"$subfolder\")" $DATADIR/connections.json )"
		sub=${sub:1:-1}
		sub1=${sub1:1:-1}
		jq -r ". | . + {\"$folder\":{$sub1,\"$subfolder\":{$sub}}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
	  esac
	  echo Connection \"$(join_by @ $oldconnection $subfolder $folder)\" renamed to \"$newconnection\"
  exit 0; fi
  if [ $1 = "list" ]; then 
    jq -r 'paths as $path | select(getpath($path) == "connection") | $path |  [map(select(. != "type"))[-1,-2,-3]] | map(select(. !=null)) | join("@")' $DATADIR/connections.json
    exit 0
  fi
  if [ $1 = "show" ]; then 
	connection=$2
	  folder=$3
	  subfolder=$4
	  if [ ! -z $folder ]
		then fold=\"$folder\" 
		mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
		if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  fi
	  if [ ! -z $subfolder ]
		then subf=\"$subfolder\" 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
	    mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
	  fi
	  getconnections=(jq -r \'\. \| \.$fold \| \.$subf \| \. as \$object\ \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"connection\"\)\?\' $DATADIR/connections.json)
	  mapfile -t connections < <(eval ${getconnections[@]})
	  if [ -z $(isinarray $connection ${connections[@]}) ]; then invalid 24 $(join_by @ $connection $subfolder $folder); fi
	  getvalues=(jq -r \'\. \| \.$fold \| \.$subf \| \.\"$connection\" \| del\(.type\) \' $DATADIR/connections.json)
	  eval ${getvalues[@]}
      exit 0
  fi
}
bulk(){
    folder=""
    subfolder=""
    echo Adding connections in bulk mode
	echo
    echo "list connections names using comma as separation"
    inputregex Connections "^[$validfile]+([,][$validfile]+){1,}$"
    IFS=',' read -r -a nodes <<< "$valueregex"
	echo
    nodesrep=($(printf "%s\n" "${nodes[@]}" | sort -u | tr '\n' ' '))
    [[ ${#nodes[@]} -eq ${#nodesrep[@]} ]] || invalid 30
    echo "Add the location to store the new connections"
    echo "you can use <folder> <subfolder@folder> or leave it empty"
    inputregex Location "^[$validfile]+[@]?[$validfile]+$|^$" folder  
    IFS='@' read -r -a location <<< "$valueregex"
    if [ ${#location[@]} -eq 1 ]; then
        folder=\"${location[0]}\" 
    elif [ ${#location[@]} -eq 2 ]; then
        folder=\"${location[1]}\" 
        subfolder=\"${location[0]}\" 
    fi
    echo
    echo "list connections hostname or IP using comma as separation or add a single value to use on all connections"
    inputregex Hosntames/IP "(^[A-Za-z0-9.-]+$)|((^[A-Za-z0-9.-]+)([,]([A-Za-z0-9.-]+)){$(( ${#nodes[@]} - 1 ))}$)" 
    IFS=',' read -r -a hostnames <<< "$valueregex"
	echo
    echo do you want to set a protocol for these connections? if empty it will use the default profile setting
	echo options: ssh,telnet
	echo you can use the configured setting in a profile using @profilename
    echo "list connections protocol using comma as separation or add a single value or profile to use on all connections"
    inputregex Protocol "(^ssh$|^telnet$|^$|^@[$validfile]+$)|((^ssh|^telnet)([,](ssh|telnet)){$(( ${#nodes[@]} - 1 ))}\$)"
    IFS=',' read -r -a protocols <<< "$valueregex"
	echo
    echo do you want to set a port for these connections? if empty it will use the default profile setting
	echo options: 1-65535
	echo you can use the configured setting in a profile using @profilename
    echo "list connections port using comma as separation or add a single value or profile to use on all connections"
    inputregex Ports "(^[1-9]$|^[1-9][0-9]$|^[1-9][0-9]{2}$|^[1-9][0-9]{3}$|^[1-5][0-9]{4}$|^6[0-4][0-9]{3}$|^65[0-4][0-9]{2}$|^655[0-2][0-9]$|^6553[0-5]$|^$|^@[$validfile]+$)|((^[1-9]|^[1-9][0-9]|^[1-9][0-9]{2}|^[1-9][0-9]{3}|^[1-5][0-9]{4}|^6[0-4][0-9]{3}|^65[0-4][0-9]{2}|^655[0-2][0-9]|^6553[0-5])([,]([1-9]|[1-9][0-9]|[1-9][0-9]{2}|[1-9][0-9]{3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])){$(( ${#nodes[@]} - 1 ))}\$)"
    IFS=',' read -r -a ports <<< "$valueregex"
    echo
	echo do you want to set a user for these connections? if not, please leave empty
	echo you can use the configured setting in a profile using @profilename
    echo "list users using comma as separation or add a single value or profile to use on all connections"
    inputregex User "(^[^,]+$|^$)|((^[^,]+)([,]([^,]+)){$(( ${#nodes[@]} - 1 ))}$)" 
    IFS=',' read -r -a users <<< "$valueregex"
    echo
	  echo do you want to set a password for these connections? if not, please leave empty
	  echo you can use the configured setting in a profile using @profilename
	  echo if your password start with @, you can duplicate the @ to escape profile names. 
	  echo Example: @@password will work as @password and not a profile name
	  echo if you need to pass multiple passwords \(ex. using jumphost\) you can use profiles:
	  echo Example: \@profile1\|\@profile1\|\@profile2
	  while true; do
	    echo -n Password:
	    read -s password
	    IFS='|' read -ra that <<< $password
		for ti in "${!that[@]}"; do that[$ti]="${that[$ti]:1}"; done
		if [[ $password =~ (^@.+$) ]] && [[ ! $password =~ (^@@.+$) ]] && [ -z $(isinarray -m ${#that[@]} ${that[@]} ${allprofiles[@]}) ]; then echo; echo profile \"$(join_by "|" ${that[@]})\" not found, please try again; echo;
		elif [ ! -z $password ] && ( [[ ! $password =~ (^@.+$) ]] || [[ $password =~ (^@@.+$) ]] ); then
		    if [[ $password =~ (^@@.+$) ]]; then password=${password:1}; fi
            password=`echo $password | openssl rsautl -inkey $DATADIR/.osk -encrypt -out >(base64 -w 0)`;break; else break; echo
         fi
	done
	echo 
	echo
    echo do you want to set other options for these connections? if not, please leave empty
	echo you can pass extra ssh or telnet options to the session like -X, -L or combined options
	echo you can use the configured setting in a profile using @profilename
	inputregex Options "(^[^,]+$|^$)|((^[^,]+)([,]([^,]+)){$(( ${#nodes[@]} - 1 ))}$)"
    IFS=',' read -r -a options <<< "$valueregex"
	echo
	echo do you want to save the session logs for these connections? if not, please leave empty
	echo set the location and file name, you can use Date command to add timestamp
	echo 'you can also use the following variables ${hostname}, ${id}, ${port} and ${user}'
	echo example: '/home/user/logs/${hostname}_$(date '"'"'+%Y-%M-%d_%T'"'"').log'
	echo you can use the configured setting in a profile using @profilename
	inputregex Logs "(^[^,]+$|^$)|((^[^,]+)([,]([^,]+)){$(( ${#nodes[@]} - 1 ))}$)"
    IFS=',' read -r -a logs <<< "$valueregex"
    echo
    sub1=""
    getvalues=(jq -r \'\. \| \.$folder \| \.$subfolder \' $DATADIR/connections.json)
    [[ ${#location[@]} -eq 0 ]] || sub1=$(eval ${getvalues[@]})
    sub1=${sub1:1:-1}
    ignored=0
    getconnections=(jq -r \'\. \| \.$folder \| \.$subfolder \| keys\[\]\' $DATADIR/connections.json)
    mapfile -t connections < <(eval ${getconnections[@]})
    for i in ${!nodes[@]}; do
        if [ ! -z $(isinarray ${nodes[$i]} ${connections[@]}) ]; then
            echo "Connection ${nodes[$i]} already exist. Ignoring it"
            ((ignored++))
            continue
        fi
        node=${nodes[$i]}
        [[ "${#hostnames[@]}" -eq 1 ]] && hostname="${hostnames[0]}" || hostname="${hostnames[$i]}"
        [[ "${#protocols[@]}" -eq 1 ]] && protocol="${protocols[0]}" || protocol="${protocols[$i]}"
        [[ "${#ports[@]}" -eq 1 ]] && port="${ports[0]}" || port="${ports[$i]}"
        [[ "${#users[@]}" -eq 1 ]] && user="${users[0]}" || user="${users[$i]}"
        password="${password}"
        [[ "${#options[@]}" -eq 1 ]] && option="${options[0]}" || option="${options[$i]}"
        [[ "${#logs[@]}" -eq 1 ]] && log="${logs[0]}" || log="${logs[$i]}"
        sub2="\"$node\":{\"type\":\"connection\", \"host\":\"$hostname\", \"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$option\", \"logs\":\"$log\"}"
        [[ -z $sub1 ]] && sub1="$sub2" || sub1="$sub1,$sub2"
    done
    [[ "$ignored" -eq "${#nodes[@]}" ]] && { echo Nothing to add.; exit 0; }
    case ${#location[@]} in
		0)
		jq -r ". | . + {$sub1}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
		1)
		jq -r ". | . + {$folder:{$sub1}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
		2)
		sub=(jq -c \'.$folder \| \. \+ \{$subfolder\:\{$sub1\}\}\'  $DATADIR/connections.json)
		sub=$(eval ${sub[@]})
		sub=${sub:1:-1}
		jq -r ". | . + {$folder:{$sub}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
	 esac
    echo $(( ${#nodes[@]} - $ignored )) connections added.
}
