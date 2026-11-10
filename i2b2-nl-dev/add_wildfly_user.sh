#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="i2b2-core-server"
ADD_USER="/opt/jboss/wildfly/bin/add-user.sh"

docker exec -it "$CONTAINER_NAME" "$ADD_USER" # docker exec -it i2b2-core-server /opt/jboss/wildfly/bin/add-user.sh
