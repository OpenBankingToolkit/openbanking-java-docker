#!/bin/bash

set -euo pipefail

DEFAULT_CONFIG_SERVER="http://config:8888"

# Default to http://config:8888 if no spring.cloud.config.uri is defined
CONFIG_SERVER=${spring_cloud_config_uri:-${DEFAULT_CONFIG_SERVER}}

# default to system hostname if spring_hostname is not defined
SPRING_HOSTNAME=${spring_hostname:-${HOSTNAME}}

IP_AS_SPRING_HOSTNAME=${ip_as_spring_hostname:-"!"}


OVERRIDE_KEYSTORE=${override_keystore_path:-"!"}

JAR_NAME=$(ls *.jar)
SVC=$(</opt/ob/SERVICE)

function logMessage {
    echo "$(date +%Y-%m-%d\ %H:%M:%S).000 INFO [${SVC},,,] 00 --- [script] script : $*"
}

logMessage "Starting sbootwait.sh..."
echo '
 
 #####################################################################
 _____ ____  ____  _____ _____ ____  ____  ____  _  __
/    //  _ \/  __\/  __//  __//  __\/  _ \/   _\/ |/ /
|  __\| / \||  \/|| |  _|  \  |  \/|| / \||  /  |   / 
| |   | \_/||    /| |_//|  /_ |    /| \_/||  \__|   \ 
\_/   \____/\_/\_\\____\\____\\_/\_\\____/\____/\_|\_\
                                                      
'
echo "
      service: ${SVC}
      jar name: ${JAR_NAME}
      config server: ${CONFIG_SERVER}

"

if [ -f /etc/ssl/certs/java/keystore.jks ]; then
    logMessage "keystore found, moving to working directory..."
    cp /etc/ssl/certs/java/keystore.jks /opt/ob/config
fi

logMessage "bootstrap.properties:"
echo "
"
cat /opt/ob/bootstrap.properties
echo "
"

export JAVA_OPTS="${java_opts:-"-Xmx256m -XX:+UseConcMarkSweepGC"}"

if [[ ${IP_AS_SPRING_HOSTNAME} == "true" ]]; then
    logMessage "setting IP address as spring hostname..."
    SPRING_HOSTNAME=$(hostname -i)
fi

if [[ ${SVC} == jwkms ]]; then
    logMessage "JWKMS: Checking for existing JWK store..."
    if [ -f  /etc/ssl/certs/java/jwksstore.pfx ]; then
        logMessage "JWKMS: Adding JWK store..."
        cp /etc/ssl/certs/java/jwksstore.pfx /opt/ob
    fi

fi

if [[ ${SVC} != config ]]; then
    export JAVA_OPTS="${JAVA_OPTS} -Dspring.cloud.config.uri=${CONFIG_SERVER}" 
    export JAVA_OPTS="${JAVA_OPTS} -Dserver.internal.hostname=${SPRING_HOSTNAME}"     
fi

if [ ${OVERRIDE_KEYSTORE} != "!" ]; then
    export JAVA_OPTS="${JAVA_OPTS} -Dserver.ssl.keystore=${OVERRIDE_KEYSTORE}"
fi

logMessage "JAVA_OPTS:
 ${JAVA_OPTS}
"

# unset all env variables with _PORT
while read var; do unset $var; done < <(env | grep _PORT | awk -F= '{print $1}')

java ${JAVA_OPTS} -jar /opt/ob/${JAR_NAME}

exit 0
