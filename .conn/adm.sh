adm(){
  if [ $1 = "add" ]; then
  
	  connection=$2
	  folder=$3
	  subfolder=$4
	  if [ ! -z $folder ]
		then fold=\"$folder\" 
		mapfile -t folders < <(jq -r 'keys[]' $DATADIR/connections.json)
		if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  fi
	  if [ ! -z $subfolder ]
		then subf=\"$subfolder\" 
		getsubfolders=(jq -r \'\.\? \| \.\"$folder\"\? \| keys\[\]\' $DATADIR/connections.json)
	    mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
	  fi
	  getconnections=(jq -r \'\.\? \| \.$fold\? \| \.$subf\? \| keys\[\]\' $DATADIR/connections.json)
	  mapfile -t connections < <(eval ${getconnections[@]})
	  if [ ! -z $(isinarray $connection ${connections[@]}) ]; then invalid 20 $(join_by @ $connection $subfolder $folder); fi
	  echo Adding connection $(join_by @ $connection $subfolder $folder)
	  echo
	  inputregex Hostname/IP '(^.+$)'
	  host=$valueregex
	  echo $host
	  echo

	  echo do you want to set a protocol for this profile? if empty it will use the default profile setting
	  echo options: ssh,telnet
	  echo you can use the configured setting in a profile using @profilename
	  inputregex Protocol '(^ssh$|^telnet$|^$|^@.+$)'
	  protocol=$valueregex
	  echo
	  if [ -z $protocol ]; then
		  echo do you want to set a port for this profile? if empty it will use the default profile setting
		  echo options: 1-65535
		  echo you can use the configured setting in a profile using @profilename
		  inputrange Port 1 65535
		  port=$valuerange
	  else
		echo do you want to set a port for this profile? if $protocol default just leave empty
		  echo options: 1-65535
		  inputrange Port 1 65535
		  echo you can use the configured setting in a profile using @profilename
		  port=$valuerange
		  if [ $protocol = "ssh" ] && [ -z "$port" ]; then port=22; fi
		  if [ $protocol = "telnet" ] && [ -z "$port" ]; then port=23; fi
	  fi
	  echo
	  echo do you want to set a user for this profile? if not, please leave empty
	  echo you can use the configured setting in a profile using @profilename
	  inputregex User '.*'
	  user=$valueregex
	  echo
	  echo do you want to set a password for this profile? if not, please leave empty
	  echo you can use the configured setting in a profile using @profilename
	  echo if your password start with @, you can duplicate the @ to escape profile names. 
	  echo Example: @@password will work as @password and not a profile name
	  echo -n Password:
	  read -s password
	  if [ ! -z $password ] && ( [[ ! $password =~ (^@.+$) ]] || [[ $password =~ (^@@.+$) ]] ); then
	  if [[ $password =~ (^@@.+$) ]]; then password=${password:1}; fi
	  password=`echo $password | openssl rsautl -inkey $DATADIR/.osk -encrypt -out >(base64 -w 0)`; fi
	  echo 
	  echo
	  echo do you want to set other options for this profile? if not, please leave empty
	  echo you can pass extra ssh or telnet options to the session like -X, -L or combined options
	  echo you can use the configured setting in a profile using @profilename
	  inputregex Options '.*'
	  options=$valueregex
	  echo
	  echo do you want to save the session logs for this profile? if not, please leave empty
	  echo set the location and file name, you can use Date command to add timestamp
	  echo 'you can also use the following variables $hostname, $port and $user'
	  echo example: '/home/user/logs/$hostname_$(date '"'"'+%Y-%M-%d_%T'"'"').log'
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
		jq -r ". | . + {\"$folder\":{$sub,\"$connection\":{\"type\":\"connection\", \"host\":\"$host\", \"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
		;;
	  esac
	  echo
	  echo Connection \"$(join_by @ $connection $subfolder $folder)\" added correctly
  
  exit 1; fi
  if [ $1 = "del" ]; then echo deleting $2!; 
  
  exit 1; fi
  if [ $1 = "mod" ]; then echo modifying $2!; 
  
  exit 1; fi
}
