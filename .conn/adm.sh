adm(){
  if [ $1 = "add" ] && [ $# -eq 2 ]; then echo adding $2!; exit 1; fi
  if [ $1 = "del" ] && [ $# -eq 2 ]; then echo deleting $2!; exit 1; fi
  if [ $1 = "mod" ] && [ $# -eq 2 ]; then echo modifying $2!; exit 1; fi
}
