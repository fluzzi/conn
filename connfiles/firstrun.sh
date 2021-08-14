firstrun(){
  if [ ! -f $DATADIR/.osk ]; then openssl genrsa -out $DATADIR/.osk 2048  &> /dev/null; chmod  600 $DATADIR/.osk; fi
  if [ ! -f $DATADIR/profiles.json ]; then
    touch $DATADIR/profiles.json; chmod  600 $DATADIR/profiles.json
    echo -e "{\"default\":{\"host\":\"\", \"protocol\":\"ssh\", \"port\":\"22\", \"user\":\"\", \"password\":\"\", \"options\":\"\", \"logs\":\"\"}}" | jq . >> $DATADIR/profiles.json
  else
    jq 'to_entries | map(if .value.host == null then .value = {"host":""} + .value else . end) | from_entries' $DATADIR/profiles.json > $DATADIR/INPUT.tmp && mv $DATADIR/INPUT.tmp $DATADIR/profiles.json; chmod  600 $DATADIR/profiles.json
  fi
  if [ ! -f $DATADIR/connections.json ]; then
    touch $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
    echo -e "{}" >> $DATADIR/connections.json
  fi
  sed -i 's/frun=.*/frun="false"/' $DATADIR/config
}
