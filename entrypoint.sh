#!/bin/bash

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup : init database--"
    python /init_database.py
    echo 'init database finished!'
else
    echo "-- Not first container startup --"
fi
${DATAX_WEB_HOME}/bin/start-all.sh
echo 'datax-web started!'

tail -f /dev/null
