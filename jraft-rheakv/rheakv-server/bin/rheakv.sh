#!/usr/bin/env bash

set -exu
set -o pipefail

BIN_DIR=$(cd `dirname $0`; pwd)

if [ ! -e "$BIN_DIR/env.sh" ]; then
    echo "not set env.sh" && exit 1
else
    . "$BIN_DIR/env.sh"
fi

PROG_NAME=rheakv
PID_FILE=$PID_PATH/${PROG_NAME}.pid

MAIN_CLASS="com.alipay.sofa.jraft.rhea.server.RheaKvServerBootstrap"

echo "RHEA_HOME="$RHEA_HOME
echo "RHEAKV_USER="$RHEAKV_USER

if [ $# == 0 ]; then
    echo "Usage: $0 {start|start-foreground|stop|restart|status}" >&2 && exit 1
fi

ulimit -c unlimited
ulimit -n 100000

# Create dirs if they don't exist
[ -e $LOG_PATH ] || mkdir -p $LOG_PATH
chown $RHEAKV_USER: $LOG_PATH

[ -e $DATA_PATH ] || mkdir -p $DATA_PATH
[ -e $RAFT_PATH ] || mkdir -p $RAFT_PATH
[ -e $DB_PATH ] || mkdir -p $DB_PATH
[ -e $PID_PATH ] || mkdir -p $PID_PATH
chown -R $RHEAKV_USER: $DATA_PATH

# jvm parameters
MEM_INFO_KB=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

# reserve one quarter memory for system
JVM_MAX_MEM_MB="`expr ${MEM_INFO_KB} / 1024 \* 3 / 4`"

SERVER_JVM_FLAGS="-Xmx${JVM_MAX_MEM_MB}M -Djdk.nio.maxCachedBufferSize=2000000"
JVM_FLAGS="$SERVER_JVM_FLAGS $BASE_JVM_FLAGS"

# log4j parameters
# NOTE: logging.path used by rheakv & bolt
LOG_PARAMS="-Dlogging.path=${LOG_PATH} -Dlog4j.configurationFile=$LOG_CONF_FILE "

echo "whoami: $(whoami)"

case $1 in
start)
    echo  -n "Starting $PROG_NAME ... "
    if [ -f "$PID_FILE" ]; then
      if kill -0 `cat "$PID_FILE"` > /dev/null 2>&1; then
         echo $PROG_NAME already running as process `cat "$PID_FILE"`.
         exit 0
      fi
    fi
    nohup "$JAVA" $LOG_PARAMS -cp "$CLASSPATH" $BASE_JVM_FLAGS $MAIN_CLASS $RHEA_CONF &> /dev/null &
    if [ $? -eq 0 ]; then
      /bin/echo -n $! > "$PID_FILE"
      if [ $? -eq 0 ]; then
        sleep 1
        echo "$PROG_NAME STARTED"
      else
        echo "$PROG_NAME FAILED TO WRITE PID"
        exit 1
      fi
    else
      echo "$PROG_NAME DID NOT START"
      exit 1
    fi
    ;;
start-foreground)
     "$JAVA" $LOG_PARAMS -cp "$CLASSPATH" $JVM_FLAGS $MAIN_CLASS $RHEA_CONF
    ;;
stop)
    echo -n "Stopping $PROG_NAME ... "
    if [ ! -f "$PID_FILE" ]
    then
      echo "no $PROG_NAME to stop (could not find file $PID_FILE)"
    else
      kill -9 $(cat "$PID_FILE")
      rm "$PID_FILE"
      echo "$PROG_NAME STOPPED"
    fi
    exit 0
    ;;
restart)
    shift
    "$0" stop ${@}
    sleep 3
    "$0" start ${@}
    ;;
status)
    if [ -f "$PID_FILE" ]; then
      if kill -0 `cat "$PID_FILE"` > /dev/null 2>&1; then
         echo $PROG_NAME is running as process `cat "$PID_FILE"`.
         exit 0
      fi
    else
        echo "$PROG_NAME is stopped"
        exit 1
    fi
    ;;
*)
    echo "Usage: $0 {start|start-foreground|stop|restart|status}" >&2
    exit 1
esac