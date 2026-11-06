# Cómo hacer persistente la configuración de Zabbix en GNS3

## Por qué se pierde todo

En GNS3, un contenedor Docker **se destruye al cerrar el proyecto**. Lo que no esté en un
*directorio persistente* desaparece: la clave de Admin, los hosts, las plantillas y el histórico.
Todo eso vive en la base de datos, en `/var/lib/mysql`. Por eso ese directorio **debe** marcarse como persistente.

GNS3 guarda los directorios persistentes dentro de la carpeta del proyecto
(`project-files/docker/<id-del-nodo>/...`) y los vuelve a montar en cada arranque.

## Paso a paso

1. Abra **Edit → Preferences → Docker containers**, seleccione `Zabbix` y pulse **Edit**.
2. Vaya a la pestaña **Advanced**.
3. En **Additional persistent directories** escriba `/var/lib/mysql` y pulse **Add**.
   Debe verse en la lista. Pulse **Apply** y luego **OK**.
4. **Importante:** los cambios en la plantilla solo afectan a los nodos nuevos.
   Si ya tenía un nodo Zabbix en el proyecto, **bórrelo** y arrastre uno nuevo desde la plantilla.
5. Conéctelo, enciéndalo y espere 2 a 3 minutos. **El primer arranque es más lento**, porque GNS3
   copia la base de datos inicial al directorio del proyecto.
6. Configure Zabbix (cambie la clave de Admin, cree sus hosts).

## Cómo comprobar que quedó persistente

**Opción A, desde el propio contenedor.** Abra la consola auxiliar del nodo y ejecute:

```bash
zbx-status.sh
```

La primera sección debe decir `PERSISTENTE: /var/lib/mysql se guarda en el proyecto de GNS3.`
Si no es así, al abrir la consola VNC aparece una **ventana roja de aviso**.

**Opción B, desde la GNS3 VM (SSH).**

```bash
docker ps --format '{{.Names}}'
docker inspect NOMBRE_DEL_CONTENEDOR --format '{{json .Mounts}}'
```

Debe aparecer un montaje con destino `/gns3volumes/var/lib/mysql` y origen dentro de `project-files/docker/`.

## Prueba de reinicio (hágala siempre)

1. Cambie la clave de Admin y cree un host de prueba.
2. Apague el nodo con clic derecho → **Stop** (espere a que termine) y luego cierre el proyecto.
3. Ábralo de nuevo y encienda el nodo.
4. Entre con **su clave nueva** y compruebe que el host sigue ahí.

## Persistir otras configuraciones propias

Funciona igual para cualquier directorio: agréguelo en **Additional persistent directories**.
La primera vez, GNS3 copia el contenido original de la imagen a la carpeta del proyecto y desde ahí manda lo del proyecto.

| Directorio | Qué guarda | Cuándo agregarlo |
|---|---|---|
| `/var/lib/mysql` | Toda la configuración e histórico de Zabbix | **Siempre** |
| `/etc/zabbix` | `zabbix_server.conf`, `zabbix_agent2.conf` | Si edita esos archivos |
| `/usr/lib/zabbix/alertscripts` | Scripts de alertas propios | Si crea alertas personalizadas |
| `/usr/lib/zabbix/externalscripts` | Scripts externos propios | Si usa *External check* |
| `/root` | Descargas y perfil de Firefox | Si guarda archivos exportados ahí |

Nota: `/etc/network` ya es persistente por defecto en GNS3.

## Respaldo de seguridad (recomendado)

La persistencia dura mientras exista el proyecto. Para tener una copia fuera de él, exporte los hosts a YAML.

Por la interfaz: *Data collection → Hosts* → marque los hosts → **Export → YAML**.
Por script (dentro del contenedor):

```bash
ZPASS=su_clave zbx-export.sh              # genera /root/zabbix-hosts-export.yaml
```

Para sacarlo del contenedor, desde la GNS3 VM:

```bash
docker cp NOMBRE_DEL_CONTENEDOR:/root/zabbix-hosts-export.yaml .
```

Copia completa de la base de datos (dentro del contenedor):

```bash
mysqldump zabbix | gzip > /root/zabbix-backup.sql.gz
```

Recuerde que `/root` no es persistente salvo que lo agregue a la lista. Saque el archivo con `docker cp` antes de cerrar el proyecto.

## Uso fuera de GNS3 (Docker normal)

```bash
docker run -d --name zabbix --privileged -p 8080:80 -v zabbix-db:/var/lib/mysql zabbix:7.0
```

El frontend queda en `http://localhost:8080/zabbix/`. Usuario `Admin`, clave `zabbix`: **cámbiela** al entrar.
