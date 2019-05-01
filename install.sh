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
install -m 755 "conn-autocomplete" /etc/bash_completion.d/
for file in connfiles/*;do
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
		install -m 755 "conn-autocomplete" $directory/.conn
		for file in connfiles/*;do
			install -m 755 "$file" $directory/.conn
		done
		echo "source '$directory/.conn/conn-autocomplete'" >> ~/.bashrc
		echo "Install complete"
		exit 0
	else 
		
		mkdir -p $HOME/bin
		mkdir -p $HOME/bin/.conn
		install -m 755 "conn" $HOME/bin
		install -m 755 "conn-autocomplete" $HOME/bin/.conn
		for file in connfiles/*;do
			install -m 755 "$file" $HOME/bin/.conn
		done
		echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
		echo "source '$HOME/bin/.conn/conn-autocomplete'" >> ~/.bashrc
		echo "Install complete"
		exit 0
    fi
done
;;
*)
	echo "Invalid argument"
	;;
esac
