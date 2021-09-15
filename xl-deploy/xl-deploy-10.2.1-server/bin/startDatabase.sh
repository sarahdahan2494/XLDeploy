#!/usr/bin/env bash
absdirname ()
{
  _dir="`dirname \"$1\"`"
  cd "$_dir"
  echo "`pwd`"
}

# Get Java executable
if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=java
else
  JAVACMD="${JAVA_HOME}/bin/java"
fi

# Get XL Deploy server home dir
if [ -z "$DEPLOYIT_SERVER_HOME" ] ; then
  self="$0"
  if [ -h "$self" ]; then
    self=`resolvelink "$self"`
  fi
  BIN_DIR=`absdirname "$self"`
  DEPLOYIT_SERVER_HOME=`dirname "$BIN_DIR"`
elif [ ! -d "$DEPLOYIT_SERVER_HOME" ] ; then
  echo "Directory $DEPLOYIT_SERVER_HOME does not exist"
  exit 1
fi

cd "$DEPLOYIT_SERVER_HOME"

# Default port
DERBY_PORT=1527
START_DATABASE=1

if [ -f "$DEPLOYIT_SERVER_HOME/centralConfiguration/deploy-repository.yaml" ] ; then
  START_DATABASE=0
  CONF_FILE=`grep -v '^[[:space:]]*\/\/\|^[[:space:]]*#' "$DEPLOYIT_SERVER_HOME/centralConfiguration/deploy-repository.yaml"`
  DERBY_URL=`echo "$CONF_FILE" | grep 'jdbc:derby://localhost' | head -n 1 `
  if [ ! -z "$DERBY_URL" ] ; then
    DERBY_PORT=`echo "$DERBY_URL" | sed -n 's/.*:\([0-9]*\).*/\1/p'`
    START_DATABASE=1
  fi
fi

if [ "$START_DATABASE" == '1' ]; then
  echo "XLD will attempt to start a Derby Network Server on port '$DERBY_PORT'"
  CLASSPATH=$(JARS=("$DEPLOYIT_SERVER_HOME/derbyns"/*.jar); IFS=:; echo "${JARS[*]}")
  $JAVACMD -Djava.security.manager=java.lang.SecurityManager -Djava.security.policy=conf/xl-deploy.policy -cp "$CLASSPATH" org.apache.derby.drda.NetworkServerControl start -p $DERBY_PORT
else
  echo "Could not start Derby Network server as Derby was not configured in centralConfiguration/deploy-repository.yaml."
fi
