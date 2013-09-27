#!/bin/bash

### BEGIN INIT INFO
# Provides:	  app
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the app
# Description:       starts app using start-stop-daemon
### END INIT INFO

NAME=app
SOURCE_DIR=/opt/app
SOURCE_FILE=app.js
SHUTDOWN_SCRIPT=prepareForStop.js
set -e

. /lib/lsb/init-functions

user=www-data
pidfile=/var/run/$NAME.pid
log_dir=$SOURCE_DIR/log
logfile=$SOURCE_DIR/log/$NAME.log

forever_dir=/var/run
node=node
forever=forever
sed=sed

##########################################################################################
# Initializing variables
##########################################################################################

# Read pid from pidfile
if [ -f $pidfile ]; then
	pid=`cat $pidfile`
else
	pid=""
fi

# get forever application ID
if [ "$pid" != "" ]; then
  foreverid=`$forever list | $sed -n /$pid/p | sed 's/\[//g;s/\]//g' | awk ' {print $2} '`
else
  foreverid=""
fi

# echo "pidfile   : ${pidfile}"
# echo "pid       : ${pid}"
# echo "foreverid : ${foreverid}"

##########################################################################################
# functions
##########################################################################################
start(){
  echo "Starting $NAME node instance: "

  if [ "$foreverid" == "" ]; then
    $forever start -p $forever_dir \
                  --pidFile $pidfile \
                  --minUptime 1000ms \
                  --spinSleepTime 1000ms \
                  -l $logfile \
                  -o "${SOURCE_DIR}/log/out.log" \
                  -e "${SOURCE_DIR}/log/err.log" \
                  -a \
                  -d \
                  $SOURCE_DIR/$SOURCE_FILE
    RETVAL=$?
  else
    echo "Instance already running"
    RETVAL=0
  fi
}

stop(){
	echo -n "Shutting down $NAME node instance : "
	if [ "$foreverid" != "" ]; then
# 		$node $SOURCE_DIR/$SHUTDOWN_SCRIPT
		$forever stop -p $forever_dir $foreverid
	else
		echo "Instance is not running";
	fi
	RETVAL=$?
}

##########################################################################################
RETVAL=0

case "$1" in
	start)
		start
		;;
	stop)
		stop
		;;
	status)
		status -p ${pidfile}
		;;
	restart)
	  stop
	  foreverid=""
	  start
	  ;;
	*)
		echo "Usage:  {start|stop|restart}"
		exit 1
		;;
esac

exit $RETVAL
