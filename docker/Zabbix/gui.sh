#!/bin/bash
if [ -z "$DISPLAY" ]; then
    echo "[gui] DISPLAY no definido (la consola no es VNC). Saliendo."
    exit 0
fi
N=${DISPLAY#:}; N=${N%%.*}
for i in $(seq 1 120); do [ -S "/tmp/.X11-unix/X${N}" ] && break; sleep 1; done

openbox &
sleep 1

until curl -s -o /dev/null http://127.0.0.1/zabbix/; do sleep 2; done

if [ -f /etc/zbx-persist-warning.txt ]; then
    xterm -T "AVISO: SIN PERSISTENCIA" -bg darkred -fg white -geometry 82x13+10+10 \
          -e bash -c 'cat /etc/zbx-persist-warning.txt; read -r -p "  Pulse Enter para cerrar este aviso..."' &
fi

while true; do
    firefox-esr --no-remote --profile /opt/firefox-profile http://127.0.0.1/zabbix/
    sleep 2
done
