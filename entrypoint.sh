#!/bin/bash
mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp 
NGINX_DEFAULT_CONF="/tmp/nginx/conf.d/default.conf"
mkdir -p /tmp/nginx/conf.d/

cp ./config.template.json /tmp/config.json
cp ./nginx.template.conf $NGINX_DEFAULT_CONF

if [[ ! -n "$WARPKEY" ]]; then
  WARPKEY="WARPKEY"
fi

if [[ ! -n "$WARPSERVER" ]]; then
  WARPSERVER="engage.cloudflareclient.com"
fi

if [[ ! -n "$WARPPORT" ]]; then
  WARPPORT="2408"
fi
sed -i "s/UUID/$UUID/g" /tmp/config.json
sed -i "s~WARPKEY~$WARPKEY~g" /tmp/config.json
sed -i "s/WARPSERVER/$WARPSERVER/g" /tmp/config.json
sed -i "s/WARPPORT/$WARPPORT/g" /tmp/config.json
sed -i "s/UUID/$UUID/g" $NGINX_DEFAULT_CONF

if [[ ! -n "$JDOMAIN" ]]; then
  JDOMAIN=$(curl -s4m6 ip.sb -k)
fi

vmess="vmess://$(echo -n "\
{\
\"v\": \"2\",\
\"ps\": \"vmess_${JDOMAIN}\",\
\"add\": \"${JDOMAIN}\",\
\"port\": \"443\",\
\"id\": \"$UUID\",\
\"aid\": \"0\",\
\"net\": \"ws\",\
\"type\": \"none\",\
\"host\": \"${JDOMAIN}\",\
\"path\": \"/$UUID-vm\",\
\"tls\": \"tls\",\
\"sni\": \"${JDOMAIN}\"\
}"\
    | base64 -w 0)" 
vless="vless://${UUID}@${JDOMAIN}:443?encryption=none&security=tls&sni=$JDOMAIN&type=ws&host=${JDOMAIN}&path=/$UUID-vl#vless-${JDOMAIN}"
trojan="trojan://${UUID}@${JDOMAIN}:443?security=tls&type=ws&host=${JDOMAIN}&path=/$UUID-tr&sni=$JDOMAIN#trojan-${JDOMAIN}"

cat >> /tmp/log << EOF
Normal configs:
----------------------------------------------------------------
1：Vmess+ws+tls
${vmess}

----------------------------------------------------------------
2：Vless+ws+tls
${vless}

----------------------------------------------------------------
3：Trojan+ws+tls
${trojan}

----------------------------------------------------------------
EOF

if [[ "$WARPKEY" != "WARPKEY" ]]; then
vmess_warp="vmess://$(echo -n "\
{\
\"v\": \"2\",\
\"ps\": \"vmess_${JDOMAIN}_warp\",\
\"add\": \"${JDOMAIN}\",\
\"port\": \"443\",\
\"id\": \"$UUID\",\
\"aid\": \"0\",\
\"net\": \"ws\",\
\"type\": \"none\",\
\"host\": \"${JDOMAIN}\",\
\"path\": \"/$UUID-vm/warp\",\
\"tls\": \"tls\",\
\"sni\": \"${JDOMAIN}\"\
}"\
    | base64 -w 0)" 
vless_warp="vless://${UUID}@${JDOMAIN}:443?encryption=none&security=tls&sni=$JDOMAIN&type=ws&host=${JDOMAIN}&path=/$UUID-vl/warp#vless-${JDOMAIN}_warp"
trojan_warp="trojan://${UUID}@${JDOMAIN}:443?security=tls&type=ws&host=${JDOMAIN}&path=/$UUID-tr/warp&sni=$JDOMAIN#trojan-${JDOMAIN}_warp"

cat >> /tmp/log << EOF
WARP OUT configs:
----------------------------------------------------------------
4：Vmess+ws+tls+warp
${vmess_warp}

----------------------------------------------------------------
5：Vless+ws+tls+warp
${vless_warp}

----------------------------------------------------------------
6：Trojan+ws+tls+warp
${trojan_warp}

----------------------------------------------------------------
EOF
fi

cat >> /tmp/log << EOF
use cat /tmp/log to print configs
EOF
 
cat /tmp/log

nginx
/$XPID run -c /tmp/config.json
