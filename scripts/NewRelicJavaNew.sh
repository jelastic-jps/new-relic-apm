#!/bin/bash
SERVER_LIBS_PATH=$1
SERVER_PATH="/opt/tomcat/"
LICENSE_KEY=$2
APP_NAME=$3
USER="tomcat"
NEWRELIC_ZIP="https://download.jelastic.com/public.php?service=files&t=624c58fe3c9419e312552cc89d065fbe&download"
VARIABLES_CONF="/opt/tomcat/conf/variables.conf"

[ -f "/etc/jelastic/environment" ] && source /etc/jelastic/environment

function performAction(){
    SERVER_LIBS_PATH=$1
    SERVER_PATH=$2
    VARIABLE_CONF=$3
    USER_LOCAL=$4
    [ -n "${USER_LOCAL}" ] || USER_LOCAL="tomcat"

    curl -fLsS ${NEWRELIC_ZIP} -o ${SERVER_LIBS_PATH}/newrelic.zip
    cd ${SERVER_LIBS_PATH}
    unzip ${SERVER_LIBS_PATH}newrelic.zip
    chown ${USER_LOCAL}:${USER_LOCAL} ${SERVER_LIBS_PATH}newrelic
    chown ${USER_LOCAL}:${USER_LOCAL} ${SERVER_LIBS_PATH}newrelic/*
    sed -ri "s|LICENSE_KEY|${LICENSE_KEY}|g" ${SERVER_LIBS_PATH}newrelic/newrelic.yml;
    sed -ri "s|APP_NAME|${APP_NAME}|g" ${SERVER_LIBS_PATH}newrelic/newrelic.yml;
    
    if [ -n "${SERVER_PATH}" ]; then
        sed -ri "s|jelastic-gc-agent.jar|jelastic-gc-agent.jar -Djavaagent:${SERVER_LIBS_PATH}newrelic/newrelic.jar|g" ${VARIABLES_CONF}
        exit 0;
    fi
    grep -q "newrelic.jar" ${VARIABLE_CONF} || echo "-javaagent:"${SERVER_LIBS_PATH}"newrelic/newrelic.jar" >> ${VARIABLE_CONF} #/opt/shared/conf/etc/variables.conf
    [ -n "$3" ] && exit 0;
}

[ -d "/opt/shared/smartfox" ] && echo "-javaagent:/opt/shared/smartfox/2X/SmartFoxServer_2X/SFS2X/lib/newrelic/newrelic.jar" >> /opt/shared/smartfox/2X/SmartFoxServer_2X/SFS2X/config/variables.conf && SERVER_LIB_PATH="/opt/shared/smartfox/2X/SmartFoxServer_2X/SFS2X/lib" && curl -LfsS "https://download.jelastic.com/public.php?service=files&t=daca831d32710933b9013349f6e64ce4&download" -o ${SERVER_LIBS_PATH}/newrelic.zip && exit 0;

if [ -d "/opt/jetty" ]; then
    performAction "/opt/jetty/lib/" "" "/opt/jetty/etc/variables.conf" "jetty"
fi

if [ "${Name}" == "jetty8" ]; then
    performAction "/opt/shared/libraries/lib/" "" "/opt/shared/conf/etc/variables.conf" "jelastic" #/opt/repo/versions/8.14
fi

if [ "${Name}" == "jetty9" ]; then
    performAction "/opt/shared/lib/" "" "/opt/shared/conf/etc/variables.conf" "jelastic"
fi

if [ "${Name}" == "jbossas" ]; then
    performAction "/opt/shared/modules/" "/opt/shared/bin/standalone.conf" "/opt/shared/bin/standalone.conf" "jelastic"
fi

grep cartridge /etc/jelastic/metainf.conf && SERVER_LIBS_PATH="/opt/shared/lib"

SERV_PATH=$(cat /etc/jelastic/metainf.conf | grep COMPUTE_TYPE= | cut -c 14-)
[ -d "/opt/tomcat8" ] && SERVER_PATH="/opt/repo/versions/8.0.9/" && VARIABLES_CONF="/opt/shared/conf/variables.conf" && USER="jelastic";

performAction ${SERVER_LIBS_PATH}"/" "" ${VARIABLES_CONF} ${USER}

grep cartridge /etc/jelastic/metainf.conf && chown jelastic:jelastic ${SERVER_LIBS_PATH}/newrelic || chown ${USER}:${USER} ${SERVER_LIBS_PATH}/newrelic;
grep cartridge /etc/jelastic/metainf.conf &&  chown jelastic:jelastic ${SERVER_LIBS_PATH}/newrelic/* || chown ${USER}:${USER} ${SERVER_LIBS_PATH}/newrelic/*;
