#!/bin/bash

IMAGE_VERSION=v${BUILD_NUMBER}
HOST_HTTP_PORT=6780


# DEBUG
echo -e "\ngesetzte Variablen:\n BUILD_NUMBER: ${BUILD_NUMBER}\n IMAGE_VERSION: ${IMAGE_VERSION}\n WORKSPACE: ${WORKSPACE}\n "

# start cmr container
echo -e "\nStarting CMR-Container"
docker run -d -p 8182:8182 --name cmr_sc myinspectit/cmr:${IMAGE_VERSION}

# LOOP
# start App Server Containers and run tests
for IMAGE in $(docker images | grep myinspectit/hello2.*${IMAGE_VERSION} | awk '{print $1}');
# sample output: myinspectit/hello2_jetty
do
	APP_SERVER=${IMAGE#*_}

	echo -e "\n\nStarting ${APP_SERVER}-Container"
	docker run -d --name ${APP_SERVER}_sc -p ${HOST_HTTP_PORT}:8080 --link cmr_sc:cmr ${IMAGE}:${IMAGE_VERSION}

	echo -e "\nWaiting 45 Seconds for ${APP_SERVER}-Container to start before launching JMeter Tests"
	sleep 45

	echo -e "\nStarting JMeter Container to execute Tests"
	docker run --rm --name jmeter_sc -v ${WORKSPACE}/jmeter-tests/:/jmeter-tests/ --link ${APP_SERVER}_sc:${APP_SERVER} --link cmr_sc:cmr -e "APP_SERVER=${APP_SERVER}" sbe/jmeter:run-test-instantly
	echo -e "Tests executed"
	echo -e "\nStopping ${APP_SERVER}-Container"
	docker stop ${APP_SERVER}_sc
	echo -e "Removing ${APP_SERVER}-Container"
	docker rm ${APP_SERVER}_sc

	((HOST_HTTP_PORT++))
done

# stop and remove cmr container
echo -e "\nStopping CMR-Container"
docker stop cmr_sc
echo -e "Removing CMR-Container"
docker rm cmr_sc
