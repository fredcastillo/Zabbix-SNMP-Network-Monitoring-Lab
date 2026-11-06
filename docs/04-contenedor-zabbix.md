# 04 — Contenedor Zabbix V1 para GNS3

La imagen publicada `fredcastillo/zabbix-server:7.0-v1` integra los componentes necesarios para monitorizar R1 y SW1 mediante SNMP y acceder al frontend desde la consola VNC de GNS3.

## 1. Identificación de la imagen

| Elemento | Valor |
|---|---|
| Docker Hub | `fredcastillo/zabbix-server` |
| Tag utilizado en A2 | `7.0-v1` |
| Alias publicado | `latest` (misma imagen V1) |
| Pull | `docker pull fredcastillo/zabbix-server:7.0-v1` |
| Código fuente | [`docker/Zabbix/`](../docker/Zabbix) |

## 2. Componentes

| Componente | Función |
|---|---|
| Zabbix Server 7.0 LTS | Recolección de métricas SNMP |
| Zabbix Agent 2 | Monitorización local del contenedor |
| MariaDB | Base de datos Zabbix |
| Apache + PHP | Frontend web |
| Firefox ESR + Openbox | Interfaz gráfica en consola VNC |
| `dhclient` | Cliente DHCP de `eth0` |
| Herramientas SNMP/red | `snmpget`, `snmpwalk`, `snmpset`, `ping`, `traceroute`, `tcpdump`, `zabbix_get` |

La V1 contiene los scripts `zbx-status.sh` y `zbx-add-hosts.sh`. **No contiene `zbx-export.sh`**; por eso no debe documentarse ni utilizarse como una función de esta imagen.

## 3. Archivos fuente

| Archivo | Función |
|---|---|
| `Dockerfile` | Construye la imagen V1 |
| `entrypoint.sh` | Prepara rutas, verifica persistencia, inicia DHCP y Supervisor |
| `db-init.sh` | Inicializa MariaDB y carga el esquema Zabbix si todavía no existe |
| `supervisord.conf` | Define los procesos del contenedor |
| `gui.sh` | Inicia Openbox y Firefox sobre el display VNC |
| `zabbix.conf.php` | Configuración del frontend y conexión local a MariaDB |
| `99-zabbix.cnf` | Configuración de MariaDB |
| `user.js` | Preferencias del perfil Firefox |
| `zbx-status.sh` | Diagnóstico del contenedor |
| `zbx-add-hosts.sh` | Alta de R1 y SW1 mediante API JSON-RPC |

## 4. Construcción y prueba local

Desde la raíz del repositorio:

```bash
bash scripts/build-image.sh
bash scripts/test-container.sh
```

La imagen local se etiqueta `zabbix:7.0-v1`. La prueba es un smoke test; la validación de persistencia debe realizarse dentro de un proyecto GNS3 cerrándolo y abriéndolo de nuevo.

Una reconstrucción desde el Dockerfile puede producir un digest distinto al publicado si los repositorios base o paquetes han cambiado. Para obtener el artefacto exacto publicado, descarga el tag de Docker Hub.

## 5. Plantilla GNS3

| Campo | Valor |
|---|---|
| Name | `Zabbix` |
| Image | `fredcastillo/zabbix-server:7.0-v1` |
| Adapters | `1` |
| Console type | `vnc` |
| Console resolution | `1280x800` |
| Additional persistent directories | `/var/lib/mysql` (**obligatorio**) |

## 6. Inicio y acceso

El `entrypoint.sh` detecta el directorio persistente, inicia el cliente DHCP en `eth0`, inicializa la base de datos únicamente si no existe y ejecuta Supervisor. Supervisor mantiene los servicios activos. Cuando GNS3 proporciona un display VNC, `gui.sh` inicia Openbox y Firefox en `http://127.0.0.1/zabbix/`.

| Servicio | Acceso |
|---|---|
| Frontend | `http://127.0.0.1/zabbix/` dentro del VNC |
| Usuario inicial | `Admin` |
| Contraseña inicial | `zabbix` |
| Usuario DB local | `zabbix` |
| Contraseña DB local | `zabbix` |

Cambia la contraseña de Admin al primer acceso. Las credenciales de base de datos son valores de laboratorio y MariaDB está configurada para escuchar localmente.

## 7. Herramientas incluidas

| Comando | Uso |
|---|---|
| `zbx-status.sh` | Estado de persistencia, IP, gateway, procesos, frontend y conteo de hosts |
| `zbx-add-hosts.sh` | Crea R1 y SW1 por API; permite configurar `ZPASS`, `COMM`, `R1_IP` y `SW1_IP` mediante variables de entorno |
| `snmpget`, `snmpwalk`, `snmpset` | Consultas/pruebas SNMP |
| `ping`, `traceroute`, `tcpdump` | Diagnóstico de red |

Ejemplo de alta automatizada (usa la contraseña actual de Admin):

```bash
ZPASS='TU_CLAVE_DE_ADMIN' zbx-add-hosts.sh
```

El script trae valores iniciales específicos del laboratorio A2. Sustitúyelos al reutilizar la imagen en otra red.

## 8. Publicación

La imagen está publicada en [Docker Hub](https://hub.docker.com/r/fredcastillo/zabbix-server). Para descargarla:

```bash
docker pull fredcastillo/zabbix-server:7.0-v1
```

Script de publicación de esta V1: [`scripts/publish-image.sh`](../scripts/publish-image.sh). Requiere `docker login` y confirmación interactiva antes de sobrescribir los tags publicados.
