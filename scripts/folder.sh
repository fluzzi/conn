folder(){
  if [ $1 = "add" ] && [ $# -eq 2 ]; then echo adding folder $2!; exit 1; fi
  if [ $1 = "add" ] && [ $# -eq 3 ]; then echo adding subfolder $3 in folder $2!; exit 1; fi
  if [ $1 = "del" ] && [ $# -eq 2 ]; then echo deleting folder $2!; exit 1; fi
  if [ $1 = "del" ] && [ $# -eq 3 ]; then echo deleting subfolder $3 in folder $2!; exit 1; fi
  if [ $1 = "ren" ] && [ $# -eq 3 ]; then echo renaming folder $2 with $3!; exit 1; fi
  if [ $1 = "ren" ] && [ $# -eq 4 ]; then echo renaming subfolder $2 of folder $3 with folder $4!; exit 1; fi
}
