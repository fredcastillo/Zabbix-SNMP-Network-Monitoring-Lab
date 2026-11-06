#!/bin/bash
set -e
if [ -z "$1" ]; then
    echo "Uso: $0 USUARIO_DOCKERHUB"
    exit 1
fi
docker tag zabbix:7.0 "$1/zabbix:7.0"
docker tag zabbix:7.0 "$1/zabbix:latest"
docker push "$1/zabbix:7.0"
docker push "$1/zabbix:latest"
