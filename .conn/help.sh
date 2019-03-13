help(){
  if [ $1 = "folder" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME folder add <[subfolder@]folder>"
  echo "   $SCRIPT_NAME folder del|rm|remove <[subfolder@]folder>"
  echo "   $SCRIPT_NAME folder ren|rename <[subfolder@]folder> <new_[sub]folder_name>" 
  echo "   $SCRIPT_NAME folder ls|list"
  echo "   $SCRIPT_NAME folder [help]"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME folder add office"
  echo "   $SCRIPT_NAME folder add data@office"
  echo "   $SCRIPT_NAME folder ren data@office datacenter"
  echo "   $SCRIPT_NAME folder del datacenter@office"
  echo
  exit 1; fi
  if [ $1 = "folder-add" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME folder add <[subfolder@]folder>"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME folder add office"
  echo "   $SCRIPT_NAME folder add data@office"
  echo
  exit 1; fi
  if [ $1 = "folder-del" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME folder del|rm|remove <[subfolder@]folder>"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME folder del datacenter@office"
  echo "   $SCRIPT_NAME folder del office"
  echo
  exit 1; fi
  if [ $1 = "folder-ren" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME folder ren|rename <[subfolder@]folder> <new_[sub]folder_name>" 
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME folder ren newoffice office"
  echo "   $SCRIPT_NAME folder ren data@office datacenter"
  echo
  exit 1; fi
  if [ $1 = "profile" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME profile add <profile_name>"
  echo "   $SCRIPT_NAME profile del|rm|remove <profile_name>"
  echo "   $SCRIPT_NAME profile mod|modify|edit <profile_name>"
  echo "   $SCRIPT_NAME profile ls|list"
  echo "   $SCRIPT_NAME profile [help]"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME profile add office-user"
  echo "   $SCRIPT_NAME profile edit office-user"
  echo "   $SCRIPT_NAME profile del office-user"
  echo
  exit 1; fi
  if [ $1 = "profile-add" ]; then echo help profile add; exit 1; fi
  if [ $1 = "profile-del" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME profile del|rm|remove <profile_name>"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME profile rm office-user"
  echo
  exit 1; fi
  if [ $1 = "profile-edit" ]; then echo help profile edit; exit 1; fi
  if [ $1 = "add" ]; then echo help add; exit 1; fi
  if [ $1 = "del" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME del|rm|remove <connection[@subfolder][@folder]>"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME del server@datacenter"
  echo "   $SCRIPT_NAME del server"
  echo
  exit 1; fi
  if [ $1 = "edit" ]; then echo help edit; exit 1; fi
  if [ $1 = "ren" ]; then 
    echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME ren|rename <connection[@subfolder][@folder]> <new_connection_name>"
  echo "Examples:"
  echo "   $SCRIPT_NAME ren pc@office pc-old"
  echo "   $SCRIPT_NAME ren server@datacenter@office server-old"
  echo
  exit 1; fi
  if [ $1 = "global" ]; then 
  echo
  echo "Usage:" 
  echo "   $SCRIPT_NAME connection_name[@subfolder][@folder] [-override_options]"
  echo "         recursively search in folders and subfolders if not specified"
  echo "   $SCRIPT_NAME [@subfolder][@folder]"
  echo "         show all available connections globaly or in specified path"
  echo     
  echo "        Override options:"
  echo "               -l <username>   : Override connection user."
  echo "               -p <port>       : Override connection port."
  echo "               -P <protocol>   : Override connection protocol."
  echo "               -o \"<options>\"  : Override connection protocol options"
  echo "               -s              : Clear connection password."
  echo    
  echo "   Generic commands:"  
  echo "   $SCRIPT_NAME [command] help"
  echo "   $SCRIPT_NAME --allow-uppercase <true/false>"
  echo "        default is <false>"
  echo
  echo "   Manage connections:"  
  echo "   $SCRIPT_NAME add <connection[@subfolder][@folder]>"
  echo "   $SCRIPT_NAME del|rm|remove <connection[@subfolder][@folder]>"
  echo "   $SCRIPT_NAME mod|modify|edit <connection[@subfolder][@folder]>"
  echo "   $SCRIPT_NAME ren|rename <connection[@subfolder][@folder]> <new_connection_name>"
  echo "   $SCRIPT_NAME ls|list"
  echo
  echo "   Manage folders:"  
  echo "   $SCRIPT_NAME folder add <[subfolder@]folder>"
  echo "   $SCRIPT_NAME folder del|rm|remove <[subfolder@]folder>"
  echo "   $SCRIPT_NAME folder ren|rename <[subfolder@]folder> <new_[sub]folder_name>" 
  echo "   $SCRIPT_NAME folder ls|list"
  echo
  echo "   Manage profiles:"  
  echo "   $SCRIPT_NAME profile add <profile_name>"
  echo "   $SCRIPT_NAME profile del|rm|remove <profile_name>"
  echo "   $SCRIPT_NAME profile mod|modify|edit <profile_name>"
  echo "   $SCRIPT_NAME profile ls|list"
  echo
  echo "Examples:"
  echo "   $SCRIPT_NAME profile add office-user"
  echo "   $SCRIPT_NAME folder add office"
  echo "   $SCRIPT_NAME folder add datacenter@office"
  echo "   $SCRIPT_NAME add server@datacenter@office"
  echo "   $SCRIPT_NAME add pc@office"
  echo "   $SCRIPT_NAME pc"
  echo "   $SCRIPT_NAME server@office"
  echo "   $SCRIPT_NAME server -l root"
  echo
  echo
  exit 1; fi
}
