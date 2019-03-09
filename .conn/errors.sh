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
  if [ $1 -eq 12 ]; then echo Profile \"$2\" can not be deleted; exit 1; fi
  if [ $1 -eq 13 ]; then echo Profile \"$2\" is being used by a connection; exit 1; fi
  # errors for folders and connections
  if [ $1 -eq 20 ]; then echo Folder or connection \"$2\" already exist; exit 1; fi
  if [ $1 -eq 21 ]; then echo subfolder or connection \"$2\@$3\" already exist; exit 1; fi
  if [ $1 -eq 22 ]; then echo folder \"$2\" do not exist; exit 1; fi
  if [ $1 -eq 23 ]; then echo subfolder \"$2\@$3\" do not exist; exit 1; fi
  if [ $1 -eq 24 ]; then echo connection \"$2\" do not exist; exit 1; fi
  if [ $1 -eq 25 ]; then echo invalid address \"$2\"; exit 1; fi
}
