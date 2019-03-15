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
   conn connection_name[@subfolder][@folder] [-override_options]
         recursively search in folders and subfolders if not specified
		 
   conn [@subfolder][@folder]
         show all available connections globaly or in specified path
```

####        Override options:
```    
               -l <username>   : Override connection user.
               -p <port>       : Override connection port.
               -P <protocol>   : Override connection protocol.
               -o "<options>"  : Override connection protocol options
               -s              : Clear connection password.
```  

####    Generic commands: 
```  
   conn [command1] [command2] <help|-h|--help>
   conn --allow-uppercase <true/false>
        default is <false>
```

####   Manage connections:  
```    
   conn add <connection[@subfolder][@folder]>
   conn del|rm|remove <connection[@subfolder][@folder]>
   conn mod|modify|edit <connection[@subfolder][@folder]>
   conn ren|rename <connection[@subfolder][@folder]> <new_connection_name>
   conn show <connection[@subfolder][@folder]>
   conn ls|list
```   

####   Manage folders:  
``` 
   conn folder add <[subfolder@]folder>
   conn folder del|rm|remove <[subfolder@]folder>
   conn folder ren|rename <[subfolder@]folder> <new_[sub]folder_name> 
   conn folder ls|list
```

####   Manage profiles:   
```   
   conn profile add <profile_name>
   conn profile del|rm|remove <profile_name>
   conn profile mod|modify|edit <profile_name>
   conn profile show <profile_name>
   conn profile ls|list
``` 

####   Examples: 
```  
   conn profile add office-user
   conn folder add office
   conn folder add datacenter@office
   conn add server@datacenter@office
   conn add pc@office
   conn show server@datacenter@office
   conn pc
   conn server@office
   conn server -l root
``` 