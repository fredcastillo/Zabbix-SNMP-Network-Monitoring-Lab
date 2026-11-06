#!/bin/bash
set -e
cd "$(dirname "$0")/../docker/Zabbix"
docker build -t zabbix:7.0-v1 .
docker images zabbix
