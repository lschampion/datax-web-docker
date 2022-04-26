#!/bin/bash

database_config=$DATAX_WEB_HOME/modules/datax-admin/conf/bootstrap.properties
db_host=$HOST
db_port=${PORT:-3306}
db_username=$USERNAME
db_password=$PASSWORD
db_database=$DATABASE

CONTAINER_ALREADY_STARTED=/CONTAINER_ALREADY_STARTED_PLACEHOLDER
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
  echo "-- First container startup : init database--"
  touch $CONTAINER_ALREADY_STARTED
  if [ -n "$db_host" ]&&[ -n "$db_port" ]&&[ -n "$db_username" ]&&[ -n "$db_password" ]; then
    sed -i "s/db_host/$db_host/g" $database_config
    sed -i "s/db_port/$db_port/g" $database_config
    sed -i "s/db_username/$db_username/g" $database_config
    sed -i "s/db_password/$db_password/g" $database_config
    sed -i "s/db_database/dataxweb/g" $database_config
    python /init_database.py --host $db_host --port $db_port --username $db_username --password $db_password --database $db_database > /init_database.log
  fi
  echo 'init database finished!'
else
  echo "-- Not first container startup --"
fi

${DATAX_WEB_HOME}/bin/start-all.sh
echo 'datax-web started!'

tail -f /dev/null
