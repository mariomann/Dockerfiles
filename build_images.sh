#!/bin/bash

# for-loop iterating over all "Dockerfile_<Appserver>" files (e.g. Dockerfile_jboss, Dockerfile_tomcat,...) in the current directory
# each found app-server secific Dockerfile will be copied to a file called just Dockerfile
# then a Dockerimage is created for the current Dockerfile
for i in $( ls | grep -e "Dockerfile_*" );
    do
	# get name of current app-server (needed for tagging the Image)
	APP_SERVER=${i#*_}
	echo "\nBuilding Dockerfile for: $APP_SERVER"

	# copy the app-server specific Dockerfile (e.g. Dockerfile_jboss) to Dockerfile.
	# necessary, because Docker can only build images from files exactly called "Dockerfile"
        cp $i Dockerfile
	
        # build Docker-image
	echo Executing Command: docker build --tag=sbe/ticket-monster_$APP_SERVER:v$BUILD_NUMBER .
	docker build --tag=sbe/ticket-monster_$APP_SERVER:v$BUILD_NUMBER .
	# start Docker-container for current image
	echo Executing Command: docker run -d -P --name ticket-monster_$APP_SERVER\_v$BUILD_NUMBER sbe/ticket-monster_$APP_SERVER:v$BUILD_NUMBER
	docker run -d -P --name ticket-monster_$APP_SERVER\_v$BUILD_NUMBER sbe/ticket-monster_$APP_SERVER:v$BUILD_NUMBER
done

# cleanup the created Dockerfile
rm Dockerfile
