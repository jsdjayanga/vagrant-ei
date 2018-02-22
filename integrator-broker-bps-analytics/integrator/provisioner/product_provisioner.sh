#!/usr/bin/env bash
# Copyright 2018 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# set variables
WSO2_SERVER=wso2ei
WSO2_SERVER_VERSION=6.1.1
WORKING_DIRECTORY=/home/vagrant
JAVA_HOME=/opt/java/
DEFAULT_MOUNT=/vagrant
CONFIGURATIONS=${DEFAULT_MOUNT}/integrator
WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}*.zip
MYSQL_CONNECTOR=mysql-connector-java-5.1.*-bin.jar
NODE_IP=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

# unpack the WSO2 product pack to the working directory
echo "Setting up the ${WSO2_SERVER}-${WSO2_SERVER_VERSION} server..."
if test ! -d ${WSO2_SERVER}-${WSO2_SERVER_VERSION}; then
  unzip -q ${WORKING_DIRECTORY}/${WSO2_SERVER_PACK} -d ${WORKING_DIRECTORY}
fi
echo "Successfully set up ${WSO2_SERVER}-${WSO2_SERVER_VERSION} server"

# add the MySQL driver
echo "Copying the MySQL driver to the server pack..."
cp ${WORKING_DIRECTORY}/${MYSQL_CONNECTOR} ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/lib/${MYSQL_CONNECTOR}
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the MySQL driver to the server pack."
else
  echo "Failed to copy the MySQL driver to the server pack."
fi

# copy files with configuration changes
echo "Copying the files with configuration changes to the server pack..."
cp -TRv ${CONFIGURATIONS}/conf/ ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/conf/
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the configuration files."
else
  echo "Failed to copy the configuration files"
fi

cp -TRv ${CONFIGURATIONS}/repository/deployment/server/ ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the deployment Server files."
else
  echo "Failed to copy the deployment Server files"
fi

cp -TRv ${CONFIGURATIONS}/repository/resources/security/ ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/resources/security/
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the deployment Security files."
else
  echo "Failed to copy the deployment Security files"
fi

echo "Copying ande-client.jar"
cp ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/broker/client-lib/andes-client-3.2.19.jar ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/lib/andes-client-3.2.19.jar
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the ande-client.jar to the server pack."
else
  echo "Failed to copy the ande-client.jar to the server pack."
fi

echo "Copying geronimo-jms_1.1_spec-1.1.0.wso2v1.jar"
cp ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/broker/client-lib/geronimo-jms_1.1_spec-1.1.0.wso2v1.jar ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/lib/geronimo-jms_1.1_spec-1.1.0.wso2v1.jar
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the geronimo-jms_1.1_spec-1.1.0.wso2v1 to the server pack."
else
  echo "Failed to copy the geronimo-jms_1.1_spec-1.1.0.wso2v1 to the server pack."
fi

echo "Copying org.wso2.securevault-1.0.0-wso2v2.jar"
cp ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/broker/client-lib/org.wso2.securevault-1.0.0-wso2v2.jar ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/lib/org.wso2.securevault-1.0.0-wso2v2.jar
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the org.wso2.securevault-1.0.0-wso2v2 to the server pack."
else
  echo "Failed to copy the org.wso2.securevault-1.0.0-wso2v2 to the server pack."
fi

export JAVA_HOME

# start the WSO2 product pack as a background service
echo "Starting ${WSO2_SERVER}-${WSO2_SERVER_VERSION}-integrator..."
sh ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/integrator.sh start

sleep 10

# tail the WSO2 product server startup logs until the server startup confirmation is logged
tail -f ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/logs/wso2carbon.log | while read LOG_LINE
do
  # echo each log line
  echo "${LOG_LINE}"
  # once the log line with WSO2 Carbon server start confirmation was logged, kill the started tail process
  [[ "${LOG_LINE}" == *"WSO2 Carbon started"* ]] && pkill tail
done

echo "Management console URL: https://${NODE_IP}:9443/carbon"