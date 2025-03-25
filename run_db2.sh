#!/bin/bash

DOCKER=podman

$DOCKER run -d \
    --name db2_container \
    --privileged \
    -p 50000:50000 \
    -v "./database:/database" \
    -e LICENSE=accept \
    -e DB2INSTANCE=db2inst1 \
    -e DB2INST1_PASSWORD=secret \
    -e DBNAME=testdb \
    -e BLU=false \
    -e ENABLE_ORACLE_COMPATIBILITY=false \
    -e UPDATEAVAIL=NO \
    -e TO_CREATE_SAMPLEDB=true \
    -e REPODB=false \
    -e IS_OSXFS=false \
    -e PERSISTENT_HOME=true \
    -e HADR_ENABLED=false \
    icr.io/db2_community/db2:11.5.8.0
