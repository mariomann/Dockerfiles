#!/bin/bash

DOCKER_ID=inspectit-dev

# This script builds Docker Images for the inspectIT CMR and several App-Servers including the inspectIT Agent
# Furthermore JMeter-tests are created from TEMPLATES

# build inspectIT CMR container
sed -i "s/^RUN wget https:\/\/github\.com.*/ADD inspectit-cmr.linux.x64.tar.gz . \nRUN echo inspectit \\\ /" ./cmr/Dockerfile

# echo -e "\nBuilding Docker Image for inspectIT CMR"
docker build --tag=${DOCKER_ID}/cmr:v$BUILD_NUMBER ./cmr/

# for-loop iterating over all "Dockerfile_<Appserver>" files (e.g. Dockerfile_jboss, Dockerfile_tomcat,...) in the Jenkins workspace
# each found app-server specific Dockerfile will be copied to a file called just Dockerfile
# then a Docker Image tagged with the Jenkins Buildnumber is created for the current Dockerfile

for dockerfile in `find . -name Dockerfile -not -path "./cmr*" -type f`;
do

  # change RUN to ADD built inspectit-agent
  sed -i "s/^RUN wget https:\/\/github\.com.*/ADD inspectit-agent-sun1.5.zip . \nRUN echo inspectit \\\ /" ${dockerfile}

  DOCKERFILE_PATH=`dirname ${dockerfile}`

  # get name of current app-server (needed for tagging the Image)
	APP_SERVER=`echo ${DOCKERFILE_PATH} | sed 's/\//_/g'`
	echo -e "\nBuilding Docker Image for ${APP_SERVER} with new built inspectIT Agent"

  # build Docker-image
	echo Executing Command: docker build --tag=${DOCKER_ID}/hello2_${APP_SERVER}:v${BUILD_NUMBER} ${DOCKERFILE_PATH}
	docker build --tag=${DOCKER_ID}/hello2_${APP_SERVER}:v${BUILD_NUMBER} ${DOCKERFILE_PATH}

	# cleanup the created Dockerfile
	# rm Dockerfile
done
