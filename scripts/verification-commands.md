# Comandos de verificación

## R1 (Cisco 7200)

```
show ip interface brief
show ip dhcp pool
show ip dhcp binding
show ip dhcp server statistics
show ip dhcp conflict
ping 10.21.75.2
show snmp community
show running-config | include snmp
show access-lists
show snmp
show clock
terminal length 0
show running-config
```

## SW1 (IOSvL2)

```
show ip interface brief
show interfaces status
show vlan brief
show spanning-tree interface gi0/1 portfast
show mac address-table
ping 10.21.75.1
show snmp community
show access-lists
show snmp
show clock
terminal length 0
show running-config
```

## Contenedor Zabbix (consola auxiliar)

```
zbx-status.sh
ip -4 addr show eth0
ip route
ping -c 4 10.21.75.1
ping -c 4 10.21.75.2
snmpget -v2c -c RO_20252175 10.21.75.1 1.3.6.1.2.1.1.1.0
snmpget -v2c -c RO_20252175 10.21.75.2 1.3.6.1.2.1.1.1.0
snmpwalk -v2c -c RO_20252175 10.21.75.1 1.3.6.1.2.1.2.2.1.2
snmpset -v2c -c RO_20252175 10.21.75.1 1.3.6.1.2.1.1.5.0 s PRUEBA
snmpget -v2c -c public 10.21.75.1 1.3.6.1.2.1.1.1.0
```

## GNS3 VM (SSH)

```
docker ps --format '{{.Names}}'
docker inspect NOMBRE_DEL_CONTENEDOR --format '{{json .Mounts}}'
docker exec NOMBRE_DEL_CONTENEDOR zbx-status.sh
```

## Zabbix (interfaz web)

| Verificación | Ruta |
|---|---|
| Disponibilidad SNMP de los hosts | Data collection → Hosts → columna Availability |
| Datos recolectados | Monitoring → Latest data → filtrar por host |
| Problemas activos | Monitoring → Problems |
| Gráfica de un ítem numérico | Latest data → enlace Graph del ítem |
