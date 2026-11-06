#!/bin/bash
set -e
docker rm -f ztest >/dev/null 2>&1 || true
docker run -d --name ztest --hostname Zabbix --privileged zabbix:7.0
echo "Esperando 60 s a que arranquen los servicios..."; sleep 60
docker exec ztest zbx-status.sh
echo "== Prueba de Firefox (headless) =="
docker exec ztest bash -c "mkdir -p /tmp/ffp && firefox-esr --headless --no-remote --profile /tmp/ffp --screenshot /tmp/t.png http://127.0.0.1/zabbix/ >/dev/null 2>&1; ls -la /tmp/t.png"
docker cp ztest:/tmp/t.png ./zabbix-test.png && echo "Captura guardada en ./zabbix-test.png (debe mostrar el login de Zabbix)"
docker rm -f ztest >/dev/null
