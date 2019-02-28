folder(){
  if [ $1 = "add" ] && [ $# -eq 2 ]; then
	  folder=$2
	  mapfile -t folders < <(jq -r 'keys[]' $DIR/data/structure.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then invalid 20 $folder; fi
	  jq -r ". | . + {\"$folder\":{}}" $DIR/data/structure.json > $DIR/data/INPUT.tmp && mv $DIR/data/INPUT.tmp $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
	  echo Folder \"$folder\" added correctly
  exit 1; fi
  if [ $1 = "add" ] && [ $# -eq 3 ]; then
	  folder=$3
	  subfolder=$2
	  mapfile -t folders < <(jq -r 'keys[]' $DIR/data/structure.json)
	  
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then 
		mapfile -t subfolders < <(jq -r ".$folder | to_entries[] | [.key][]" $DIR/data/structure.json)
		if [ ! -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 21 $subfolder $folder; fi
		sub="$(jq -c .$folder $DIR/data/structure.json)"
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub,\"$subfolder\":{}}}" $DIR/data/structure.json > $DIR/data/INPUT.tmp && mv $DIR/data/INPUT.tmp $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
	  else
		invalid 22 $folder
	  fi
	  echo Subfolder \"$subfolder@$folder\" added correctly
  exit 1; fi
  if [ $1 = "del" ] && [ $# -eq 2 ]; then
	folder=$2
	  mapfile -t folders < <(jq -r 'keys[]' $DIR/data/structure.json)
	  if [ -z $(isinarray $folder ${folders[@]}) ]; then invalid 22 $folder; fi
	  jq -r "del(.$folder)" $DIR/data/structure.json > $DIR/data/INPUT.tmp && mv $DIR/data/INPUT.tmp $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
	  echo folder \"$folder\" deleted
  exit 1; fi
  if [ $1 = "del" ] && [ $# -eq 3 ]; then
	  folder=$3
	  subfolder=$2
	  mapfile -t folders < <(jq -r 'keys[]' $DIR/data/structure.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then 
		mapfile -t subfolders < <(jq -r ".$folder | to_entries[] | [.key][]" $DIR/data/structure.json)
		if [ -z $(isinarray $subfolder ${subfolders[@]}) ]; then invalid 23 $subfolder $folder; fi
		jq -r "del(.$folder.$subfolder)" $DIR/data/structure.json > $DIR/data/INPUT.tmp && mv $DIR/data/INPUT.tmp $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
	  else
		invalid 22 $folder
	  fi
	  echo Subfolder \"$subfolder@$folder\" deleted
  exit 1; fi
  if [ $1 = "ren" ] && [ $# -eq 3 ]; then
	  oldfolder=$2
	  newfolder=$3
	  mapfile -t folders < <(jq -r 'keys[]' $DIR/data/structure.json)
	  if [ -z $(isinarray $oldfolder ${folders[@]}) ]; then invalid 22 $oldfolder; fi
	  if [ ! -z $(isinarray $newfolder ${folders[@]}) ]; then invalid 20 $newfolder; fi
	  
	  jq -r "with_entries(if .key == \"$oldfolder\" then .key = \"$newfolder\" else . end)" $DIR/data/structure.json > $DIR/data/INPUT.tmp && mv $DIR/data/INPUT.tmp $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
	  echo Folder \"$oldfolder\" renamed to \"$newfolder\"
  exit 1; fi
  if [ $1 = "ren" ] && [ $# -eq 4 ]; then
	  folder=$3
	  oldsubfolder=$2
	  newsubfolder=$4
	  mapfile -t folders < <(jq -r 'keys[]' $DIR/data/structure.json)
	  if [ ! -z $(isinarray $folder ${folders[@]}) ]; then 
		mapfile -t subfolders < <(jq -r ".$folder | to_entries[] | [.key][]" $DIR/data/structure.json)
		if [ -z $(isinarray $oldsubfolder ${subfolders[@]}) ]; then invalid 23 $oldsubfolder $folder; fi
		if [ ! -z $(isinarray $newsubfolder ${subfolders[@]}) ]; then invalid 21 $newsubfolder $folder; fi
		sub="$(jq -c ".$folder | with_entries(if .key == \"$oldsubfolder\" then .key = \"$newsubfolder\" else . end)" $DIR/data/structure.json)"
		sub=${sub:1:-1}
		jq -r ". | . + {\"$folder\":{$sub}}" $DIR/data/structure.json > $DIR/data/INPUT.tmp && mv $DIR/data/INPUT.tmp $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
	  else
		invalid 22 $folder
	  fi
	  echo Subfolder \"$oldsubfolder@$folder\" renamed to \"$newsubfolder@$folder\" 
  exit 1; fi
}
