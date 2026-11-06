#!/bin/bash
API="http://127.0.0.1/zabbix/api_jsonrpc.php"
ZUSER="${ZUSER:-Admin}"; ZPASS="${ZPASS:-zabbix}"
COMM="${COMM:-RO_20252175}"
R1_IP="${R1_IP:-10.21.75.1}"; SW1_IP="${SW1_IP:-10.21.75.2}"
TOKEN=""

api() {
    local H=()
    [ -n "$TOKEN" ] && H=(-H "Authorization: Bearer $TOKEN")
    curl -s "${H[@]}" -H 'Content-Type: application/json-rpc' \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"$1\",\"params\":$2,\"id\":1}" "$API"
}

TOKEN=$(api user.login "$(jq -n --arg u "$ZUSER" --arg p "$ZPASS" '{username:$u,password:$p}')" | jq -r '.result // empty')
[ -z "$TOKEN" ] && { echo "Login fallido (usuario/clave)."; exit 1; }

GID=$(api hostgroup.get '{"filter":{"name":["Network devices"]}}' | jq -r '.result[0].groupid // empty')
[ -z "$GID" ] && GID=$(api hostgroup.create '{"name":"Network devices"}' | jq -r '.result.groupids[0]')

tid() { api template.get "$(jq -n --arg n "$1" '{filter:{host:[$n]},output:["templateid"]}')" | jq -r '.result[0].templateid // empty'; }
T_CISCO=$(tid "Cisco IOS by SNMP"); T_ICMP=$(tid "ICMP Ping")
[ -z "$T_CISCO" ] && { echo "No encontre la plantilla 'Cisco IOS by SNMP'."; exit 1; }
[ -z "$T_ICMP" ]  && { echo "No encontre la plantilla 'ICMP Ping'."; exit 1; }

add_host() {
    local p
    p=$(jq -n --arg h "$1" --arg ip "$2" --arg c "$COMM" --arg g "$GID" --arg t1 "$T_CISCO" --arg t2 "$T_ICMP" '{
        host:$h,
        groups:[{groupid:$g}],
        templates:[{templateid:$t1},{templateid:$t2}],
        interfaces:[{type:2,main:1,useip:1,ip:$ip,dns:"",port:"161",
                     details:{version:2,bulk:1,community:"{$SNMP_COMMUNITY}"}}],
        macros:[{macro:"{$SNMP_COMMUNITY}",value:$c}]}')
    echo -n "$1 ($2): "; api host.create "$p" | jq -c '.result // .error'
}

add_host "R1-20252175"  "$R1_IP"
add_host "SW1-20252175" "$SW1_IP"
