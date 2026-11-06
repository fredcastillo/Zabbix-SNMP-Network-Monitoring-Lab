# 09 — Controles de seguridad y limitaciones

## 1. Controles implementados

| Control                              | Implementación                                                                 | Riesgo que reduce                                              |
|--------------------------------------|--------------------------------------------------------------------------------|----------------------------------------------------------------|
| SNMP de solo lectura                 | `snmp-server community RO_20252175 RO 10`                                      | Cambios de configuración vía SNMP con una comunidad filtrada   |
| Comunidad no predeterminada          | `RO_20252175` en lugar de `public`                                             | Consultas con la comunidad conocida por defecto                |
| Restricción por origen               | `access-list 10 permit 10.21.75.0 0.0.0.255`, asociada a la comunidad          | Consultas SNMP desde redes ajenas a la LAN                     |
| Sin envío de traps ni escritura      | No hay `snmp-server enable traps` ni comunidades `RW`                          | Superficie de ataque innecesaria                               |
| Direcciones de infraestructura fijas | `.1` y `.2` estáticas y excluidas del pool DHCP                                | Que un cliente reciba la IP del gateway o del switch           |
| DHCP centralizado                    | Pool único en R1 con exclusiones                                               | Asignaciones manuales inconsistentes                           |
| Comunidad fuera de la interfaz de Zabbix | Macro `{$SNMP_COMMUNITY}` por host                                         | Valores repetidos y dispersos en la configuración              |
| Base de datos local                  | MariaDB escucha solo en `127.0.0.1` y usa socket                               | Acceso remoto a la base de datos de Zabbix                     |
| Persistencia con aviso               | La imagen avisa si `/var/lib/mysql` no se conserva                             | Pérdida silenciosa de la configuración de monitoreo            |

## 2. Prueba del control de solo lectura

El control se verifica en la Fase 5 de [`06-verificacion.md`](06-verificacion.md): la lectura con la comunidad funciona, una escritura con esa comunidad es rechazada y una comunidad distinta no recibe respuesta. En R1 y SW1, el contador `Number of altered variables` de `show snmp` permanece en cero.

## 3. Limitaciones conocidas

| Observación                                                                                         | Detalle                                                                                      |
|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| SNMPv2c no cifra ni autentica por usuario                                                           | La comunidad viaja en texto claro dentro de la LAN. SNMPv3 con `authPriv` ofrece autenticación y cifrado |
| Credenciales iniciales de Zabbix                                                                    | `Admin` / `zabbix` y la base de datos `zabbix` / `zabbix` son los valores estándar. La clave de `Admin` debe cambiarse en el primer acceso |
| Contenedor ejecutado con privilegios                                                                | GNS3 crea los contenedores con privilegios; el entorno es de laboratorio                     |
| Comunidad `ILMI` de solo lectura en R1                                                              | Aparece de forma predeterminada en la imagen del router y no fue creada para este laboratorio |
| Servicios HTTP/HTTPS habilitados en SW1                                                             | `ip http server` e `ip http secure-server` vienen activos en la imagen IOSvL2; R1 los tiene desactivados |
| Líneas `vty` sin contraseña                                                                         | No se configuró acceso remoto; la administración es solo por consola                         |
| Comunidad SNMP visible en las running-configs                                                       | Es un valor de laboratorio y debe sustituirse en un entorno real                             |

## 4. Mejoras posibles

- Migrar a SNMPv3 con `authPriv` y un usuario dedicado para Zabbix.
- Deshabilitar `ip http server` y `ip http secure-server` en SW1.
- Reservar una dirección fija para Zabbix en el pool DHCP, de modo que la ACL pueda limitarse a una sola IP.
- Configurar acceso remoto por SSH con autenticación local para R1 y SW1.
- Definir un valor distinto de la comunidad por dispositivo.
