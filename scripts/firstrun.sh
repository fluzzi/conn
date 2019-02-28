firstrun(){
  if [ ! -d $DIR/data ]; then mkdir -p $DIR/data; fi
  if [ ! -f $DIR/data/.osk ]; then openssl genrsa -out $DIR/data/.osk 2048  &> /dev/null; chmod  600 $DIR/data/.osk; fi
  touch $DIR/data/profiles.json; chmod  600 $DIR/data/profiles.json
  touch $DIR/data/connections.json; chmod  600 $DIR/data/connections.json
  touch $DIR/data/structure.json; chmod  600 $DIR/data/structure.json
  echo -e "{\"default\":{\"protocol\":\"ssh\", \"port\":\"22\", \"user\":\"\", \"password\":\"\", \"options\":\"\", \"logs\":\"\"}}" | jq . >> $DIR/data/profiles.json
  echo -e "{}" >> $DIR/data/connections.json
  echo -e "{}" >> $DIR/data/structure.json
}
