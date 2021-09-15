
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
if [ -f "$DEPLOYIT_SERVER_HOME/centralConfiguration/deploy-repository.yaml" ] ; then
  DERBY_PORT=`sed -n 's/.*:\([0-9]*\).*/\1/p' "$DEPLOYIT_SERVER_HOME/centralConfiguration/deploy-repository.yaml"`
fi
echo "XLD will attempt to stop the Derby Network Server on port '$DERBY_PORT'"
CLASSPATH=$(JARS=("$DEPLOYIT_SERVER_HOME/derbyns"/*.jar); IFS=:; echo "${JARS[*]}")
$JAVACMD -cp $CLASSPATH org.apache.derby.drda.NetworkServerControl shutdown -p $DERBY_PORT
