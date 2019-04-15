#!/usr/bin/env bash
#Usage: start-rheakv.sh [OPTIONS]
#   -s    The number of RheaKV servers
#   -p    The number of PlacementDriver servers

set -uxe
set -o pipefail

USER=`whoami`
HOST=`hostname -s`
DOMAIN=`hostname -d`
PORT=8181
SERVERS=1
CONFIG_FILE="/usr/local/rheakv/conf/rheakv.yaml"

function print_usage() {
    echo "\
    Usage: start-rheakv [OPTIONS]
    Starts a rheakv server based on the supplied options.
        -s      The number of servers in the ensemble. The default value is 1.
        -h      Print usage.
    "
}

function create_config() {
    if [ $SERVERS -gt 1 ]; then
        if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
        NAME=${BASH_REMATCH[1]}
        ORD=${BASH_REMATCH[2]}
        else
            echo "Fialed to parse name and ordinal of Pod"
            exit 1
        fi

        # set local host server ip
        sed -i "s/127.0.0.1/$(hostname -f)/g" $CONFIG_FILE

        # init server list
        SERVER_LIST="initialServerList: "
        for (( i=0; i<$SERVERS; i++ ))
        do
            SERVER_LIST="${SERVER_LIST}${NAME}-$i.${DOMAIN}:$PORT,"
        done
        sed -i '/initialServerList: /d' $CONFIG_FILE
        echo "${SERVER_LIST::-1}" >> $CONFIG_FILE
    fi
    cat $CONFIG_FILE >&2
}

optspec="hs:"
while getopts "$optspec" optchar; do

    case "${optchar}" in
        s)
            SERVERS=${OPTARG##*=}
            ;;
        h)
            print_usage
            exit
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done

create_config && exec /usr/local/rheakv/bin/rheakv.sh start-foreground