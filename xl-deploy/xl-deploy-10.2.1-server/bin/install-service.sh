#!/bin/sh
#
# Shell script to install XL Deploy Server as a daemon
#

DIR=$( cd "$( dirname "$0" )" && pwd )
. "$DIR"/.wrapper-env.sh

if [ ! -f "conf/deployit-license.lic" ]; then
    echo "A license is required in order to be able to install the XL Deploy Server as a daemon."
    exit 1
fi

if [ ! -f "conf/deployit.conf" ]; then
    echo "The XL Deploy server is not initialized. Please execute the run.sh script!"
    exit 1
fi

read -p "Please provide the user that will run XL Deploy: " user
export user

conf_file="$xldeploy_home"/conf/xld-wrapper-server.conf
export template_postfix=""
if [ "$1" = "worker" ]; then
    conf_file="$xldeploy_home"/conf/xld-wrapper-worker.conf
    if [ -z "$2" ]; then
    read -p "Please provide the connection details for the XL Deploy master (HOST:PORT): " master
    read -p "Please provide the URL for the REST api: " restapi

    elif [ 0 -gt  $(echo "$@" | tr " " "\n" | grep -c "\-master") ]; then
    	   echo please provide the master
       	 exit 1
    else
       	for i in $@; do
            if [ $i = "-api" ]; then
                shift
                restapi=$1
            elif [ $i = "-master" ]; then
                shift
                if [ -z "$master" ] ;then
                    master=$master$1
               	else
               	    master=$master"_"$1
               	fi
            else
               shift
	    fi
	 done
   fi
   export master=$master
   export restapi=$restapi

    # ensure `$master` and `$restapi` switches get retained across `service xl-deploy-worker start|stop`
    _env=$(which env)
    _worker_args="master=$master restapi=$restapi"
    export template_postfix=".generated-for-worker"
    sed -e "s%w_start_cmd_modified=\\\"\\\"%w_start_cmd_modified=\\\"$_env $_worker_args\\\"%g" conf/wrapper-daemon.vm > conf/wrapper-daemon.vm$template_postfix
fi

# install daemon/ service
"$java_exe" "$wrapper_java_options" "$wrapper_java_sys_options" -jar "$wrapper_jar" -i "$conf_file"
"$java_exe" "$wrapper_java_options" "$wrapper_java_sys_options" -jar "$wrapper_jar" -t "$conf_file"


echo ""
echo "Please make sure the server is configured so that it can start without input from the user"
echo "(e.g. if a repository keystore password is required then it should be provided in deployit.conf)."
