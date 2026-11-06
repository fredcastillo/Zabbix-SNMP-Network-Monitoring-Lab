# Zabbix 7.0 LTS para GNS3 (imagen `zabbix:7.0`)

Zabbix server + MariaDB + Apache/PHP + agent2 + Firefox ESR en un solo contenedor.

- **Consola VNC de GNS3:** abre Firefox con `http://127.0.0.1/zabbix/` automáticamente.
- **Red:** cliente DHCP en `eth0` (reintenta hasta obtener IP).
- **Login web:** `Admin` / `zabbix` (cámbiela al entrar). Base de datos: `zabbix` / `zabbix`, solo local.
- **Zona horaria:** America/Santo_Domingo.

## Plantilla en GNS3

| Campo | Valor |
|---|---|
| Name | Zabbix |
| Adapters | 1 |
| Console type | vnc |
| Console resolution | 1280x800 |
| Additional persistent directories | `/var/lib/mysql`  **(obligatorio, ver PERSISTENCIA.md)** |

## Herramientas incluidas (consola auxiliar)

| Comando | Para qué sirve |
|---|---|
| `zbx-status.sh` | Diagnóstico: persistencia, IP, procesos, web y base de datos |
| `zbx-add-hosts.sh` | (Opcional) Crea R1 y SW1 con SNMPv2 por API |
| `zbx-export.sh` | (Opcional) Exporta los hosts del laboratorio a YAML |
| `snmpget`, `snmpwalk`, `zabbix_get`, `ping`, `traceroute`, `tcpdump` | Pruebas de red y SNMP |

Documentación de persistencia: [PERSISTENCIA.md](PERSISTENCIA.md)
