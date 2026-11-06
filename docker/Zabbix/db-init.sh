#!/bin/bash
set -e
mkdir -p /run/mysqld /var/lib/mysql
chown mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "[db-init] /var/lib/mysql vacio: inicializando MariaDB..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null
fi

STARTED=0
if ! mysqladmin ping --silent 2>/dev/null; then
    mariadbd --user=mysql &
    MYSQLD_PID=$!
    STARTED=1
    for i in $(seq 1 90); do mysqladmin ping --silent 2>/dev/null && break; sleep 1; done
fi

if ! mysql -e "USE zabbix" 2>/dev/null; then
    echo "[db-init] Creando base de datos zabbix (puede tardar 1-3 min)..."
    mysql <<SQL
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';
CREATE USER IF NOT EXISTS 'zabbix'@'127.0.0.1' IDENTIFIED BY 'zabbix';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'127.0.0.1';
SET GLOBAL log_bin_trust_function_creators = 1;
SQL
    zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
        mysql --default-character-set=utf8mb4 -uzabbix -pzabbix zabbix
    mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"
    echo "[db-init] Esquema importado."
fi

if [ "$STARTED" = "1" ]; then
    mysqladmin shutdown
    wait $MYSQLD_PID || true
fi
