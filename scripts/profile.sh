inputregex(){
  while true; do
	read -p  "$1: "  valueregex
	if [[ ! $valueregex =~ $2 ]]; then echo wrong input, please try again;
	  else
		break
	  fi
  done
}
inputrange(){
echo $@
  while true; do
	read -p "$1: "  valuerange
	if [ ! $valuerange -ge "$2" ] &> /dev/null || [ ! $valuerange -le "$3" ] &> /dev/null; then echo wrong input, please try again;
	  else
		break
	  fi
  done
}
profile(){
  if [ $1 = "add" ]; then
  profile=$2
  echo Adding profile $2
  echo do you want to set a protocol for this profile? if not, please leave empty
  echo options: ssh,telnet
  inputregex Protocol '(^ssh$|^telnet$|^$)'
  protocol=$valueregex
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
  echo do you want to set a user for this profile? if not, please leave empty
  inputregex User '.*'
  user=$valueregex
  echo $protocol
  echo $port
  echo $user
  echo do you want to set a password for this profile? if not, please leave empty
  echo -n Password:
  read -s password
  password=`echo $password | openssl rsautl -inkey $DIR/data/.osk -encrypt -out >(base64 -w 0)`
  echo do you want to set other options for this profile? if not, please leave empty
  echo you can pass extra ssh or telnet options to the session like -X or -L
  inputregex Options '.*'
  options=$valueregex
  echo $profile
  echo $protocol
  echo $port
  echo $user
  echo $password
  echo $options
  
  exit 1; fi
  if [ $1 = "del" ]; then echo deleting profile $2!
  
  exit 1; fi
  if [ $1 = "mod" ]; then echo modifying profile $2!
  
  exit 1; fi
}
