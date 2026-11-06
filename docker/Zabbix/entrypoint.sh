#!/bin/bash
mkdir -p /run/mysqld /run/zabbix /var/run/apache2 /var/lock/apache2 /var/log/supervisor /var/log/zabbix
chown mysql:mysql /run/mysqld
chown zabbix:zabbix /run/zabbix /var/log/zabbix
chown -R mysql:mysql /var/lib/mysql
mount -o remount,size=512m /dev/shm 2>/dev/null || true

if [ -d /gns3volumes/var/lib/mysql ]; then
    echo "PERSISTENTE: /var/lib/mysql se guarda en el proyecto de GNS3." > /var/log/persistence.status
    rm -f /etc/zbx-persist-warning.txt
else
    echo "NO PERSISTENTE: /var/lib/mysql se perdera al cerrar el proyecto." > /var/log/persistence.status
    cat > /etc/zbx-persist-warning.txt <<'EOW'

  ATENCION: /var/lib/mysql NO es un directorio persistente en GNS3.
  Todo lo que configure en Zabbix (clave, hosts, plantillas) se PERDERA
  al cerrar el proyecto.

  Solucion: Edit > Preferences > Docker containers > Zabbix > Edit >
  Advanced > "Additional persistent directories" > agregar /var/lib/mysql
  Luego BORRE este nodo del proyecto y arrastre uno nuevo.
  (Guia completa: PERSISTENCIA.md)

EOW
fi
cat /var/log/persistence.status

(
    ip link set lo up
    for i in $(seq 1 30); do ip link show eth0 >/dev/null 2>&1 && break; sleep 1; done
    ip link set eth0 up
    while true; do
        if ! ip -4 addr show dev eth0 | grep -q 'inet '; then
            dhclient -1 -v -pf /run/dhclient.eth0.pid -lf /var/lib/dhcp/dhclient.eth0.leases eth0
        fi
        sleep 5
    done
) > /var/log/dhcp-client.log 2>&1 &

[ -d /var/lib/mysql/zabbix ] || /usr/local/bin/db-init.sh

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
