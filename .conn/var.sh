validdir='0-9a-zA-Z_,.$@#-'
validfile='0-9a-zA-Z_,.$#-'
shopt -s extglob
names='@(mod|modify|edit|ren|raname|add|folder|folders|profile|del|delete|rem|remove|rm|help|type)'
namesif='^(mod|modify|edit|ren|raname|add|folder|folders|profile|del|delete|rem|remove|rm|help|type)$'
args=( )
flag=0
flags=