firstrun(){
  if [ ! -d $DIR/data ]; then mkdir -p $DIR/data; fi
  if [ ! -f $DIR/data/.osk ]; then openssl genrsa -out $DIR/data/.osk 2048  &> /dev/null; chmod  600 $DIR/data/.osk; fi
  touch $DIR/data/.keys.json
  chmod  600 $DIR/data/.keys.json
  touch $DIR/data/profiles.json
  touch $DIR/data/connections.json
  echo -e "{\"default\":{\"protocol\":\"ssh\", \"port\":\"22\"}}" >> $DIR/data/profiles.json
}
