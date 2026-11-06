FROM debian:12

ARG DEBIAN_FRONTEND=noninteractive
ARG ZBX_REPO_DEB=https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
ENV TZ=America/Santo_Domingo
LABEL description="Zabbix 7.0 LTS all-in-one con Firefox para GNS3 (VNC)"

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates wget tzdata && \
    wget -q -O /tmp/zabbix-release.deb "${ZBX_REPO_DEB}" && \
    dpkg -i /tmp/zabbix-release.deb && rm /tmp/zabbix-release.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
      zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf \
      zabbix-sql-scripts zabbix-agent2 zabbix-get \
      mariadb-server apache2 libapache2-mod-php \
      php-mysql php-bcmath php-mbstring php-gd php-xml php-ldap \
      supervisor \
      firefox-esr openbox xterm fonts-dejavu-core fonts-liberation \
      isc-dhcp-client ifupdown iproute2 iputils-ping net-tools traceroute \
      snmp curl jq nano procps tcpdump && \
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*

COPY 99-zabbix.cnf    /etc/mysql/mariadb.conf.d/99-zabbix.cnf
COPY zabbix.conf.php  /etc/zabbix/web/zabbix.conf.php
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY user.js          /opt/firefox-profile/user.js
COPY entrypoint.sh db-init.sh gui.sh zbx-status.sh zbx-add-hosts.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/*.sh && \
    chown www-data:www-data /etc/zabbix/web/zabbix.conf.php && \
    printf 'DBPassword=zabbix\nDBSocket=/run/mysqld/mysqld.sock\n' >> /etc/zabbix/zabbix_server.conf && \
    for d in /etc/php/*/apache2/conf.d; do \
        printf 'date.timezone=%s\npost_max_size=16M\nmax_execution_time=300\nmax_input_time=300\nmemory_limit=128M\n' "${TZ}" > "$d/99-zabbix.ini"; \
    done && \
    echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && a2enconf servername && \
    sed -i 's#</applications>#<application class="*"><maximized>yes</maximized></application></applications>#' /etc/xdg/openbox/rc.xml

RUN /usr/local/bin/db-init.sh

RUN apache2ctl -t && \
    (apache2ctl -M 2>&1 | grep -qi php) && \
    zabbix_server -V | head -1 && zabbix_agent2 -V | head -1 && \
    firefox-esr --version && \
    test -d /var/lib/mysql/zabbix && \
    grep -q 'maximized>yes' /etc/xdg/openbox/rc.xml

ENV MOZ_FAKE_NO_SANDBOX=1
EXPOSE 80 10050 10051
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
