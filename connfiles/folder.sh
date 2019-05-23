folder(){
  if [ $1 = "add" ] && [ $# -eq 2 ]; then
	  folder=$2
	  mapfile -t folders < <(jq -r 'keys[]' $DATADIR/connections.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then invalid 20 $folder; fi
	  jq -r ". | . + {\"$folder\":{\"type\": \"folder\"}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  echo Folder \"$folder\" added correctly
  exit 0; fi
  if [ $1 = "add" ] && [ $# -eq 3 ]; then
	  folder=$3
	  subfolder=$2
	  mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then 
	    getsubfolders=(jq -r \'\.\"$folder\" \| to_entries\[\] \| \[\.key\]\[\]\' $DATADIR/connections.json)
		mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ ! -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 21 $subfolder $folder; fi
		sub="$(jq -c .\"$folder\" $DATADIR/connections.json)"
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub,\"$subfolder\":{\"type\": \"subfolder\"}}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  else
		invalid 22 $folder
	  fi
	  echo Subfolder \"$subfolder@$folder\" added correctly
  exit 0; fi
  if [ $1 = "del" ] && [ $# -eq 2 ]; then
	folder=$2
	  mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
	  if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  jq -r "del(.\"$folder\")" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  echo folder \"$folder\" deleted
  exit 0; fi
  if [ $1 = "del" ] && [ $# -eq 3 ]; then
	  folder=$3
	  subfolder=$2
	  mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
		mapfile -t subfolders < <(eval ${getsubfolders[@]})
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
		jq -r "del(.\"$folder\".\"$subfolder\")" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  else
		invalid 22 $folder
	  fi
	  echo Subfolder \"$subfolder@$folder\" deleted
  exit 0; fi
  if [ $1 = "ren" ] && [ $# -eq 3 ]; then
	  oldfolder=$2
	  newfolder=$3
	  mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
	  mapfile -t everything < <(jq -r '. as $object | keys[] ' $DATADIR/connections.json)
	  if [ -z $(isinarray $oldfolder ${folders[@]}) ]; then invalid 22 $oldfolder; fi
	  if [ ! -z $(isinarray $newfolder ${everything[@]}) ]; then invalid 20 $newfolder; fi
	  
	  jq -r "with_entries(if .key == \"$oldfolder\" then .key = \"$newfolder\" else . end)" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  echo Folder \"$oldfolder\" renamed to \"$newfolder\"
  exit 0; fi
  if [ $1 = "ren" ] && [ $# -eq 4 ]; then
	  folder=$4
	  oldsubfolder=$2
	  newsubfolder=$3
	  mapfile -t folders < <(jq -r '. as $object | keys[] | select($object[.].type == "folder")?' $DATADIR/connections.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then 
		getsubfolders=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \| select\(\$object\[\.\]\.type \=\= \"subfolder\"\)\?\' $DATADIR/connections.json)
		mapfile -t subfolders < <(eval ${getsubfolders[@]})
		geteverything=(jq -r \'\.\"$folder\" \| \. as \$object \| keys\[\] \' $DATADIR/connections.json)
		mapfile -t everything < <(eval ${geteverything[@]})
		if [ -z $(isinarray $oldsubfolder ${subfolders[@]}) ]; then invalid 23 $oldsubfolder $folder; fi
		if [ ! -z $(isinarray $newsubfolder ${everything[@]}) ]; then invalid 21 $newsubfolder $folder; fi
		sub="$(jq -c ".\"$folder\" | with_entries(if .key == \"$oldsubfolder\" then .key = \"$newsubfolder\" else . end)" $DATADIR/connections.json)"
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub}}" $DATADIR/connections.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
	  else
		invalid 22 $folder
	  fi
	  echo Subfolder \"$oldsubfolder@$folder\" renamed to \"$newsubfolder@$folder\" 
  exit 0; fi
  if [ $1 = "list" ]; then 
	jq -r 'paths as $path | select(getpath($path) == "folder" or getpath($path) == "subfolder") | $path | [map(select(. != "type"))[-1,-2]] | map(select(. !=null)) | join("@")' $DATADIR/connections.json
    exit 0
  fi
}
