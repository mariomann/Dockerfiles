#!/bin/bash


# This script builds Docker Images for the inspectIT CMR and several App-Servers including the inspectIT Agent
# Furthermore JMeter-tests are created from TEMPLATES

# Hostport which will be mapped to the port 8080 inside the created containers (incremented in loop)
HOST_HTTP_PORT=6780

# build inspectIT CMR container
cd inspectIT/cmr/
echo -e "\nBuilding inspectIT CMR container"
docker build --tag=myinspectit/cmr:v$BUILD_NUMBER .
# ggf anpassen in cd $WORKSPACE (Jenkins Variable), Besser noch die cds kommplett weglassen un den docker build mit inspectIT/cmr/... durchführen wenn möglich
cd ${WORKSPACE}


# for-loop iterating over all "Dockerfile_<Appserver>" files (e.g. Dockerfile_jboss, Dockerfile_tomcat,...) in the Jenkins workspace
# each found app-server specific Dockerfile will be copied to a file called just Dockerfile
# then a Dockerimage is created for the current Dockerfile and the image is added to a docker-compose.yml file
for i in $( ls | grep Dockerfile_ );
    do
	# get name of current app-server (needed for tagging the Image)
	APP_SERVER=${i#*_}
	echo -e "\nBuilding $APP_SERVER container with integrated inspectIT Agent"

	# copy the app-server specific Dockerfile (e.g. Dockerfile_jboss) to Dockerfile.
	# necessary, because Docker can only build images from files exactly called "Dockerfile"
        cp $i Dockerfile
	
        # build Docker-image
	echo Executing Command: docker build --tag=myinspectit/hello2_$APP_SERVER:v$BUILD_NUMBER .
	docker build --tag=myinspectit/hello2_$APP_SERVER:v$BUILD_NUMBER .

	# create JMeter test for each app-server from Template
        cp jmeter-tests/TEMPLATE_http.jmx jmeter-tests/http-requests_${APP_SERVER}.jmx
        sed -i -- "s/containerHostname/${APP_SERVER}/g" jmeter-tests/http-requests_${APP_SERVER}.jmx
        
        cp jmeter-tests/TEMPLATE_rest.jmx jmeter-tests/restcall_${APP_SERVER}.jmx
	sed -i -- "s/APP_SERVER/${APP_SERVER}/g" jmeter-tests/restcall_${APP_SERVER}.jmx

	((HOST_HTTP_PORT++))

done

# build JMeter container
#echo -e "\nBuilding JMeter container"
#cp JMeter_Dockerfile Dockerfile
#docker build --tag=myinspectit/jmeter:v$BUILD_NUMBER .

# cleanup the created Dockerfile
rm Dockerfile



