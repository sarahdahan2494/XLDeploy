#!/bin/sh

if test $1 -le 0
then
  echo "First parameter (\"$1\") must be a positive number."
  echo "startLocalWorker.sh NUMBER -api URL -master NAME:PORT ..."
  echo "Usage: Starts a local worker with parameter values set based on the NUMBER."
  echo "       See usage message of 'run.sh worker' for details."
  exit -1
fi

WORKER_NUMBER=$1

WORKER_NAME="worker-$WORKER_NUMBER"
WORKER_PORT=$((8180 + $WORKER_NUMBER))
WORKER_WORKDIR="work-$WORKER_NUMBER"
WORKER_LOG="deployit-worker-$WORKER_NUMBER"

BIN_DIR=$(dirname $0)

shift

set -x #echo on

LOGFILE=$WORKER_LOG sh $BIN_DIR/run.sh worker -name $WORKER_NAME -port $WORKER_PORT -work $WORKER_WORKDIR "$@"
