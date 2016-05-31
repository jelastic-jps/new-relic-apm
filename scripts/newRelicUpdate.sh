#!/bin/bash
SERVER_LIBS_PATH=$1
SERVER_PATH="/opt/tomcat/"
LICENSE_KEY=$2
APP_NAME=$3
USER="tomcat"
NEWRELIC_ZIP="http://yum.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip"
VARIABLES_CONF="/opt/tomcat/conf/variables.conf"

[ -f "/etc/jelastic/environment" ] && source /etc/jelastic/environment

function performAction(){
    SERVER_LIBS_PATH=$1
    SERVER_PATH=$2
    VARIABLE_CONF=$3
    USER_LOCAL=$4
    TMP_DIR="/tmp/"
    
    rm -rf ${SERVER_LIBS_PATH}/newrelic/*.jar
    [ -n "${USER_LOCAL}" ] || USER_LOCAL="tomcat"

    curl -LfsS ${NEWRELIC_ZIP} -o ${TMP_DIR}newrelic.zip
    cd ${TMP_DIR}
    unzip ${TMP_DIR}newrelic.zip
    cp -r ${TMP_DIR}newrelic/*.jar ${SERVER_LIBS_PATH}/newrelic/
    chown ${USER_LOCAL}:${USER_LOCAL} ${SERVER_LIBS_PATH}newrelic/*
    rm -rf ${TMP_DIR}newrelic*
    exit 0;
}

[ -d "/opt/shared/smartfox" ] && echo "-javaagent:/opt/shared/smartfox/2X/SmartFoxServer_2X/SFS2X/lib/newrelic/newrelic.jar" >> /opt/shared/smartfox/2X/SmartFoxServer_2X/SFS2X/config/variables.conf && SERVER_LIB_PATH="/opt/shared/smartfox/2X/SmartFoxServer_2X/SFS2X/lib" && curl -LfsS "https://download.jelastic.com/public.php?service=files&t=daca831d32710933b9013349f6e64ce4&download" -o ${SERVER_LIBS_PATH}/newrelic.zip && exit 0;

if [ -d "/opt/jetty" ]; then
    performAction "/opt/jetty/lib/" "" "/opt/jetty/etc/variables.conf" "jetty"
fi

if [ "${Name}" == "jetty8" ]; then
    performAction "/opt/shared/libraries/lib/" "" "/opt/shared/conf/etc/variables.conf" #/opt/repo/versions/8.14
fi

if [ "${Name}" == "jetty9" ]; then
    performAction "/opt/shared/lib/" "" "/opt/shared/conf/etc/variables.conf" "jelastic"
fi

if [ "${Name}" == "jbossas" ]; then
    performAction "/opt/shared/modules/" "/opt/shared/bin/standalone.conf" "" "jelastic"
fi

grep cartridge /etc/jelastic/metainf.conf && SERVER_LIBS_PATH="/opt/shared/lib"
SERV_PATH=$(cat /etc/jelastic/metainf.conf | grep COMPUTE_TYPE= | cut -c 14-)
if [ -d "/opt/tomcat8" ]; then
    SERVER_PATH="/opt/repo/versions/8.0.9/"
    VARIABLES_CONF="/opt/shared/conf/variables.conf";
    USER="jelastic"
fi

performAction ${SERVER_LIBS_PATH}"/" ${SERVER_PATH} ${VARIABLES_CONF} ${USER}

grep cartridge /etc/jelastic/metainf.conf && chown jelastic:jelastic ${SERVER_LIBS_PATH}/newrelic || chown ${USER}:${USER} ${SERVER_LIBS_PATH}/newrelic;
grep cartridge /etc/jelastic/metainf.conf &&  chown jelastic:jelastic ${SERVER_LIBS_PATH}/newrelic/* || chown ${USER}:${USER} ${SERVER_LIBS_PATH}/newrelic/*;
