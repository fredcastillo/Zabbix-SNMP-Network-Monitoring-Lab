#!/bin/bash
set -e
IMAGE="${IMAGE:-zabbix:7.0-v1}"
CONTAINER="ztest-b1"

docker image inspect "$IMAGE" >/dev/null 2>&1 || {
    echo "No existe la imagen local: $IMAGE"
    echo "Descargue primero: docker pull fredcastillo/zabbix-server:7.0-v1"
    echo "O construya desde el Dockerfile: bash scripts/build-image.sh"
    exit 1
}

docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker run -d --name "$CONTAINER" --hostname Zabbix --privileged "$IMAGE"
echo "Esperando 60 segundos a que arranquen los servicios..."
sleep 60
docker exec "$CONTAINER" zbx-status.sh
echo "== Verificación de herramientas incluidas en V1 =="
docker exec "$CONTAINER" bash -lc 'command -v zbx-status.sh; command -v zbx-add-hosts.sh; if command -v zbx-export.sh >/dev/null 2>&1; then echo "ERROR: esta imagen no coincide con el inventario V1 esperado"; exit 1; else echo "OK: zbx-export.sh no forma parte de V1"; fi'
echo "== Prueba de Firefox headless =="
docker exec "$CONTAINER" bash -lc 'mkdir -p /tmp/ffp && firefox-esr --headless --no-remote --profile /tmp/ffp --screenshot /tmp/t.png http://127.0.0.1/zabbix/ >/dev/null 2>&1 && test -s /tmp/t.png && ls -lh /tmp/t.png'
docker cp "$CONTAINER:/tmp/t.png" ./zabbix-test-b1.png
echo "Captura guardada en ./zabbix-test-b1.png"
docker rm -f "$CONTAINER" >/dev/null
echo "Smoke test V1 completado. La persistencia propia de GNS3 debe validarse en el proyecto."
