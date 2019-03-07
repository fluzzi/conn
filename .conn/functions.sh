#!/bin/bash
isinarray(){
first=$1
shift
for i in "$@"
do
    if [ "$i" == "$first" ] ; then
        printf "true"
    fi
done
}
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
  while true; do
	read -p "$1: "  valuerange
	if ([ ! $valuerange -ge "$2" ] &> /dev/null || [ ! $valuerange -le "$3" ] &> /dev/null) && [[ ! $valuerange =~ (^@.+$) ]]; then echo wrong input, please try again;
	  else
		break
	  fi
  done
}
modify(){
read -p "do you want to edit $1? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    printf true
fi
}
function join_by { local IFS="$1"; shift; echo "$*"; }