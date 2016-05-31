#!/bin/bash
SERVER_LIBS_PATH=$1
SERVER_PATH="/opt/tomcat/"
LICENSE_KEY=$2
APP_NAME=$3
USER="tomcat"
VARIABLES_CONF="/opt/tomcat/conf/variables.conf"

[ -f "/etc/jelastic/environment" ] && source /etc/jelastic/environment

function doRemoveAction() {
    SERVER_LIBS_PATH=$1
    VARIABLES_CONF=$2
    ONLY_SED=$3
    
    rm -rf ${SERVER_LIBS_PATH}/newrelic*
    if [ -n "${ONLY_SED}" ]; then
        sed -ri "s|jelastic-gc-agent.jar .*|jelastic-gc-agent.jar;|g" VARIABLES_CONF;
        exit 0;
    fi
    
    sed -ir "s|.*newrelic.*||g" ${VARIABLES_CONF}
    exit 0;
}

[ -d "/opt/shared/smartfox" ] && sed -ir "s|.*newrelic.*||g" /opt/shared/smartfox/2.x/SmartFoxServer_2X/SFS2X/config/variables.conf && sed -ir "s|.*-javaagent.*||g" /opt/shared/smartfox/2.x/SmartFoxServer_2X/SFS2X/config/variables.conf && SERVER_LIB_PATH="/opt/shared/smartfox/2.x/SmartFoxServer_2X/SFS2X/lib" && exit 0;

if [ -d "/opt/jetty" ]; then
    doRemoveAction "/opt/jetty/lib/" "/opt/jetty/etc/variables.conf" 
fi

if [ "${Name}" == "jetty8" ]; then
    doRemoveAction "/opt/shared/libraries/lib/" "/opt/shared/conf/etc/variables.conf"
fi

if [ "${Name}" == "jetty9" ]; then
    doRemoveAction "/opt/shared/lib/" "/opt/shared/conf/etc/variables.conf"
fi

if [ "${Name}" == "jbossas" ]; then
    doRemoveAction "/opt/shared/modules/" "/opt/shared/bin/standalone.conf" "ONLY_SED"
fi

grep cartridge /etc/jelastic/metainf.conf && SERVER_LIBS_PATH="/opt/shared/lib"

SERV_PATH=$(cat /etc/jelastic/metainf.conf | grep COMPUTE_TYPE= | cut -c 14-)
[ -d "/opt/tomcat8" ] && SERVER_PATH="/opt/repo/versions/8.0.9/" && VARIABLES_CONF="/opt/shared/conf/variables.conf"

doRemoveAction ${SERVER_LIBS_PATH} ${VARIABLES_CONF}