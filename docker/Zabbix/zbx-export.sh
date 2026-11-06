#!/bin/bash
API="http://127.0.0.1/zabbix/api_jsonrpc.php"
ZUSER="${ZUSER:-Admin}"; ZPASS="${ZPASS:-zabbix}"
FILTRO="${FILTRO:-20252175}"
OUT="${1:-/root/zabbix-hosts-export.yaml}"
TOKEN=""

api() {
    local H=()
    [ -n "$TOKEN" ] && H=(-H "Authorization: Bearer $TOKEN")
    curl -s "${H[@]}" -H 'Content-Type: application/json-rpc' \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"$1\",\"params\":$2,\"id\":1}" "$API"
}

TOKEN=$(api user.login "$(jq -n --arg u "$ZUSER" --arg p "$ZPASS" '{username:$u,password:$p}')" | jq -r '.result // empty')
[ -z "$TOKEN" ] && { echo "Login fallido (usuario/clave)."; exit 1; }

IDS=$(api host.get "$(jq -n --arg f "$FILTRO" '{search:{host:[$f]},output:["hostid"]}')" | jq -c '[.result[].hostid]')
if [ -z "$IDS" ] || [ "$IDS" = "[]" ]; then
    echo "No encontre hosts que contengan '$FILTRO' en el nombre."; exit 1
fi

RESP=$(api configuration.export "$(jq -n --argjson ids "$IDS" '{options:{hosts:$ids},format:"yaml"}')")
if echo "$RESP" | jq -e '.result' >/dev/null 2>&1; then
    echo "$RESP" | jq -r '.result' > "$OUT"
    echo "Exportado: $OUT  ($(grep -c 'host:' "$OUT") lineas 'host:')"
else
    echo "Error de la API: $(echo "$RESP" | jq -c '.error')"; exit 1
fi
