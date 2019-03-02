adm(){
  if [ $1 = "add" ]; then echo adding $2!; 
  
  exit 1; fi
  if [ $1 = "del" ]; then echo deleting $2!; 
  
  exit 1; fi
  if [ $1 = "mod" ]; then echo modifying $2!; 
  
  exit 1; fi
}
