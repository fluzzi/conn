#!/bin/bash
array=("tee" "sed" "jq" "echo" "printf" "touch" "chmod" "expect" "base64" "openssl" "cd" "dirname" "source" "read" "mkdir" "mapfile" "eval" "ssh" "telnet" "shopt" "getopts")
for i in "${array[@]}"
do
    command -v $i >/dev/null 2>&1 || { 
        echo >&2 "package \"$i\" required"; 
        exit 1; 
    }
done
if [ $# -gt 1 ]; then echo "invalid arguments"; fi;
case $1 in
"")
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or add argument: --local"
  exit 1
fi
mkdir -p /usr/local/bin/.conn
install -m 755 "conn" /usr/local/bin/
for file in .conn/*;do
    install -m 755 "$file" /usr/local/bin/.conn
done
echo "Install complete"
;;
--local)
IFS=':'
for directory in $PATH; do
    if [[ $directory =~ ^$HOME.*/bin$ ]]; then
		mkdir -p $directory/.conn
		install -m 755 "conn" $directory
		for file in .conn/*;do
			install -m 755 "$file" $directory/.conn
		done
		echo "Install complete"
		exit 1
	else 
		
		mkdir -p $HOME/bin
		mkdir -p $HOME/bin/.conn
		install -m 755 "conn" $HOME/bin
		for file in .conn/*;do
			install -m 755 "$file" $HOME/bin/.conn
		done
		echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
		echo "Install complete"
		exit 1
    fi
done
;;
*)
	echo "Invalid argument"
	;;
esac