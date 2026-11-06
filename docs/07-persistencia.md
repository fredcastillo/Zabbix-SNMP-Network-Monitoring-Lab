# 07 — Persistencia de Zabbix V1 en GNS3

## 1. Por qué debe persistir MariaDB

Los usuarios, hosts, plantillas, macros e histórico de Zabbix se almacenan en MariaDB. En esta imagen, los datos están en `/var/lib/mysql`; ese directorio debe agregarse a los directorios persistentes de la plantilla Docker de GNS3.

## 2. Configuración

1. Abre **Edit → Preferences → Docker containers**.
2. Selecciona `Zabbix` y pulsa **Edit**.
3. Ve a **Advanced**.
4. En **Additional persistent directories**, agrega `/var/lib/mysql`.
5. Guarda la plantilla. Si la modificaste después de crear el nodo, crea un nodo nuevo desde la plantilla actualizada; respalda primero los datos que quieras conservar.

## 3. Montaje en GNS3

GNS3 conserva el directorio dentro de `project-files/docker/<id-del-nodo>/...` y lo monta en el contenedor. En el entorno del laboratorio se observa el destino `/gns3volumes/var/lib/mysql`, enlazado con el directorio del proyecto; MariaDB sigue utilizando `/var/lib/mysql` dentro del contenedor.

```bash
docker ps --format '{{.Names}}'
docker inspect ID_DEL_CONTENEDOR --format '{{range .Mounts}}{{println .Destination "->" .Source}}{{end}}'
```

## 4. Verificación

Dentro del contenedor ejecuta:

```bash
zbx-status.sh
```

Debe informar `PERSISTENTE` y mostrar los procesos MariaDB, Apache, Zabbix Server y Agent 2 activos.

## 5. Prueba real de persistencia

1. Cambia la contraseña inicial de Admin y verifica que R1 y SW1 estén registrados.
2. Detén los nodos y cierra el proyecto GNS3.
3. Abre nuevamente el proyecto e inicia R1, SW1 y Zabbix.
4. Inicia sesión con la contraseña nueva y comprueba que los hosts sigan presentes.
5. Confirma que SNMP vuelve a estar disponible.

Reiniciar solo el contenedor no sustituye esta prueba.

## 6. Respaldo en V1

Para exportar los hosts: **Data collection → Hosts → Export → YAML**.

Para respaldar la base de datos completa, dentro del contenedor:

```bash
mysqldump zabbix | gzip > /root/zabbix-backup.sql.gz
```

Copia el archivo a la GNS3 VM antes de cerrar o eliminar el proyecto:

```bash
docker cp ID_DEL_CONTENEDOR:/root/zabbix-backup.sql.gz .
```

`/root` no está incluido en los directorios persistentes por defecto.

## 7. Descargar la imagen V1

```bash
docker pull fredcastillo/zabbix-server:7.0-v1
```

En GNS3, selecciona esa imagen en la plantilla y agrega `/var/lib/mysql` a **Additional persistent directories**.
