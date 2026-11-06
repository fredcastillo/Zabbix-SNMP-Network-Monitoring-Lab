#!/bin/bash
echo "== Persistencia =="
cat /var/log/persistence.status 2>/dev/null || echo "(sin dato: el contenedor no arranco con entrypoint.sh)"
echo "Directorios montados aparte (persistentes):"
grep -E ' /(var|etc|usr|root|opt|home)/' /proc/mounts | awk '{print "  " $2}' | grep -v -E '/etc/(hosts|hostname|resolv.conf)$' || echo "  (ninguno)"
echo "== IP de eth0 (DHCP) =="
ip -4 addr show eth0 2>/dev/null | grep inet || echo "SIN IP (DHCP pendiente)"
echo "== Gateway =="; ip route | grep default || echo "sin gateway"
echo "== Procesos =="
for p in mariadbd apache2 zabbix_server zabbix_agent2 openbox; do
    pgrep -x "$p" >/dev/null && echo "[OK] $p" || echo "[--] $p"
done
pgrep -f firefox >/dev/null && echo "[OK] firefox" || echo "[--] firefox (normal si no hay consola VNC)"
echo "== Web =="; echo "HTTP /zabbix/ -> $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/zabbix/)"
echo "== Base de datos =="; mysql -e "SELECT COUNT(*) AS hosts_en_zabbix FROM zabbix.hosts" 2>&1 | tail -2
echo "== Ultimas lineas zabbix_server.log =="; tail -n 5 /var/log/zabbix/zabbix_server.log 2>/dev/null
