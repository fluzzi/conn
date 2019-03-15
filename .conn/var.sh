validdir='0-9a-zA-Z_,.$@#-'
validfile='0-9a-zA-Z_,.$#-'
shopt -s extglob
names='@(mod|modify|edit|ren|raname|add|folder|subfolder|connection|profile|del|delete|remove|rm|help|type|host|logs|options|password|port|protocol|user|list|ls|-h|--help|show)'
namesif='^(mod|modify|edit|ren|raname|add|folder|subfolder|connection|profile|del|delete|remove|rm|help|type|host|logs|options|password|port|protocol|user|list|ls|[-]h|[-][-]help|show)$'
args=( )
flag=0
flags=
arguments=(type host protocol port user password options logs)
mapfile -t allprofiles < <(jq -r 'keys[]' $DATADIR/profiles.json)