validdir='0-9a-zA-Z_.$@#-'
validfile='0-9a-zA-Z_.$#-'
validlist='0-9a-zA-Z_,.$#-'
shopt -s extglob
namesif='^(mod|modify|edit|ren|rename|add|folder|subfolder|connection|profile|del|delete|remove|rm|help|type|host|logs|options|password|port|protocol|user|list|ls|[-]h|[-][-]help|show|bulk)$'
args=( )
flag=0
flags=
arguments=(type host protocol port user password options logs)
mapfile -t allprofiles < <(jq -r 'keys[]' $DATADIR/profiles.json)
mapfile -t allfolders < <(jq -r 'paths as $path | select(getpath($path) == "folder" or getpath($path) == "subfolder") | $path | [map(select(. != "type"))[-1,-2]] | map(select(. !=null)) | join("@")' $DATADIR/connections.json)
