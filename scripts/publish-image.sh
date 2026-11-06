#!/bin/bash
set -euo pipefail
SOURCE_IMAGE="${SOURCE_IMAGE:-zabbix:7.0-v1}"
TARGET_REPO="fredcastillo/zabbix-server"
VERSION_TAG="7.0-v1"

if ! docker image inspect "$SOURCE_IMAGE" >/dev/null 2>&1; then
    echo "No existe la imagen local '$SOURCE_IMAGE'."
    echo "Descargue la V1 publicada o constrúyala desde scripts/build-image.sh."
    exit 1
fi

echo "Se publicará la imagen local $SOURCE_IMAGE como:"
echo "  $TARGET_REPO:$VERSION_TAG"
echo "  $TARGET_REPO:latest"
read -r -p "Escriba PUBLISH para confirmar: " CONFIRM
if [[ "$CONFIRM" != "PUBLISH" ]]; then
    echo "Publicación cancelada."
    exit 1
fi

docker tag "$SOURCE_IMAGE" "$TARGET_REPO:$VERSION_TAG"
docker tag "$SOURCE_IMAGE" "$TARGET_REPO:latest"
docker push "$TARGET_REPO:$VERSION_TAG"
docker push "$TARGET_REPO:latest"
echo "Publicación V1 finalizada. Ambas etiquetas apuntan a la misma imagen."
