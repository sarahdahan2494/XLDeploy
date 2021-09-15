#!/bin/sh
#
# Shell script to install XL Deploy Server as a daemon
#

DIR=$( cd "$( dirname "$0" )" && pwd )
. "$DIR"/.wrapper-env.sh

user=""
export user

conf_file="$xldeploy_home"/conf/xld-wrapper-server.conf
export template_postfix=""
if [ "$1" = "worker" ]; then
    conf_file="$xldeploy_home"/conf/xld-wrapper-worker.conf
    export template_postfix=".generated-for-worker"
fi

# stop and uninstall daemon/ service
"$java_exe" $wrapper_java_options "$wrapper_java_sys_options" -jar "$wrapper_jar" -p "$conf_file"
"$java_exe" $wrapper_java_options "$wrapper_java_sys_options" -jar "$wrapper_jar" -r "$conf_file"
