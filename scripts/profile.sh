profile(){
  if [ $1 = "add" ]; then echo adding profile $2!; exit 1; fi
  if [ $1 = "del" ]; then echo deleting profile $2!; exit 1; fi
  if [ $1 = "mod" ]; then echo modifying profile $2!; exit 1; fi
}
