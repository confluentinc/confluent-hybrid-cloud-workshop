#! /bin/bash

docker exec -it ksqldb-cli ksql --file /tmp/commands.sql http://ksqldb-server-ccloud:8088