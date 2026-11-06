# 05 — Monitorización SNMP en Zabbix

Este documento describe cómo se registraron R1 y SW1 en Zabbix y qué datos consulta la plantilla Cisco IOS by SNMP.

## 1. Acceso inicial

Dentro de la consola VNC del nodo Zabbix, Firefox abre `http://127.0.0.1/zabbix/`. El usuario inicial es `Admin` y la contraseña `zabbix`. Cambia la contraseña en el primer acceso.

## 2. Macro de comunidad SNMP

Los hosts usan la macro `{$SNMP_COMMUNITY}` en la interfaz SNMP. En esta práctica, el valor configurado es `RO_20252175`.

| Macro | Valor |
|---|---|
| `{$SNMP_COMMUNITY}` | `RO_20252175` |

## 3. Hosts registrados

| Campo | R1 | SW1 |
|---|---|---|
| Host name | `R1-20252175` | `SW1-20252175` |
| Template | Cisco IOS by SNMP | Cisco IOS by SNMP |
| Host group | Network devices | Network devices |
| Interface | SNMP | SNMP |
| IP | `10.21.75.1` | `10.21.75.2` |
| Port | `161` | `161` |
| SNMP version | SNMPv2c | SNMPv2c |
| Community | `{$SNMP_COMMUNITY}` | `{$SNMP_COMMUNITY}` |

## 4. Datos recolectados

La plantilla puede recopilar información del sistema (descripción, nombre, ubicación, contacto y uptime), disponibilidad SNMP, estado de interfaces, bits recibidos/enviados y errores. Algunas métricas de CPU, memoria o temperatura pueden no estar disponibles en imágenes virtuales IOSvL2/IOSv.

## 5. Dónde consultar

| Dato | Ruta en Zabbix |
|---|---|
| Disponibilidad SNMP | Data collection → Hosts → Availability |
| Valores actuales | Monitoring → Latest data |
| Evolución temporal | Latest data → Graph del ítem |
| Alertas | Monitoring → Problems |

[![Hosts SNMP](../images/07-zabbix-hosts-snmp.png)](../images/07-zabbix-hosts-snmp.png)
[![Latest data R1](../images/08-zabbix-latest-data-r1.png)](../images/08-zabbix-latest-data-r1.png)
[![Latest data SW1](../images/09-zabbix-latest-data-sw1.png)](../images/09-zabbix-latest-data-sw1.png)

## 6. Respaldo en la versión V1

La imagen V1 no incluye un comando propio para exportar hosts a YAML. Utiliza la interfaz de Zabbix: **Data collection → Hosts → Export → YAML**. Para una copia completa de la base de datos, consulta [07-persistencia.md](07-persistencia.md).
