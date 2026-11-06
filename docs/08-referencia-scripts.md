# 08 — Referencia de scripts V1

## 1. Scripts Docker ejecutados desde la raíz del repositorio

| Script | Comando | Función |
|---|---|---|
| `scripts/build-image.sh` | `bash scripts/build-image.sh` | Construye la imagen local `zabbix:7.0-v1` desde `docker/Zabbix/`. |
| `scripts/test-container.sh` | `bash scripts/test-container.sh` | Comprueba procesos, frontend y Firefox headless de la imagen V1. No sustituye la prueba de persistencia en GNS3. |
| `scripts/publish-image.sh` | `bash scripts/publish-image.sh` | Publica la imagen local V1 en `fredcastillo/zabbix-server:7.0-v1` y `:latest`, previa confirmación. |

## 2. Configuración Cisco

- `scripts/r1-config.txt`: configuración aplicada en R1.
- `scripts/sw1-config.txt`: configuración aplicada en SW1.
- `scripts/verification-commands.md`: comandos de comprobación.

Los running-config resultantes están en `configs/R1/` y `configs/SW1/`.

## 3. Scripts internos de la imagen V1

| Archivo | Función |
|---|---|
| `entrypoint.sh` | Prepara directorios, detecta persistencia, solicita DHCP y ejecuta Supervisor. |
| `db-init.sh` | Inicializa MariaDB y carga el esquema Zabbix si no existe. |
| `gui.sh` | Inicia Openbox y Firefox sobre el display VNC de GNS3. |
| `zbx-status.sh` | Informa persistencia, IP, gateway, procesos, frontend y base de datos. |
| `zbx-add-hosts.sh` | Crea R1 y SW1 mediante la API de Zabbix. |

La V1 no incluye un script de exportación YAML. Los hosts se exportan desde **Data collection → Hosts → Export → YAML**.

## 4. Herramientas incluidas

`snmpget`, `snmpwalk`, `snmpset`, `zabbix_get`, `ping`, `traceroute`, `tcpdump`, `iproute2`, `curl` y `jq`.

No publiques tokens de Docker Hub ni contraseñas personales en los scripts o en el repositorio.
