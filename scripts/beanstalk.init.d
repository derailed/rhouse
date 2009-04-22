#!/bin/bash
#
# Init file for BeanStalkd.
#
# Written by Fernand Galiana.
#
#
[ -x /usr/local/bin/beanstalkd ] || exit 1

RETVAL=0
desc="Beanstalk"
pidfile=/tmp/beanstalkd.pid

BEANSTALK_USER=fernand

if [ -f ${pidfile} ]; then
  BEANSTALK_PID=`cat ${pidfile}`
fi;

start() {
    su ${BEANSTALK_USER} -c 'beanstalkd -p 7777& echo $! > /tmp/beanstalkd.pid'
    RETVAL=$?
    echo Beanstalkd server started 
    return $RETVAL
}

stop() {
     if [ -n "$BEANSTALK_PID" ] && ps -p ${BEANSTALK_PID} > /dev/null ; then
        kill -9 ${BEANSTALK_PID}
        $0 status
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f ${lockfile} ${pidfile}
     else
       echo Beanstalkd is not running
       RETVAL=1
     fi
     return $RETVAL
}

restart() {
        stop
        start
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        restart
        ;;
  status)
        if [ -n "$BEANSTALK_PID" ] && ps -p ${BEANSTALK_PID} > /dev/null; then
          echo Beanstalk server is running
          RETVAL=0
        else
          echo Beanstalk server is stopped
        fi
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|status}"
        RETVAL=1
esac

exit $RETVAL