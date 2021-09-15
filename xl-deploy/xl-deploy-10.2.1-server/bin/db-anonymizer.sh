#!/bin/sh
#
# Shell script to export the XLD Database
#

absdirname ()
{
  _dir="`dirname \"$1\"`"
  cd "$_dir"
  echo "`pwd`"
}

resolvelink() {
  _dir=`dirname "$1"`
  _dest=`readlink "$1"`
  case "$_dest" in
  /* ) echo "$_dest" ;;
  *  ) echo "$_dir/$_dest" ;;
  esac
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

wrapper_conf_file=$DEPLOYIT_SERVER_HOME/conf/xld-wrapper.conf.common

# Build XLD classpath
classpath_dirs=`sed -n 's/^wrapper.java.classpath.\([0-9]*\)=\(.*[^*]\)$/\2/p' "$wrapper_conf_file" | tr '\n' ':'`
classpath_dirs=`echo $classpath_dirs | sed 's/.$//'`

DEPLOYIT_SERVER_CLASSPATH="${classpath_dirs}"

all_files_to_list=`sed -n 's/^wrapper.java.classpath.\([0-9]*\)=\(.*\)\/\*$/\2 /p' "$wrapper_conf_file" | tr '\n' ' '`
all_files_to_list="$all_files_to_list -name '*.jar'"
all_files=`echo $all_files_to_list | xargs find`
for each in $all_files
do
  if [ -f $each ]; then
    case "$each" in
      *.jar)
        DEPLOYIT_SERVER_CLASSPATH=${DEPLOYIT_SERVER_CLASSPATH}:${each}
        ;;
    esac
  fi
done

ANONYMIZER_EXTRA_OPTS="-DentityExpansionLimit=0 -DtotalEntitySizeLimit=0 -Djdk.xml.totalEntitySizeLimit=0"

BOOTSTRAPPER="com.xebialabs.database.anonymizer.AnonymizerBootstrapper"

# Run XLD Database export
$JAVACMD -Dfile.encoding=UTF-8 $ANONYMIZER_OPTS $ANONYMIZER_EXTRA_OPTS -classpath "${DEPLOYIT_SERVER_CLASSPATH}" $BOOTSTRAPPER "$@"
