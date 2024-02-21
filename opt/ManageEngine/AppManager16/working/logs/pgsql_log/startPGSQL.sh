#!/bin/sh
if [ $# = 1 ]
then
	PGSQL_HOME=$1
else
	WORKING_HOME=`pwd`
	PGSQL_HOME=$WORKING_HOME/pgsql
	
fi

FILEOWNER="`ls -l $PGSQL_HOME/data/ | grep "amdb" | awk '{print $3}'`"
COMM="`id |cut -d '=' -f2|cut -d '(' -f1`"

if [ $COMM != "0" ]
then
	$PGSQL_HOME/bin/pg_ctl -D $PGSQL_HOME/data/amdb start &
	#Going to wait for pg_ctl start command to complete to get the exitcode (Anyway, the default timeout of pg_ctl start command is 60 sec)
	wait $!
else
	su - $FILEOWNER -c "$PGSQL_HOME/bin/pg_ctl -D $PGSQL_HOME/data/amdb start & wait \$!; exit \$?"
fi
rc=$?
exit $rc