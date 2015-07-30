FROM progrium/busybox

MAINTAINER info.inspectit@novatec-gmbh.de

#ENV INSPECTIT_VERSION 1.6.2.65
#RUN wget ftp://ftp.novatec-gmbh.de/inspectit/releases/RELEASE.${INSPECTIT_VERSION}/inspectit-cmr.linux.x64.tar.gz -qO - | gunzip | tar xvf - 

#ADD /var/lib/jenkins/workspace/build_inspectIT/CMR/release/inspectit-cmr.linux.x64.tar.gz /CMR/
ADD inspectit-cmr.linux.x64.tar.gz /
WORKDIR /CMR

VOLUME ["config", "db", "storage", "ci"]

EXPOSE 8182 9070

COPY run.sh run.sh
CMD /bin/sh run.sh
