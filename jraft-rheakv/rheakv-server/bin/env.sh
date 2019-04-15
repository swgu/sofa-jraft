#!/usr/bin/env bash

set -x

# set path
BIN_DIR=$(cd `dirname $0`; pwd)
RHEA_HOME="${BIN_DIR}/.."
CONF_DIR="$RHEA_HOME/conf"
RHEA_CONF="$CONF_DIR/rheakv.yaml"
LOG_CONF_FILE="$CONF_DIR/log4j2.xml"

# set log dir
LOG_PATH=${LOG_PATH:-$RHEA_HOME/logs}
export LOG_PATH

# set data dir
DATA_PATH=${DATA_PATH:-$RHEA_HOME/data}
RAFT_PATH="$DATA_PATH/raft_data"
DB_PATH="$DATA_PATH/rhea_db"
PID_PATH="$DATA_PATH/pid"

export DATA_PATH RAFT_PATH DB_PATH PID_PATH

# jdk env
if [ "$JAVA_HOME" != "" ]; then
  JAVA="$JAVA_HOME/bin/java"
else
  JAVA=java
fi
echo "JAVA_HOME=$JAVA_HOME"

RHEAKV_USER=${RHEAKV_USER:-$(whoami)}
CLASSPATH=${CLASSPATH:-}

CLASSPATH="$CLASSPATH:$RHEA_HOME/lib/*:$JAVA_HOME/lib/*"

# add all conf to classpath
CLASSPATH="$CONF_DIR:$CLASSPATH"

echo "CLASSPATH=$CLASSPATH"

BASE_JVM_FLAGS="-server -XX:-UseBiasedLocking -XX:+UseG1GC -XX:+ExplicitGCInvokesConcurrent -XX:+HeapDumpOnOutOfMemoryError \
-XX:+UseGCOverheadLimit -XX:+ExitOnOutOfMemoryError -Djdk.attach.allowAttachSelf=true -Dsun.net.inetaddr.ttl=0"