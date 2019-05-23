invalid(){
  # errors for user input
  if [ $1 -eq 3 ]; then echo "Too many arguments" 1>&2; exit 103; fi
  if [ $1 -eq 1 ]; then echo "Invalid arguments" 1>&2; exit 101; fi
  if [ $1 -eq 4 ]; then echo "Invalid name" 1>&2; exit 104; fi
  if [ $1 -eq 2 ]; then echo "Missing arguments" 1>&2; exit 102; fi
  if [ $1 -eq 5 ]; then echo "Invalid characters" 1>&2; exit 105; fi
  if [ $1 -eq 6 ]; then echo "Only folder and subfolder is allowed" 1>&2; exit 106; fi
  if [ $1 -eq 7 ]; then echo "Only connection, subfolder and folder is allowed" 1>&2; exit 107; fi
  if [ $1 -eq 8 ]; then echo "Unknown option: $2" 1>&2; exit 108; fi
  if [ $1 -eq 9 ]; then echo "Invalid protocol $2" 1>&2; exit 109; fi
  # errors for profiles
  if [ $1 -eq 10 ]; then echo "Profile \"$2\" already exist" 1>&2; exit 110; fi
  if [ $1 -eq 11 ]; then echo "Profile \"$2\" do not exist" 1>&2; exit 111; fi
  if [ $1 -eq 12 ]; then echo "Profile \"$2\" can not be deleted" 1>&2; exit 112; fi
  if [ $1 -eq 13 ]; then echo "Profile \"$2\" is being used by a connection" 1>&2; exit 113; fi
  # errors for folders and connections
  if [ $1 -eq 20 ]; then echo "Folder or connection \"$2\" already exist" 1>&2; exit 120; fi
  if [ $1 -eq 21 ]; then echo "Subfolder or connection \"$2\@$3\" already exist" 1>&2; exit 121; fi
  if [ $1 -eq 22 ]; then echo "Folder \"$2\" do not exist" 1>&2; exit 122; fi
  if [ $1 -eq 23 ]; then echo "Subfolder \"$2\@$3\" do not exist" 1>&2; exit 123; fi
  if [ $1 -eq 24 ]; then echo "Connection \"$2\" do not exist" 1>&2; exit 124; fi
  if [ $1 -eq 25 ]; then echo "Invalid address \"$2\"" 1>&2; exit 125; fi
  if [ $1 -eq 26 ]; then echo "No connections found, try: conn help" 1>&2; exit 126; fi
  # errors for bulk
  if [ $1 -eq 30 ]; then echo "duplicates nodes found" 1>&2; exit 130; fi
}
