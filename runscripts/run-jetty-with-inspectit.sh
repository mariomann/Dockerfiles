#!/bin/bash
	
CMR_ADDR=${INSPECTIT_CMR_ADDR:-cmr}
CMR_PORT=${INSPECTIT_CMR_PORT:-9070}

AGENT_NAME=${AGENT_NAME:-$HOSTNAME}
sed -i "s/^\(repository\) .*/\1 $CMR_ADDR $CMR_PORT $AGENT_NAME/" $INSPECTIT_CONFIG_HOME/inspectit-agent.cfg
echo "Done. Remember to modify the configuration for your needs. You find the configuration in the mapped volume $INSPECTIT_CONFIG_HOME." 

exec jetty.sh run
