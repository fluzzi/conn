source $DATADIR/config 2> /dev/null
if [ -z $case ]; then echo case=\"false\" >> $DATADIR/config; chmod  600 $DATADIR/config; fi
if [ -z $idletime ]; then echo idletime=\"0\" >> $DATADIR/config; fi
source $DATADIR/config