profile(){
  if [ $1 = "add" ]; then
	  profile=$2
	  mapfile -t profiles < <(jq -r 'keys[]' $DATADIR/profiles.json)
	  if [ ! -z $(isinarray $profile ${profiles[@]}) ]; then invalid 10 $profile; fi
	  echo Adding profile $profile
	  echo
	  echo do you want to set a protocol for this profile? if not, please leave empty
	  echo options: ssh,telnet
	  inputregex Protocol '(^ssh$|^telnet$|^$)'
	  protocol=$valueregex
	  echo
	  if [ -z $protocol ]; then
		  echo do you want to set a port for this profile? if not, please leave empty
		  echo options: 1-65535
		  inputrange Port 1 65535
		  port=$valuerange
	  else
		echo do you want to set a port for this profile? if $protocol default just leave empty
		  echo options: 1-65535
		  inputrange Port 1 65535
		  port=$valuerange
		  if [ $protocol = "ssh" ] && [ -z "$port" ]; then port=22; fi
		  if [ $protocol = "telnet" ] && [ -z "$port" ]; then port=23; fi
	  fi
	  echo
	  echo do you want to set a user for this profile? if not, please leave empty
	  inputregex User '.*'
	  user=$valueregex
	  echo
	  echo do you want to set a password for this profile? if not, please leave empty
	  echo -n Password:
	  read -s password
	  if [ ! -z $password ]; then password=`echo $password | openssl rsautl -inkey $DATADIR/.osk -encrypt -out >(base64 -w 0)`; fi
	  echo 
	  echo
	  echo do you want to set other options for this profile? if not, please leave empty
	  echo you can pass extra ssh or telnet options to the session like -X, -L or combined options
	  inputregex Options '.*'
	  options=$valueregex
	  echo
	  echo do you want to save the session logs for this profile? if not, please leave empty
	  echo set the location and file name, you can use Date command to add timestamp
	  echo 'you can also use the following variables ${hostname}, ${port} and ${user}'
	  echo example: '/home/user/logs/$hostname_$(date '"'"'+%Y-%M-%d_%T'"'"').log'
	  inputregex Logging '.*'
	  logs=$valueregex
	  jq -r ". | . + {\"$profile\":{\"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}" $DATADIR/profiles.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/profiles.json; chmod  600 $DATADIR/profiles.json
	  echo
	  echo Profile \"$profile\" created correctly
  exit 1; fi
  if [ $1 = "del" ]; then
	  profile=$2
	  mapfile -t profiles < <(jq -r 'keys[]' $DATADIR/profiles.json)
	  if [ -z $(isinarray $profile ${profiles[@]}) ]; then invalid 11 $profile; fi
	  if [ $profile == "default" ]; then invalid 12 $profile; fi
	  mapfile -t profileused < <(jq -r ".[] | select(.. == \"@$profile\")[]" $DATADIR/connections.json)
	  if [ ! -z ${profileused[0]} ]; then invalid 13 $profile; fi
	  jq -r "del(.\"$profile\")" $DATADIR/profiles.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/profiles.json; chmod  600 $DATADIR/profiles.json
	  echo profile \"$profile\" deleted
  exit 1; fi
  if [ $1 = "mod" ]; then
	  profile=$2
	  mapfile -t profiles < <(jq -r 'keys[]' $DATADIR/profiles.json)
	  if [ -z $(isinarray $profile ${profiles[@]}) ]; then invalid 11 $profile; fi
	  mapfile -t oldvalues < <(jq -r ".\"$profile\"[]" $DATADIR/profiles.json)
	  echo Editing profile $profile
	  echo
	  if [ ! -z $(modify Protocol) ]; then
		  echo
		  if [ $profile == "default" ]; then
			echo Select a protocol for this profile:
		  else
			echo do you want to set a protocol for this profile? if not, please leave empty
		  fi
		  echo options: ssh,telnet
		  echo current protocol: ${oldvalues[0]}
		  if [ $profile == "default" ]; then
			inputregex Protocol '(^ssh$|^telnet$)'
		  else
			inputregex Protocol '(^ssh$|^telnet$|^$)'
		  fi
		  protocol=$valueregex
	  else
	      protocol=${oldvalues[0]}
	  fi
	  echo
	  if [ ! -z $(modify Port) ]; then
		echo
		if [ -z $protocol ]; then
		  echo do you want to set a port for this profile? if not, please leave empty
		  echo options: 1-65535
		  echo current port: ${oldvalues[1]}
		  inputrange Port 1 65535
		  port=$valuerange
		else
		  echo do you want to set a port for this profile? if $protocol default just leave empty
		  echo options: 1-65535
		  echo current port: ${oldvalues[1]}
		  inputrange Port 1 65535
		  port=$valuerange
		  if [ $protocol = "ssh" ] && [ -z "$port" ]; then port=22; fi
		  if [ $protocol = "telnet" ] && [ -z "$port" ]; then port=23; fi
		fi
	  else
	      port=${oldvalues[1]}
	  fi
	  echo
	  if [ ! -z $(modify User) ]; then
		   echo
		   echo do you want to set a user for this profile? if not, please leave empty
		   echo current user: ${oldvalues[2]}
		   inputregex User '.*'
		   user=$valueregex
	  else
	      user=${oldvalues[2]}
	  fi
	  echo
	  if [ ! -z $(modify Password) ]; then
		   echo
		   echo do you want to set a password for this profile? if not, please leave empty
		   echo -n Password:
		   read -s password
		   password=`echo $password | openssl rsautl -inkey $DATADIR/.osk -encrypt -out >(base64 -w 0)`
		   echo 
	  else
	      password=${oldvalues[3]}
	  fi
	  echo
	  if [ ! -z $(modify Options) ]; then
		   echo
		   echo do you want to set other options for this profile? if not, please leave empty
		   echo you can pass extra ssh or telnet options to the session like -X, -L or combined options
		   echo current options: ${oldvalues[4]}
		   inputregex Options '.*'
		   options=$valueregex
	  else
	      options=${oldvalues[4]}
	  fi
	  echo
	  if [ ! -z $(modify Logs) ]; then
		   echo
		   echo do you want to save the session logs for this profile? if not, please leave empty
		   echo set the location and file name, you can use Date command to add timestamp
		   echo 'you can also use the following variables ${hostname}, ${port} and ${user}'
		   echo example: '/home/user/logs/$hostname_$(date '"'"'+%Y-%M-%d_%T'"'"').log'
		   inputregex Logging '.*'
		   logs=$valueregex
	  else
	      logs=${oldvalues[5]}
	  fi
	  newvalues=("$protocol" "$port" "$user" "$password" "$options" "$logs")
	  old=${oldvalues[@]}
	  new=${newvalues[@]}
	  if [ "$old" == "$new" ] ; then
		echo
		echo nothing to do here.
	  else
	    jq -r ". | . + {\"$profile\":{\"protocol\":\"$protocol\", \"port\":\"$port\", \"user\":\"$user\", \"password\":\"$password\", \"options\":\"$options\", \"logs\":\"$logs\"}}" $DATADIR/profiles.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/profiles.json; chmod  600 $DATADIR/profiles.json
		echo
		echo Profile \"$profile\" edited correctly
	  fi
  exit 1; fi
  if [ $1 = "list" ]; then 
	jq -r 'keys[]' $DATADIR/profiles.json
  fi
}
