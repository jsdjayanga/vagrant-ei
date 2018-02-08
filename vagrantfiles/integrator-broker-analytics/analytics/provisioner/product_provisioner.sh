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
CONFIGURATIONS=${DEFAULT_MOUNT}/analytics
NODE_IP=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

# copy files with configuration changes
echo "Copying the files with configuration changes to the server pack..."

cp -TRv ${CONFIGURATIONS}/conf/ ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/analytics/conf/
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the configuration files."
else
  echo "Failed to copy the configuration files"
fi

cp -TRv ${CONFIGURATIONS}/repository/resources/security/ ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/analytics/repository/resources/security/
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the deployment Security files."
else
  echo "Failed to copy the deployment Security files"
fi

export JAVA_HOME

# start the WSO2 product pack as a background service
echo "Starting ${WSO2_SERVER}-${WSO2_SERVER_VERSION}-analytics..."
sh ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/analytics/bin/wso2server.sh start

sleep 10

# tail the WSO2 product server startup logs until the server startup confirmation is logged
tail -f ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/analytics/repository/logs/wso2carbon.log | while read LOG_LINE
do
  # echo each log line
  echo "${LOG_LINE}"
  # once the log line with WSO2 Carbon server start confirmation was logged, kill the started tail process
  [[ "${LOG_LINE}" == *"WSO2 Carbon started"* ]] && pkill tail
done

echo "Management console URL: https://${NODE_IP}:9444/carbon"