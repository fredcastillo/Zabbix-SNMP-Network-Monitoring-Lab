# Zabbix 7.0 LTS para GNS3 — V1

Imagen Docker personalizada para utilizar Zabbix como nodo dentro de GNS3. Esta documentación corresponde a la versión publicada y utilizada en la práctica A2: **`fredcastillo/zabbix-server:7.0-v1`**.

## Imagen publicada

- Docker Hub: https://hub.docker.com/r/fredcastillo/zabbix-server
- Tag de la práctica: `fredcastillo/zabbix-server:7.0-v1`
- Alias publicado: `fredcastillo/zabbix-server:latest` (apunta a la misma V1)
- Pull: `docker pull fredcastillo/zabbix-server:7.0-v1`

No se documentan aquí revisiones posteriores. La V1 no incluye el script `zbx-export.sh`.

## Componentes incluidos

- Zabbix Server 7.0 LTS y Zabbix Agent 2.
- MariaDB con el esquema inicial de Zabbix.
- Apache y PHP para el frontend.
- Firefox ESR y Openbox para la consola VNC de GNS3.
- Cliente DHCP (`dhclient`) para `eth0`.
- Herramientas de red y SNMP: `snmpget`, `snmpwalk`, `snmpset`, `ping`, `traceroute`, `tcpdump`, `iproute2` y `zabbix_get`.
- Scripts del contenedor: `zbx-status.sh` y `zbx-add-hosts.sh`.

## Descargar la imagen

```bash
docker pull fredcastillo/zabbix-server:7.0-v1
```

## Construir la imagen desde este código fuente

Desde la raíz del repositorio, en un host Docker Linux compatible:

```bash
bash scripts/build-image.sh
```

El script construye la etiqueta local `zabbix:7.0-v1`. La construcción desde un Dockerfile no garantiza un digest idéntico al de una imagen ya publicada, porque las capas base y los paquetes de los repositorios pueden cambiar con el tiempo. Para utilizar exactamente el artefacto publicado de la práctica, descarga el tag de Docker Hub.

## Probar la imagen

```bash
bash scripts/test-container.sh
```

La prueba comprueba el arranque de los servicios, la respuesta HTTP del frontend y la consola gráfica en modo headless. La persistencia real debe validarse además cerrando y reabriendo el proyecto GNS3.

## Plantilla Docker en GNS3

| Campo | Valor |
|---|---|
| Name | `Zabbix` |
| Image | `fredcastillo/zabbix-server:7.0-v1` |
| Adapters | `1` |
| Console type | `vnc` |
| Console resolution | `1280x800` |
| Additional persistent directories | `/var/lib/mysql` (**obligatorio**) |

GNS3 VM necesita acceso a Internet para descargar la imagen si no está almacenada localmente.

## Persistencia

Agrega `/var/lib/mysql` en **Additional persistent directories** de la plantilla Docker. Sin este montaje, los usuarios, hosts, plantillas, macros e historial almacenados en MariaDB pueden perderse al cerrar el proyecto.

Guía: [PERSISTENCIA.md](PERSISTENCIA.md).

## Acceso inicial

- Frontend: Firefox abre `http://127.0.0.1/zabbix/` dentro de la consola VNC.
- Usuario inicial: `Admin`.
- Contraseña inicial: `zabbix`.
- MariaDB local: usuario `zabbix`, contraseña `zabbix`.

Cambia la contraseña inicial de Zabbix inmediatamente después del primer acceso. Son credenciales de laboratorio, no de producción.

## Scripts disponibles dentro del contenedor

| Script | Función |
|---|---|
| `zbx-status.sh` | Muestra estado de persistencia, IP, gateway, procesos, frontend y conteo de hosts en la base de datos. |
| `zbx-add-hosts.sh` | Crea los hosts R1 y SW1 mediante la API JSON-RPC de Zabbix. |

`zbx-add-hosts.sh` utiliza por defecto valores propios de este laboratorio (`RO_20252175`, `10.21.75.1` y `10.21.75.2`). Al reutilizar la imagen en otra red, configura las variables `COMM`, `R1_IP`, `SW1_IP` y `ZPASS` adecuadas.

## Código fuente y documentación

- Proyecto: https://github.com/fredcastillo/Zabbix-SNMP-Network-Monitoring-Lab
- Carpeta Docker: https://github.com/fredcastillo/Zabbix-SNMP-Network-Monitoring-Lab/tree/main/docker/Zabbix
- Docker Hub: https://hub.docker.com/r/fredcastillo/zabbix-server

Esta imagen está orientada a laboratorios educativos y no constituye una instalación endurecida para producción.
