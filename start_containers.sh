#!/bin/bash

IMAGE_VERSION=v${BUILD_NUMBER}
HOST_HTTP_PORT=6780
DOCKER_ID=inspectit-dev

# DEBUG
echo -e "\ngesetzte Variablen:\n BUILD_NUMBER: ${BUILD_NUMBER}\n IMAGE_VERSION: ${IMAGE_VERSION}\n WORKSPACE: ${WORKSPACE}\n "

# start cmr container
echo -e "\nStarting CMR-Container"
docker run -d -p 8182:8182 --name cmr_jenkins_build ${DOCKER_ID}/cmr:${IMAGE_VERSION}

sleep 20

# LOOP
# start App Server Containers and run tests
for IMAGE in $(docker images | grep ${DOCKER_ID}/hello2.*${IMAGE_VERSION} | awk '{print $1}');
# sample output: myinspectit/hello2_jetty
do
	APP_SERVER=${IMAGE#*_}

	echo -e "\n\nStarting ${APP_SERVER}-Container: docker run -d --name ${APP_SERVER}_jenkins_build -p ${HOST_HTTP_PORT}:8080 --link cmr_jenkins_build:cmr ${IMAGE}:${IMAGE_VERSION}"
	docker run -d --name ${APP_SERVER}_jenkins_build -p ${HOST_HTTP_PORT}:8080 -h ${APP_SERVER} --link cmr_jenkins_build:cmr ${IMAGE}:${IMAGE_VERSION}

	echo -e "\nWaiting 45 Seconds for ${APP_SERVER}-Container to start before launching JMeter Tests"
	sleep 45
	
	(curl -s http://localhost:${HOST_HTTP_PORT}/hello2/greeting?username=Simon | grep -i Simon >/dev/null ) || exit 1
	(curl -s http://localhost:${HOST_HTTP_PORT}/hello2/greeting?username=APM | grep -i APM >/dev/null ) || exit 1
	(curl -s http://localhost:${HOST_HTTP_PORT}/hello2/greeting?username=Novatec | grep -i Novatec >/dev/null ) || exit 1
	
	#echo -e "Tests executed"
	#echo -e "\nStopping ${APP_SERVER}-Container"
	#docker stop ${APP_SERVER}_jenkins_build
	#echo -e "Removing ${APP_SERVER}-Container"
	#docker rm ${APP_SERVER}_jenkins_build

	((HOST_HTTP_PORT++))
done

# stop and remove cmr container
#echo -e "\nStopping CMR-Container"
#docker stop cmr_jenkins_build
#echo -e "Removing CMR-Container"
#docker rm cmr_jenkins_build
