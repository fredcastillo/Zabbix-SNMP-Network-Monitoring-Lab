# Persistencia de Zabbix V1 en GNS3

## Qué debe persistir

Los hosts, plantillas, macros, historial y contraseña de Admin se almacenan en MariaDB. En la imagen V1, los datos de MariaDB están en `/var/lib/mysql`; por eso esa ruta debe configurarse como directorio persistente en la plantilla Docker de GNS3.

## Configuración de GNS3

1. Abre **Edit → Preferences → Docker containers**.
2. Selecciona la plantilla `Zabbix` y pulsa **Edit**.
3. Entra en **Advanced**.
4. En **Additional persistent directories**, agrega exactamente `/var/lib/mysql`.
5. Guarda con **Apply** y **OK**.
6. Si modificaste la plantilla después de crear el nodo de la topología, crea un nodo nuevo desde la plantilla actualizada. Antes de borrar el anterior, verifica que los datos estén respaldados.

## Cómo funciona el montaje de GNS3

GNS3 guarda el directorio persistente dentro de la carpeta del proyecto y lo monta en el contenedor. En esta plantilla se utiliza una ruta interna de respaldo como `/gns3volumes/var/lib/mysql`; por eso `docker inspect` puede mostrar esa ruta como destino del montaje mientras MariaDB escribe en `/var/lib/mysql`.

## Verificación dentro del contenedor

Abre la consola auxiliar y ejecuta:

```bash
zbx-status.sh
```

Debe informar que `/var/lib/mysql` se guarda en el proyecto GNS3 y mostrar los procesos MariaDB, Apache, Zabbix Server y Agent 2 como activos.

## Verificación desde la GNS3 VM

```bash
docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}'
docker inspect ID_DEL_CONTENEDOR --format '{{range .Mounts}}{{println .Destination "->" .Source}}{{end}}'
```

Debe aparecer un montaje cuyo destino sea `/gns3volumes/var/lib/mysql` y cuyo origen esté dentro de `project-files/docker/` del proyecto.

## Prueba real de persistencia

1. Inicia sesión en Zabbix y cambia la contraseña inicial de Admin.
2. Comprueba que los hosts `R1-20252175` y `SW1-20252175` están registrados.
3. Detén los nodos y cierra el proyecto GNS3 de forma ordenada.
4. Abre de nuevo el proyecto e inicia R1, SW1 y Zabbix.
5. Inicia sesión con la contraseña nueva y comprueba que ambos hosts continúan registrados.
6. Verifica que SNMP vuelva a estar disponible.

Reiniciar solamente el contenedor no sustituye la prueba de cerrar y abrir el proyecto GNS3.

## Respaldo de los hosts y la base de datos en V1

La versión V1 no incluye un script de exportación YAML propio. Para exportar hosts, utiliza la interfaz web: **Data collection → Hosts → Export → YAML**.

Para una copia completa de la base de datos, dentro del contenedor ejecuta:

```bash
mysqldump zabbix | gzip > /root/zabbix-backup.sql.gz
```

Copia el archivo fuera del contenedor desde la GNS3 VM:

```bash
docker cp ID_DEL_CONTENEDOR:/root/zabbix-backup.sql.gz .
```

`/root` no está incluido en la persistencia por defecto. Extrae la copia antes de cerrar o eliminar el proyecto.

## Descargar y ejecutar fuera de GNS3 (opcional)

```bash
docker pull fredcastillo/zabbix-server:7.0-v1
docker run -d --name zabbix --privileged -p 8080:80 -v zabbix-db:/var/lib/mysql fredcastillo/zabbix-server:7.0-v1
```

El frontend queda en `http://localhost:8080/zabbix/`. El volumen nombrado conserva MariaDB entre recreaciones de este contenedor; este modo no reproduce la consola VNC ni el almacenamiento de proyecto gestionado por GNS3.
