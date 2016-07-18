FROM jboss/wildfly
MAINTAINER sbecke46@web.de

# Add User "admin" with pw "Admin#007" to acces the Webinterface
RUN /opt/jboss/wildfly/bin/add-user.sh admin Admin#007 --silent

# Deployment of App fails, if not root
USER root

ADD ticket-monster.war /opt/jboss/wildfly/standalone/deployments/

EXPOSE 8080 9990

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

