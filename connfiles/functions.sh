isinarray(){
if [ $1 == "-m" ]; then
	tot=0
	pre=1
	comp=()
	shift; local num=$1; shift
	while [ $pre -le $num ]; do
		comp+=("$1")
		((pre++))
		shift
	done
	for j in "${comp[@]}"; do
		for i in "$@"
		do
			if [[ "$i" == "$j" ]] ; then
				((tot++))
			fi
		done
	done
	if [ $tot -eq $num ]; then printf "true"; fi
else
	first="$1"
shift
for i in "$@"
do
    if [[ "$i" == "$first" ]] ; then
        printf "true"
    fi
done
fi
}
inputregex(){
  while true; do
	read -p  "$1: "  valueregex
	this=${valueregex#?}
	if [[ ! $valueregex =~ $2 ]]; then echo wrong input, please try again;
	elif [[ $valueregex =~ (^@.+$) ]] && [ -z $(isinarray $this ${allprofiles[@]}) ]; then echo profile $this not found, please try again;
    elif [[ $3 == "folder" ]] && [[ ! $valueregex =~ ^$ ]]&& [ -z $(isinarray $valueregex ${allfolders[@]}) ]; then echo location $valueregex not found, please try again;    
	  else
		break
	  fi
  done
}
inputrange(){
  while true; do
	read -p "$1: "  valuerange
	this=${valuerange#?}
	if ([ ! $valuerange -ge "$2" ] &> /dev/null || [ ! $valuerange -le "$3" ] &> /dev/null ) || ([ ! -z $valuerange ] && [[ ! $valuerange =~ (^@.+$) ]] && [[ ! $valuerange =~ (^[0-9]+$) ]]); then echo wrong input, please try again;
	elif [[ $valuerange =~ (^@.+$) ]] && [ -z $(isinarray $this ${allprofiles[@]}) ]; then echo profile $this not found, please try again;
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
function join_by { 
input=($@)
if [[ ${input[0]} == "-m" ]]; then
local IFS="@"; shift 2; 
sed "s/@/${input[1]}/g" <<< "$*"
else
local IFS="$1"; shift; echo "$*"; 
fi
}
split_by () {
    string=$1
    separator=$2
	result=()
    tmp=${string//"$separator"/$'\2'}
    IFS=$'\2' read -a arr <<< "$tmp"
	num=$((${#arr[@]} - 1))
	if [[ $3 == "-r" ]]; then
	for substr in "${arr[@]}" ; do
		result[$num]="$substr"
		((num--))
    done
	else
	result=(${arr[@]})
	fi
	echo ${result[@]}
}
get_values () {
	path=$(split_by $1 "@")
    local id=$(split_by $1 "@" -r)
	if [ $# -eq 3 ]; then 
        path=(jq -r \'.\"$3\".\"$2\".\"$(join_by -m "\".\"" $path)\"[]\' $DATADIR/connections.json)
        id="$(join_by "@" $id)@${2}@${3}"
    fi
	if [ $# -eq 2 ]; then 
        path=(jq -r \'.\"$2\".\"$(join_by -m "\".\"" $path)\"[]\' $DATADIR/connections.json)
        id="$(join_by "@" $id)@${2}"
    fi
	if [ $# -eq 1 ]; then
        path=(jq -r \'.\"$(join_by -m "\".\"" $path)\"[]\' $DATADIR/connections.json)
        id="$(join_by "@" $id)"
    fi
	mapfile -t args < <(eval ${path[@]})
	for i in "${!args[@]}"; do
		if [ -z "${args[$i]}" ] && [ $i -ge 2 ] && [ $i -le 3 ]; then
			this=(jq -r \'.\"default\".${arguments[$i]}\' $DATADIR/profiles.json)
			mapfile -t this < <(eval ${this[@]})
			args[$i]=${this[@]}
		fi
		if [[ "${args[$i]}" =~ ^@.*$ ]] && [ $i -eq 5 ]; then 
			IFS='|' read -ra that <<< "${args[$i]}"
			for j in "${!that[@]}"; do
				that[$j]=${that[$j]#?}
				those=(jq -r \'.\"${that[$j]}\".${arguments[$i]}\' $DATADIR/profiles.json)
				mapfile -t those < <(eval ${those[@]})
				that[$j]=${those[@]}
			done
			args[$i]=$(join_by "|" ${that[@]})
		elif [[ "${args[$i]}" =~ ^@.*$ ]]; then
			this=${args[$i]#?}
			this=(jq -r \'.\"$this\".${arguments[$i]}\' $DATADIR/profiles.json)
			mapfile -t this < <(eval ${this[@]})
			args[$i]=${this[@]}
        fi
	done
    args[0]="$id"
}
