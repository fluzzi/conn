invalid(){
  # errors for user input
  if [ $1 -eq 3 ]; then echo Too many arguments; exit 1; fi
  if [ $1 -eq 1 ]; then echo Invalid arguments; exit 1; fi
  if [ $1 -eq 4 ]; then echo Invalid name; exit 1; fi
  if [ $1 -eq 2 ]; then echo Missing arguments; exit 1; fi
  if [ $1 -eq 5 ]; then echo Invalid characters; exit 1; fi
  if [ $1 -eq 6 ]; then echo Only folder and subfolder is allowed; exit 1; fi
  if [ $1 -eq 7 ]; then echo Only connection, subfolder and folder is allowed; exit 1; fi
  if [ $1 -eq 8 ]; then echo Unknown option: $2; exit 1; fi
  # errors for profiles
  if [ $1 -eq 10 ]; then echo Profile \"$2\" already exist; exit 1; fi
  if [ $1 -eq 11 ]; then echo Profile \"$2\" do not exist; exit 1; fi
}
