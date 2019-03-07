firstrun(){
  if [ ! -d $DATADIR ]; then mkdir -p $DATADIR; fi
  if [ ! -f $DATADIR/.osk ]; then openssl genrsa -out $DATADIR/.osk 2048  &> /dev/null; chmod  600 $DATADIR/.osk; fi
  touch $DATADIR/profiles.json; chmod  600 $DATADIR/profiles.json
  touch $DATADIR/connections.json; chmod  600 $DATADIR/connections.json
  echo -e "{\"default\":{\"protocol\":\"ssh\", \"port\":\"22\", \"user\":\"\", \"password\":\"\", \"options\":\"\", \"logs\":\"\"}}" | jq . >> $DATADIR/profiles.json
  echo -e "{}" >> $DATADIR/connections.json
  echo case=\"false\" > $DATADIR/config; chmod  600 $DATADIR/config
}
