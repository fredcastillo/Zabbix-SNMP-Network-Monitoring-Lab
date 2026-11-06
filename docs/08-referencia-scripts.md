# 08 — Referencia de scripts

## 1. Scripts del host (GNS3 VM)

Se ejecutan con `bash` desde la raíz del repositorio.

| Script                          | Uso                                             | Función                                                                 |
|---------------------------------|-------------------------------------------------|-------------------------------------------------------------------------|
| `scripts/build-image.sh`        | `bash scripts/build-image.sh`                   | Ejecuta `docker build` en `docker/Zabbix` y etiqueta la imagen `zabbix:7.0` |
| `scripts/test-container.sh`     | `bash scripts/test-container.sh`                | Inicia un contenedor de prueba, ejecuta `zbx-status.sh`, genera una captura con Firefox headless y elimina el contenedor |
| `scripts/publish-image.sh`      | `bash scripts/publish-image.sh USUARIO`         | Etiqueta y sube la imagen a Docker Hub (requiere `docker login`)         |

## 2. Configuración de los equipos Cisco

Se pegan en la consola de cada equipo.

| Archivo                  | Equipo | Contenido                                                          |
|--------------------------|--------|--------------------------------------------------------------------|
| `scripts/r1-config.txt`  | R1     | Hostname, IP de `Fa0/0`, pool DHCP, ACL 10, comunidad SNMP, consola |
| `scripts/sw1-config.txt` | SW1    | Hostname, `Vlan1`, gateway, puertos, ACL 10, comunidad SNMP, consola |

## 3. Scripts internos del contenedor (`docker/Zabbix`)

### `entrypoint.sh`

Es el punto de entrada de la imagen. En orden:

1. Crea los directorios de ejecución y asigna propietarios a `mysql` y `zabbix`.
2. Amplía `/dev/shm` a 512 MB para Firefox.
3. Detecta si GNS3 montó `/gns3volumes/var/lib/mysql` y escribe el resultado en `/var/log/persistence.status`. Si no está montado, crea `/etc/zbx-persist-warning.txt` con el aviso.
4. Lanza en segundo plano el cliente DHCP: espera `eth0`, la activa y ejecuta `dhclient -1` cada vez que la interfaz no tiene IPv4.
5. Si no existe `/var/lib/mysql/zabbix`, ejecuta `db-init.sh`.
6. Reemplaza el proceso por `supervisord`.

### `db-init.sh`

Inicializa MariaDB si el directorio de datos está vacío, arranca el servidor si no está activo, crea la base `zabbix` con `utf8mb4` y `utf8mb4_bin`, crea el usuario `zabbix` para `localhost` y `127.0.0.1`, importa `/usr/share/zabbix-sql-scripts/mysql/server.sql.gz` y apaga el servidor si fue él quien lo inició. Es idempotente: no hace nada si la base ya existe.

### `supervisord.conf`

| Programa        | Comando                                      | Notas                                                  |
|-----------------|----------------------------------------------|--------------------------------------------------------|
| `mariadb`       | `mariadbd --user=mysql`                      | Prioridad 10; hasta 30 s para apagarse                  |
| `apache2`       | `apache2ctl -D FOREGROUND`                   | Prioridad 20                                           |
| `zabbix-server` | `zabbix_server -f` tras esperar a MariaDB    | Prioridad 30; hasta 30 s para apagarse                  |
| `zabbix-agent2` | `zabbix_agent2 -f`                           | Se ejecuta como usuario `zabbix`                       |
| `gui`           | `gui.sh`                                     | Termina sin error si no hay `DISPLAY`                  |

### `gui.sh`

Si no existe la variable `DISPLAY`, termina. Si existe, espera el socket `/tmp/.X11-unix/X<n>`, inicia openbox, espera a que Apache responda, muestra una ventana roja de `xterm` cuando `/var/lib/mysql` no es persistente y abre Firefox en `http://127.0.0.1/zabbix/`. Si Firefox se cierra, lo vuelve a abrir.

### `zbx-status.sh`

Muestra el estado de persistencia, los directorios montados aparte, la IP de `eth0`, el gateway, los procesos principales, el código HTTP de `/zabbix/`, el número de hosts en la base de datos y las últimas líneas de `zabbix_server.log`.

### `zbx-add-hosts.sh`

Crea R1 y SW1 mediante la API JSON-RPC de Zabbix.

| Variable   | Valor por defecto | Descripción                      |
|------------|-------------------|----------------------------------|
| `ZUSER`    | `Admin`           | Usuario de Zabbix                |
| `ZPASS`    | `zabbix`          | Clave de Zabbix                  |
| `COMM`     | `RO_20252175`     | Comunidad SNMP                   |
| `R1_IP`    | `10.21.75.1`      | IP de R1                         |
| `SW1_IP`   | `10.21.75.2`      | IP de SW1                        |

```
ZPASS=CLAVE_DE_ADMIN zbx-add-hosts.sh
```

### `zbx-export.sh`

Exporta a YAML los hosts cuyo nombre contiene `20252175`.

| Variable   | Valor por defecto | Descripción                                |
|------------|-------------------|--------------------------------------------|
| `ZUSER`    | `Admin`           | Usuario de Zabbix                          |
| `ZPASS`    | `zabbix`          | Clave de Zabbix                            |
| `FILTRO`   | `20252175`        | Texto que debe contener el nombre del host |

```
ZPASS=CLAVE_DE_ADMIN zbx-export.sh /root/zabbix-hosts-export.yaml
docker cp NOMBRE_CONTENEDOR:/root/zabbix-hosts-export.yaml .
```

## 4. Archivos de configuración del contenedor

| Archivo            | Destino en la imagen                          | Función                                                       |
|--------------------|-----------------------------------------------|---------------------------------------------------------------|
| `zabbix.conf.php`  | `/etc/zabbix/web/zabbix.conf.php`             | Conexión del frontend con la base de datos; omite el asistente |
| `99-zabbix.cnf`    | `/etc/mysql/mariadb.conf.d/99-zabbix.cnf`     | Juego de caracteres `utf8mb4`, escucha local, buffer de 256 MB |
| `user.js`          | `/opt/firefox-profile/user.js`                | Sin asistentes de bienvenida, render por software              |
| `supervisord.conf` | `/etc/supervisor/supervisord.conf`            | Procesos del contenedor                                        |
