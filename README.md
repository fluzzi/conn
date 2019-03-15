# Conn

Conn is a ssh and telnet connection manager for bash.

### Getting Started

These instructions will get you a copy of the project up and running on your local.

#### Prerequisites

The following packages are required to use conn:

`
jq, expect
`

#### Installing

Install for all users:

`
sudo ./install.sh
`

Install for local user:

`
./install.sh --local
`

End with an example of getting some data out of the system or using it for a little demo

### Usage
```
   $SCRIPT_NAME connection_name[@subfolder][@folder] [-override_options]
         recursively search in folders and subfolders if not specified
   $SCRIPT_NAME [@subfolder][@folder]
         show all available connections globaly or in specified path
```   
        Override options:
               -l <username>   : Override connection user.
               -p <port>       : Override connection port.
               -P <protocol>   : Override connection protocol.
               -o \"<options>\"  : Override connection protocol options
               -s              : Clear connection password.
  
   Generic commands:  
   $SCRIPT_NAME [command1] [command2] <help|-h|--help>
   $SCRIPT_NAME --allow-uppercase <true/false>
        default is <false>

   Manage connections:  
   $SCRIPT_NAME add <connection[@subfolder][@folder]>
   $SCRIPT_NAME del|rm|remove <connection[@subfolder][@folder]>
   $SCRIPT_NAME mod|modify|edit <connection[@subfolder][@folder]>
   $SCRIPT_NAME ren|rename <connection[@subfolder][@folder]> <new_connection_name>
   $SCRIPT_NAME ls|list

   Manage folders:  
   $SCRIPT_NAME folder add <[subfolder@]folder>
   $SCRIPT_NAME folder del|rm|remove <[subfolder@]folder>
   $SCRIPT_NAME folder ren|rename <[subfolder@]folder> <new_[sub]folder_name> 
   $SCRIPT_NAME folder ls|list

   Manage profiles:  
   $SCRIPT_NAME profile add <profile_name>
   $SCRIPT_NAME profile del|rm|remove <profile_name>
   $SCRIPT_NAME profile mod|modify|edit <profile_name>
   $SCRIPT_NAME profile ls|list

Examples:
   $SCRIPT_NAME profile add office-user
   $SCRIPT_NAME folder add office
   $SCRIPT_NAME folder add datacenter@office
   $SCRIPT_NAME add server@datacenter@office
   $SCRIPT_NAME add pc@office
   $SCRIPT_NAME pc
   $SCRIPT_NAME server@office
   $SCRIPT_NAME server -l root
