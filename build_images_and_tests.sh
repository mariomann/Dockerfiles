#!/bin/bash

DOCKER_ID=inspectit-dev

# This script builds Docker Images for the inspectIT CMR and several App-Servers including the inspectIT Agent
# Furthermore JMeter-tests are created from TEMPLATES

# build inspectIT CMR container
echo -e "\nBuilding Docker Image for inspectIT CMR"
docker build --tag=${DOCKER_ID}/cmr:v$BUILD_NUMBER inspectIT/cmr/

# for-loop iterating over all "Dockerfile_<Appserver>" files (e.g. Dockerfile_jboss, Dockerfile_tomcat,...) in the Jenkins workspace
# each found app-server specific Dockerfile will be copied to a file called just Dockerfile
# then a Docker Image tagged with the Jenkins Buildnumber is created for the current Dockerfile
for i in $( ls | grep Dockerfile_ );
    do
	# get name of current app-server (needed for tagging the Image)
	APP_SERVER=${i#*_}
	echo -e "\nBuilding Docker Image for $APP_SERVER with integrated inspectIT Agent"

	# copy the app-server specific Dockerfile (e.g. Dockerfile_jboss) to Dockerfile.
	# necessary, because Docker can only build images from files exactly called "Dockerfile"
        cp $i Dockerfile
	
        # build Docker-image
	echo Executing Command: docker build --tag=${DOCKER_ID}/hello2_$APP_SERVER:v$BUILD_NUMBER .
	docker build --tag=${DOCKER_ID}/hello2_$APP_SERVER:v$BUILD_NUMBER .

	# cleanup the created Dockerfile
	rm Dockerfile

	# create JMeter http-test for each app-server from Template
        cp jmeter-tests/TEMPLATE_http.jmx jmeter-tests/http-requests_${APP_SERVER}.jmx
        sed -i -- "s/containerHostname/${APP_SERVER}/g" jmeter-tests/http-requests_${APP_SERVER}.jmx
        
	# create JMeter REST-test for each app-server from Template
        cp jmeter-tests/TEMPLATE_rest.jmx jmeter-tests/restcall_${APP_SERVER}.jmx
	sed -i -- "s/insertAppServerNameHere/${APP_SERVER}/g" jmeter-tests/restcall_${APP_SERVER}.jmx
done
