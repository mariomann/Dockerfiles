FROM progrium/busybox
MAINTAINER info.inspectit@novatec-gmbh.de

# adding fresh CMR version from Jenkins build
COPY inspectit-cmr.linux.x64.tar.gz /

RUN gunzip inspectit-cmr.linux.x64.tar.gz \
 && tar xfv inspectit-cmr.linux.x64.tar \
 && rm -f inspectit-cmr.linux.x64.tar.gz

WORKDIR /CMR

# exposing ports for REST-service and Agent connections
EXPOSE 8182 9070

# adding and executing startscript run.sh
COPY run.sh run.sh
CMD /bin/sh run.sh
