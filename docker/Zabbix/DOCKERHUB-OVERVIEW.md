# Zabbix Server for GNS3 — V1

Custom Docker image based on Zabbix 7.0 LTS, designed to run as a Docker node inside GNS3.

## Pull the published image

```bash
docker pull fredcastillo/zabbix-server:7.0-v1
```

The `latest` tag currently points to the same V1 image. Use the explicit `7.0-v1` tag when you need to reproduce the image used in the A2 lab.

## Included components

- Zabbix Server 7.0 LTS and Zabbix Agent 2
- MariaDB database
- Apache and PHP frontend
- Firefox ESR and Openbox for the GNS3 VNC console
- DHCP client for `eth0`
- SNMP and network diagnostic utilities
- `zbx-status.sh` and `zbx-add-hosts.sh`

## GNS3 template

| Setting | Value |
|---|---|
| Console type | `vnc` |
| Resolution | `1280x800` |
| Network configuration | DHCP |
| Additional persistent directories | `/var/lib/mysql` |

**Persistence is required.** Add `/var/lib/mysql` to the template's Additional persistent directories setting. See the [V1 persistence guide](https://github.com/fredcastillo/Zabbix-SNMP-Network-Monitoring-Lab/blob/main/docker/Zabbix/PERSISTENCIA.md).

## Initial credentials

- Frontend user: `Admin`
- Initial password: `zabbix`
- Local database user/password: `zabbix` / `zabbix`

Change the Admin password after the first login. These are lab defaults and must not be used in production.

## Source and documentation

- [GitHub repository](https://github.com/fredcastillo/Zabbix-SNMP-Network-Monitoring-Lab)
- [Docker source folder](https://github.com/fredcastillo/Zabbix-SNMP-Network-Monitoring-Lab/tree/main/docker/Zabbix)
- [Docker Hub](https://hub.docker.com/r/fredcastillo/zabbix-server)

Educational lab image; not hardened for production use.
